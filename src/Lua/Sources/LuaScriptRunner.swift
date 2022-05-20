//
//  LuaScriptRunner.swift
//

import Foundation
import LuaSwiftBindings
#if MAIN_APP
import AppMakerCore
#elseif COMPANION
import AppMakerCompanionCore
#endif

final class LuaScriptRunner: AppMakerBuildProductRunnerImplementation {
    let logger: RunnerLogger
    let buildProduct: SimpleOfflineBuildProduct
    var vm: LuaSwiftBindings.VirtualMachine?
    let sendAction: (BuildProductRunnerAction) -> Void
    init(
        logger: RunnerLogger,
        buildProduct: SimpleOfflineBuildProduct,
        sendAction: @escaping (BuildProductRunnerAction) -> Void
    ) {
        self.logger = logger
        self.buildProduct = buildProduct
        self.sendAction = sendAction
    }
    private func log(_ msg: String, addNewLine: Bool = true) {
        if addNewLine {
            logger.log(msg + "\n")
        } else {
            logger.log(msg)
        }
    }
    func resume() {
        self.log("Creating Lua Virtual Machine")
        let vm = VirtualMachine()
        self.vm = vm
        let printStringToAppMaker = vm.createUncheckedFunction { [weak self] args in
            if let str: String = args.first as? String {
                self?.log(str)
            }
            return .nothing
        }
        vm.globals["printStringToAppMaker"] = printStringToAppMaker
        // load sandbox library
        guard case let .values(values) = vm.eval(self.luaSandboxLib),
            let firstValue = values.first,
            let sandboxTable = firstValue as? Table else {
            self.log("Lua sandboxing failed")
            self.sendAction(.finished(success: false))
            return
        }
        vm.globals["sandbox"] = sandboxTable
        // save user code path
        let executionURL: URL = buildProduct.buildProductPath.deletingLastPathComponent()
        vm.globals["entryFileName"] = buildProduct.buildProductPath.lastPathComponent
        vm.globals["getSandboxedUrl"] = vm.createUncheckedFunction { [weak self] args in
            if let self = self {
                if let fileName: String = args.first as? String {
                    guard let path: RawProjectFilePath = RawProjectFilePath.root.appending(path: fileName),
                          let pathStr = path.asLocalURL(withStartingUrl: executionURL)?.path else {
                        self.log("Warning ⚠️: Lua script tried to exit sandbox with a malformed file path \"\(fileName)\"")
                        return .nothing
                    }
                    return .value(pathStr)
                }
            }
            return .nothing
        }
        self.log("Running \(buildProduct.buildProductPath.lastPathComponent)")
        let evalResult = vm.eval(#"""
            local amDoFile
            local env = {
                print = function(...)
                    local args = {...}
                    local stringToPrint = ""
                    for i = 1, #args do
                        if i ~= 1 then
                            stringToPrint = stringToPrint .. "\t"
                        end
                        stringToPrint = stringToPrint .. tostring(args[i])
                    end
                    printStringToAppMaker(stringToPrint)
                end,
                dofile = function(filename)
                    if filename == nil then
                        printStringToAppMaker("dofile from stdin not supported yet")
                    else
                        local filename = tostring(filename)
                        local result = table.pack(amDoFile(filename))
                        if result[1] then
                            return table.unpack(result, 2, result.n)
                        else
                            error(result[2])
                        end
                    end
                end
            }
            amDoFile = function(filename)
                local fullURL = getSandboxedUrl(filename)
                if fullURL == nil then
                    return false
                end
                local protectedFunc = sandbox.protectURL(fullURL, {env = env})
                if type(protectedFunc) == "string" then
                    if string.find(tostring(protectedFunc), "No such file") then
                        printStringToAppMaker("Lua error ❌")
                        printStringToAppMaker(protectedFunc)
                    else
                        printStringToAppMaker("Lua syntax error ❌")
                        printStringToAppMaker(protectedFunc)
                    end
                    return false
                else
                    local protectedResult = table.pack(protectedFunc())
                    if protectedResult[1] then
                        return table.unpack(protectedResult)
                    else
                        if protectedResult[2] ~= nil then
                            printStringToAppMaker("Lua runtime error ❌")
                            printStringToAppMaker(protectedResult[2])
                        end
                        return false
                    end
                end
            end
            local finalResult = table.pack(amDoFile(entryFileName))
            if finalResult[1] then
                if finalResult.n == 1 then
                    printStringToAppMaker("Successfully ran Lua script ✅")
                else
                    local finalResultStr = ""
                    for i=2, finalResult.n do
                        if i ~= 1 then
                            finalResultStr = finalResultStr .. "\t"
                        end
                        finalResultStr = finalResultStr .. tostring(finalResult[i])
                    end
                    printStringToAppMaker("Successfully ran Lua script ✅ and returned: " .. finalResultStr)
                end
                return true
            else
                return false
            end
            """#)
        switch evalResult {
        case .values(let value):
            if value.first as? Bool == true {
                self.sendAction(.finished(success: true))
            } else {
                self.sendAction(.finished(success: false))
            }
        case .error(let error):
            self.log("Sandboxing error ❌")
            self.log(error)
            self.sendAction(.finished(success: false))
            return
        }
    }
    func suspend() {
        self.log("Cleaning Lua Virtual Machine")
        self.vm = nil
    }
    
    func destroyRunner() async {
        self.vm = nil
    }
}

