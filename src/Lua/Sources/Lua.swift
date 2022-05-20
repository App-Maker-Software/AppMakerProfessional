//
//  Lua.swift
//

import Foundation
#if MAIN_APP
import AppMakerCore
#elseif COMPANION
import AppMakerCompanionCore
#endif
import SwiftUI
import LuaSwiftBindings


func luaplugin_main() {
    // Install sandbox and runner
    luaScriptRunner.licenseInformation = [
        "lua-sandbox (c) Enrique García Cota, MIT license" // https://github.com/kikito/lua-sandbox
    ]
    try! luaScriptRunner.install()

    #if MAIN_APP
    //
    // Lua Script Build System
    //
    let luaScriptBuildSystem: AppMakerBuildSystem = AppMakerBuildSystem(
        named: "Lua Build System",
        icon: {
            Image(systemName: "moon.fill")
        },
        validateEntryPath: { rawPath in
            let msg = "Entry path must be file ending with \".lua\""
            switch rawPath {
            case .sub(_, let name):
                return name.lowercased().hasSuffix(".lua") ? .valid : .invalid(reasonToTellUser: msg)
            case .root:
                return .invalid(reasonToTellUser: msg)
            @unknown default:
                return .invalid(reasonToTellUser: msg)
            }
        },
        validateEntryPathUserMessage: "Select any file ending with \".lua\"",
        implementation: LuaBuildSystem.self
    )
    luaScriptBuildSystem.licenseInformation = [
        "Lua, PUC-Rio, MIT license" // https://www.lua.org/license.html
    ]
    try! luaScriptBuildSystem.install()
    
    //
    // A project type which supports working with projects made in Lua
    //
    let luaProjectType: ProjectType = ProjectType(
        named: "Lua Project",
        infoURL: nil,
        icon: {
            Image(systemName: "moon.fill")
        },
        recommendedBuildSystems: [luaScriptBuildSystem],
        canSupportProjectAtURL: { rootFolder, allFilesAndFolders in
            return allFilesAndFolders.contains { (aFileOrFolder: URL) in
                return aFileOrFolder.lastPathComponent.lowercased().hasSuffix(".lua")
            }
        },
        priority: 1,
        projectFileViewersSupports: ["Project Files"]
    )
    try! luaProjectType.install()
    
    //
    // Some templates for creating new projects and files
    //
    let luaTemplateGroup: ProjectTemplateGroup = ProjectTemplateGroup(
        named: "Lua Script",
        projectTemplateSections: [
            .init(
                sectionName: "Lua Script",
                templates: [
                    .init(
                        name: "Hello World",
                        icon: iconForProjectTemplate(sfSymbol: "moon.fill"),
                        template: .init(
                            projectFolderSetup: .initNewRepository(
                                files: [
                                    .init(
                                        relativeFolderPath: "",
                                        fileName: "hello.lua",
                                        contents: """
                                            --
                                            -- hello.lua
                                            -- PROJECT_NAME
                                            --
                                            
                                            print("Hello, world!")
                                            """
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
        associatedProjectType: luaProjectType
    )
    try! luaTemplateGroup.install()
    
    
    
    // Adds the ability to create a completely empty files
    let luaFileTemplateGroup: FileTemplateGroup = FileTemplateGroup(
        named: "Lua",
        fileTemplateSections: [
            .init(
                sectionName: "Lua",
                templates: [
                    .init(
                        name: "Lua file",
                        icon: iconForProjectTemplate(sfSymbol:"moon.fill"),
                        template: .init(
                            fileContents: """
                                --
                                -- FILE_NAME
                                -- PROJECT
                                --
                                -- Created by USER on DATE
                                --
                                
                                print("Hello, world!")
                                """,
                            stringReplacements: [
                                .fileName(keyToReplace: "FILE_NAME"),
                                .currentDate(keyToReplace: "DATE"),
                                .localUserName(keyToReplace: "USER"),
                                .projectName(keyToReplace: "PROJECT"),
                            ]
                        ),
                        forcedExtension: "lua"
                    )
                ]
            )
        ],
        associatedProjectTypes: [luaProjectType]
    )
    try! luaFileTemplateGroup.install()
    
    #endif
}

let luaScriptRunnerName: String = "Lua Script Runner"


//
// Lua Script Runner
//
private let luaScriptRunner: AppMakerBuildProductRunner = AppMakerBuildProductRunner(
    named: luaScriptRunnerName,
    sandbox: .lookup(forName: "Simple Sandbox")!,
    implementation: LuaScriptRunner.self
)

#if MAIN_APP
final class LuaBuildSystem: AppMakerBuildSystemImplementation {
    
    let entryPath: RawProjectFilePath
    
    init(entryPath: RawProjectFilePath) {
        self.entryPath = entryPath
    }
    
    func buildProductsOnStartup() -> [(buildProductCreator: BuildProductCreator, recommendedRunnerName: String?)] {
        return [
            (
                buildProductCreator: .simpleOfflineBuildProduct(
                    name: "main",
                    path: entryPath
                ),
                recommendedRunnerName: luaScriptRunnerName
            )
        ]
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
#endif

