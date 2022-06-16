//
//  FireflyProjectTextSyncableDelegate.swift
//

import Foundation
import AppMakerCore
import Firefly

final class FireflyProjectTextSyncableDelegate: ProjectTextSyncable {
    
    let projectSyncedText: ProjectSyncedText
    let fireflySyntaxView: FireflySyntaxView
    
    @MainActor
    init(
        projectSyncedText: ProjectSyncedText,
        startText: String,
        wrapped: (
            fireflySyntaxView: FireflySyntaxView,
            sidebarConfiguration: FireflyEditorSidebarConfiguration
        )
    ) {
        self.projectSyncedText = projectSyncedText
        self.fireflySyntaxView = wrapped.fireflySyntaxView
        wrapped.fireflySyntaxView.text = startText
        wrapped.fireflySyntaxView.setOnTextChange { [weak projectSyncedText] oldText, location, newText in
            if let projectSyncedText = projectSyncedText {
                projectSyncedText.willReplace(oldText, at: location, to: newText)
            }
        }
    }
    
    @MainActor
    func handleForeignTextReplacement(in range: NSRange, to newText: String) {
        self.fireflySyntaxView.replace(range: range, to: newText)
    }
    
    @MainActor
    func handleForeignFullDocumentOverwrite(wholeDocumentNewText: String) {
        self.fireflySyntaxView.text = wholeDocumentNewText
    }
}
