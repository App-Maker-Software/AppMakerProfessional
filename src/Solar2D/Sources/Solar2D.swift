//
//  Solar2D.swift
//

import Foundation
#if MAIN_APP
import AppMakerCore
import LuaSwiftBindings
#elseif COMPANION
import AppMakerCompanionCore
#endif
import SwiftUI

func solar2d_main() {
    
    // Install sandbox and runner
    solar2DRunner.licenseInformation = [
        "Solar2D (c) Solar2D, MIT license" // https://github.com/coronalabs/corona/
    ]
    try! solar2DRunner.install()
    
    #if MAIN_APP
    //
    // Solar2D Build System
    //
    let solar2dBuildSystem: AppMakerBuildSystem = AppMakerBuildSystem(
        named: "Solar2D Build System",
        icon: {
            Image(systemName: "sun.max")
        },
        validateEntryPath: { rawPath in
            let msg = "Entry path must be file named \"main.lua\""
            switch rawPath {
            case .sub(_, let name):
                return name == "main.lua" ? .valid : .invalid(reasonToTellUser: msg)
            case .root:
                return .invalid(reasonToTellUser: msg)
            @unknown default:
                return .invalid(reasonToTellUser: msg)
            }
        },
        validateEntryPathUserMessage: "Select any file named \"main.lua\"",
        implementation: Solar2DBuildSystem.self
    )
    try! solar2dBuildSystem.install()

    //
    // A project type which supports working with projects made in Solar2D
    //
    let solar2DProjectType: ProjectType = ProjectType(
        named: "Solar2D Project",
        icon: {Image(systemName: "sun.max")},
        recommendedBuildSystems: [solar2dBuildSystem],
        canSupportProjectAtURL: { rootFolder, allFilesAndFolders in
            return allFilesAndFolders.contains { (aFileOrFolder: URL) in
                return aFileOrFolder.lastPathComponent.lowercased() == "main.lua"
            }
        },
        priority: 2,
        projectFileViewersSupports: ["Project Files"]
    )
    try! solar2DProjectType.install()
    
    //
    // Some templates for creating new projects
    //
    let solar2DGameTemplateGroup: ProjectTemplateGroup = ProjectTemplateGroup(
        named: "Solar2D Game",
        projectTemplateSections: [
            .init(
                sectionName: "Solar2D Game",
                templates: [
                    .init(
                        name: "Hello World",
                        icon: iconForProjectTemplate(sfSymbol: "gamecontroller.fill"),
                        template: .init(
                            projectFolderSetup: .initNewRepository(
                                files: [
                                    .init(
                                        relativeFolderPath: "",
                                        fileName: "main.lua",
                                        contents: """
                                            --
                                            -- main.lua
                                            -- PROJECT_NAME
                                            --
                                            
                                            local myText = display.newText( "Hello World from PROJECT_NAME!", 100, 200, native.systemFont, 16 )
                                            myText:setFillColor( 1, 0, 0 )
                                            """.data(using: .utf8)!
                                    )
                                ]
                            ),
                            replaceStringWithUserGivenProjectName: .inAllFiles(
                                withExtensions: ["lua"],
                                stringToReplace: "PROJECT_NAME",
                                replacementTextConstraint: .alphanumericsWithUnderscoresAndDashesAndSpaces
                            )
                        )
                    )
                ]
            )
        ],
        associatedProjectType: solar2DProjectType
    )
    try! solar2DGameTemplateGroup.install()
    #endif
}

let solar2dScriptRunnerName: String = "Solar2D Project Runner"

//
// Solar2D Project Runner
//
private let solar2DRunner: AppMakerBuildProductRunner = AppMakerBuildProductRunner(
    named: solar2dScriptRunnerName,
    sandbox: .lookup(forName: "Simple Sandbox")!,
    implementation: Solar2DRunner.self
)

#if MAIN_APP
final class Solar2DBuildSystem: AppMakerBuildSystemImplementation {
    
    let entryPath: RawProjectFilePath
    let entryPathUrl: URL
    
    init(entryPath: RawProjectFilePath, projectRootFolderUrl: URL) {
        self.entryPath = entryPath
        self.entryPathUrl = entryPath.asLocalURL(withStartingUrl: projectRootFolderUrl)!
    }
    
    func buildProductsOnStartup() -> [(buildProductCreator: BuildProductCreator, recommendedRunnerName: String?)] {
        return [
            (
                buildProductCreator: .generatedHiddenFolderOfflineBuildProduct(
                    name: "main"
                ),
                recommendedRunnerName: solar2dScriptRunnerName
            )
        ]
    }
    
    
    
    func doBuild(for product: AnyBuildProduct) async -> Result<Void, Error> {
        let product = product as! GeneratedHiddenFolderOfflineBuildProduct
        try? FileManager.default.removeItem(at: product.buildProductPath)
        let coronaSourceFolder = self.entryPathUrl.deletingLastPathComponent()
        try? FileManager.default.createDirectory(at: product.buildProductPath.deletingLastPathComponent(), withIntermediateDirectories: true)
        let mainLuaFile: URL = product.buildProductPath.appendingPathComponent("main.lua")
        let configLuaFile: URL = product.buildProductPath.appendingPathComponent("config.lua")
        do {
            // copy all source file
            try FileManager.default.copyItem(
                at: coronaSourceFolder,
                to: product.buildProductPath
            )
            
            let configLuaInfo: ConfigLuaInfo
            if FileManager.default.fileExists(atPath: configLuaFile.path) {
                // read config.lua file
                func getConfigLuaInfo() throws -> ConfigLuaInfo {
                    let vm = LuaSwiftBindings.VirtualMachine()
                    _ = vm.eval(try String(contentsOf: configLuaFile))
                    return ConfigLuaInfo(globalTable: vm.globals)
                }
                configLuaInfo = try getConfigLuaInfo()
                
                // delete given config.lua file
                try FileManager.default.removeItem(at: configLuaFile)
                
                // put in fake config.lua file
                try """
                application =
                {
                    content =
                    {
                        scale = "adaptive",
                        fps = \(configLuaInfo.fps.rawValue),
                    }
                }
                """.write(to: configLuaFile, atomically: true, encoding: .utf8)
            } else {
                configLuaInfo = ConfigLuaInfo()
            }
            
            
            // rename main.lua and create fake main.lua to implement hooks and sandboxing
            try FileManager.default.moveItem(
                at: mainLuaFile,
                to: product.buildProductPath.appendingPathComponent("_original_main.lua")
            )
            
            // create fake main.lua
            try """
            -- encode config.lua information here
            local configLuaDetails = \(configLuaInfo.asLuaTableString)
            
            -- call this function to communicate with Solar2DSwiftUIViewDelegate
            local function sendToSwift(eventName, args)
                Runtime:dispatchEvent( { name="coronaView", eventName=eventName, args=args, isForAppMaker=true } )
            end
            
            -- send prints to App Maker console
            _G.print = function(...)
                local args = {...}
                local strings = {}
                for _, arg in ipairs(args) do
                    strings[#strings+1] = tostring(arg)
                end
                sendToSwift("print", strings)
            end
            
            -- flag ensures that App Maker successfully communicates essential information about
            -- where we are running before we continue into the actual main.lua code
            local establishedCommunicationWithHostAppMakerProcess = false
            
            -- save original CoronaCard content size values to the config table for App Maker to read
            configLuaDetails["original_actualContentWidth"] = display.actualContentWidth
            configLuaDetails["original_actualContentHeight"] = display.actualContentHeight
            
            -- fake display object
            local displayOverwrites = {}
            local oldDisplay = display
            display = {}
            setmetatable(display, {
                __index = function(table, key)
                    local result = displayOverwrites[key]
                    if result == nil then
                        return oldDisplay[key]
                    else
                        return result
                    end
                end,
            })
            
            -- App Maker will always communicate to the Solar2D CoronaCard view via this listener
            local function handleAppMaker( event )
                if ( event.eventName == "containingWindowNewSize" ) then
                    -- todo
                    -- local imageSuffix = event.imageSuffix
                    
                    -- standard solar2d screen size values
                    local actualContentWidth = event.actualContentWidth
                    local actualContentHeight = event.actualContentHeight
                    local contentWidth = event.contentWidth
                    local contentHeight = event.contentHeight
                    local contentScaleX = event.contentScaleX
                    local contentScaleY = event.contentScaleY
                    local pixelWidth = event.pixelWidth
                    local pixelHeight = event.pixelHeight
                    local topStatusBarContentHeight = event.topStatusBarContentHeight
                    local bottomStatusBarContentHeight = event.bottomStatusBarContentHeight
            
                    -- simplified representation of some screen properties
                    local insetT = event.insetT
                    local insetL = event.insetL
                    local insetB = event.insetB
                    local insetR = event.insetR
                                
                    -- derrived values
                    local contentCenterX = contentWidth * .5
                    local contentCenterY = contentHeight * .5
                    local screenOriginX = (contentWidth - actualContentWidth) * .5
                    local screenOriginY = (contentHeight - actualContentHeight) * .5
                    local safeActualContentWidth = actualContentWidth - insetL - insetR
                    local safeActualContentHeight = actualContentHeight - insetT - insetB
                    local safeScreenOriginX = screenOriginX + insetL
                    local safeScreenOriginY = screenOriginY + insetT
                    local statusBarHeight = topStatusBarContentHeight -- note, this might actually be slightly different from topStatusBarContentHeight, but it doesn't seem worth the time figuring out exactly what that difference is
                    local getSafeAreaInsets = function()
                        return insetT, insetL, insetB, insetR
                    end
                    local viewableContentWidth = math.min(contentWidth, actualContentWidth)
                    local viewableContentHeight = math.min(contentHeight, actualContentHeight)
            
                    -- hack the global stage display object to fix properly
                    local _hackOffsetX = event._hackOffsetX
                    local _hackOffsetY = event._hackOffsetY
                    local _hackScaleX = event._hackScaleX
                    local _hackScaleY = event._hackScaleY
            
                    -- override values in global display table
                    displayOverwrites.actualContentWidth = actualContentWidth
                    displayOverwrites.actualContentHeight = actualContentHeight
                    displayOverwrites.contentWidth = contentWidth
                    displayOverwrites.contentHeight = contentHeight
                    displayOverwrites.contentScaleX = contentScaleX
                    displayOverwrites.contentScaleY = contentScaleY
                    displayOverwrites.pixelWidth = pixelWidth
                    displayOverwrites.pixelHeight = pixelHeight
                    displayOverwrites.topStatusBarContentHeight = topStatusBarContentHeight
                    displayOverwrites.bottomStatusBarContentHeight = bottomStatusBarContentHeight
                    displayOverwrites.viewableContentWidth = viewableContentWidth
                    displayOverwrites.viewableContentHeight = viewableContentHeight
                    displayOverwrites.contentCenterX = contentCenterX
                    displayOverwrites.contentCenterY = contentCenterY
                    displayOverwrites.safeActualContentWidth = safeActualContentWidth
                    displayOverwrites.safeActualContentHeight = safeActualContentHeight
                    displayOverwrites.safeScreenOriginX = safeScreenOriginX
                    displayOverwrites.safeScreenOriginY = safeScreenOriginY
                    displayOverwrites.screenOriginX = screenOriginX
                    displayOverwrites.screenOriginY = screenOriginY
                    displayOverwrites.statusBarHeight = statusBarHeight
                    displayOverwrites.getSafeAreaInsets = getSafeAreaInsets
                    
                    -- apply hack to stage object
                    oldDisplay.currentStage.x = _hackOffsetX * _hackScaleX
                    oldDisplay.currentStage.y = _hackOffsetY * _hackScaleY
                    oldDisplay.currentStage.xScale = _hackScaleX
                    oldDisplay.currentStage.yScale = _hackScaleY
                    
                    if establishedCommunicationWithHostAppMakerProcess then
                        -- not the first time called, call the resize listener
                        Runtime:dispatchEvent( {name="resize"} )
                    else
                        -- first time called
                        establishedCommunicationWithHostAppMakerProcess = true
                    end
                end
            end
            Runtime:addEventListener( "appMaker", handleAppMaker )
            
            -- intercept addEventListener
            local oldAddEventListener = Runtime.addEventListener
            function Runtime.addEventListener(...)
                local args = {...}
                if #args > 1 then
                    local eventName = args[2]
                    if eventName == "accelerometer" then
                        -- the accelerometer is correctly broken for CoronaCards
                        -- https://forums.solar2d.com/t/gyroscope-and-accelerometer-not-working-on-ios/331006
                        print("⚠️: accelerometer does not work with CoronaCards")
                        return
                    end
                end
                return oldAddEventListener(unpack(args))
            end
            
            -- send embedded config lua details
            sendToSwift("configLuaDetails", configLuaDetails)
            
            -- actual main.lua
            if establishedCommunicationWithHostAppMakerProcess then
                local status, err = pcall(function() require("_original_main") end)
                if status == false then
                    sendToSwift("error", {message=tostring(err)})
                end
            else
                print("❌ failed to establish communication between Solar2D (CoronaCards) and App Maker IDE")
            end
            """.write(to: mainLuaFile, atomically: true, encoding: .utf8)
            
            // done
            return .success(Void())
        } catch {
            return .failure(error)
        }
    }
    
    
    #if DEBUG
    var isDestroyed = false
    #endif
    func destroy() async {
        #if DEBUG
        self.isDestroyed = true
        #endif
    }
    deinit {
        #if DEBUG
        precondition(isDestroyed)
        #endif
    }
}


struct ConfigLuaInfo {
    let width: Int?
    let height: Int?
    let scale: ScaleMode
    let fps: FPS
    
    // for when app is running
    let original_actualContentWidth: Double?
    let original_actualContentHeight: Double?
    
    var desiredSize: CGSize? {
        if let width = width, let height = height {
            return CGSize(width: width, height: height)
        }
        return nil
    }
    
    init() {
        self.scale = .none
        self.width = nil
        self.height = nil
        self.fps = ._30
        self.original_actualContentWidth = nil
        self.original_actualContentHeight = nil
    }
    init(globalTable: Table) {
        guard let application: Table = globalTable.get(key: "application"),
           let content: Table = application.get(key: "content") else {
            self = .init()
            return
        }
        self.width = content.get(key: "width")
        self.height = content.get(key: "height")
        if let scaleModeStr: String = content.get(key: "scale") {
            self.scale = .init(rawValue: scaleModeStr.lowercased()) ?? .none
        } else {
            self.scale = .none
        }
        if let fpsInt: Int = content.get(key: "fps") {
            self.fps = .init(rawValue: fpsInt) ?? ._30
        } else {
            self.fps = ._30
        }
        self.original_actualContentWidth = nil
        self.original_actualContentHeight = nil
    }
    init?(args: Dictionary<AnyHashable, Any>) {
        self.width = (args["width"] as? NSNumber)?.intValue
        self.height = (args["height"] as? NSNumber)?.intValue
        if let scaleModeStr: String = args["scale"] as? String {
            self.scale = .init(rawValue: scaleModeStr.lowercased()) ?? .none
        } else {
            self.scale = .none
        }
        if let fpsInt: NSNumber = args["fps"] as? NSNumber {
            self.fps = .init(rawValue: fpsInt.intValue) ?? ._30
        } else {
            self.fps = ._30
        }
        guard let original_actualContentWidth: Double = (args["original_actualContentWidth"] as? NSNumber)?.doubleValue,
              let original_actualContentHeight: Double = (args["original_actualContentHeight"] as? NSNumber)?.doubleValue else {
            return nil
        }
        self.original_actualContentWidth = original_actualContentWidth
        self.original_actualContentHeight = original_actualContentHeight
    }
    
    enum ScaleMode: String {
        case none = ""
        case zoomEven = "zoomeven"
        case zoomStretch = "zoomstretch"
        case letterbox = "letterbox"
        case adaptive = "adaptive"
    }
    
    enum FPS: Int {
        case _30 = 30
        case _60 = 60
    }
    
    var asLuaTableString: String {
        return """
        {
            width = \(self.width.asLuaCodeString),
            height = \(self.height.asLuaCodeString),
            fps = \(self.fps.rawValue.asLuaCodeString),
            scale = \(self.scale.rawValue.asLuaCodeString),
        }
        """
    }
}
#endif

