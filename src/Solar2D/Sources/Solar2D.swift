//
//  Solar2D.swift
//

import Foundation
#if MAIN_APP
import AppMakerCore
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
        priority: 1,
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
                                            //
                                            // main.lua
                                            // PROJECT_NAME
                                            //
                                            
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
                recommendedRunnerName: solar2dScriptRunnerName
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

