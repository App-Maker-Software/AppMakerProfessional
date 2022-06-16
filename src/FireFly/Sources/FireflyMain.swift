//
//  FireflyMain.swift
//

import AppMakerCore
import Combine
import SwiftUI

public func firefly_main() {
    // install extra languages to be supported in the Firefly editor
    installExtraLanguages()
    
    // created the App Maker editor for Firefly
    let fireflyEditor: AppMakerEditor = AppMakerEditor(
        named: "Firefly Editor",
        basePriority: 0,
        canMakeEditor: { validContent in
            if let validFileInfo = validContent as? ProjectFileInfoContent.ValidContent {
                return validFileInfo.fileType.isString ? .canMakeEditor : .cannotMakeEditor
            } else if validContent is ProjectDirectoryContent.ValidContent {
                return .cannotMakeEditor
            }
            return .notSure
        },
        editorInstanceType: FireflyEditor.self
    )
    try! fireflyEditor.install()
}







