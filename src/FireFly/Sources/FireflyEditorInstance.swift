//
//  FireflyEditorInstance.swift
//

import Foundation
import AppMakerCore
import SwiftUI
import Firefly

/// The App Maker editor instance implementation for the Firefly editor.
final class FireflyEditor: AppMakerEditorInstance, ObservableObject {
    
    typealias Content = ProjectFileUTF8StringContent
    typealias EditorViewBody = FireflyViewRepresentable
    
    let id: UUID = UUID()
    let debugAreaTopBarInfo: DebugAreaTopBarInfo = .init()
    
    let liveProjectContent: LiveWritableProjectContent<ProjectFileUTF8StringContent>
    let context: AppMakerEditorInstanceContext<FireflyEditor>
    let sidebarConfiguration: FireflyEditorSidebarConfiguration
    let fireflyProjectTextSyncableDelegate: FireflyProjectTextSyncableDelegate
    
    static func rightSidebarOptions() -> [RightSidebarOption<FireflyEditor>] {
        return [
            RightSidebarOption<FireflyEditor>(
                shortName: "Firefly",
                name: "Firefly Editor",
                render: { (editor: FireflyEditor) in
                    return .valid(
                        editor.sidebarConfiguration.makeView(),
                        autoWrapInScrollView: false
                    )
                }
            )
        ]
    }
    
    static var editorIcon: Image {
        Image(systemName: "doc.plaintext.fill")
    }
    
    func getName() -> String {
        self.liveProjectContent.projectContentId.path.asRelativePath
    }
    
    @MainActor
    func makeMainBodyView() -> FireflyViewRepresentable {
        FireflyViewRepresentable(
            editorInstance: self,
            config: self.sidebarConfiguration
        )
    }
    
    @MainActor
    init?(
        liveProjectContent: LiveWritableProjectContent<ProjectFileUTF8StringContent>,
        context: AppMakerEditorInstanceContext<FireflyEditor>
    ) async {
        self.context = context
        self.liveProjectContent = liveProjectContent
        let projectSyncedText = ProjectSyncedText(
            liveWritableString: liveProjectContent,
            autoFlushDebounceNanoseconds: 0
        )
        self.sidebarConfiguration = .init(
            projectSyncedText: projectSyncedText,
            desiredLanguageKey: liveProjectContent.projectContentId.path.fileExtension.lowercased()
        )
        let fireflyView = FireflyViewRepresentable.UIViewType()
        self.fireflyProjectTextSyncableDelegate = projectSyncedText.open(
            with: (
                fireflyView,
                self.sidebarConfiguration
            )
        )
        fireflyView.setOnSelectionChange { [weak self] (selectionRange: NSRange) in
            if let self = self {
                let newValue: String
                let dist = selectionRange.length
                if dist == 0 {
                    newValue = ""
                } else if dist == 1 {
                    newValue = "1 character"
                } else {
                    newValue = "\(dist) characters"
                }
                if newValue != self.debugAreaTopBarInfo.text {
                    self.debugAreaTopBarInfo.text = newValue
                }
            }
        }
    }
    
    var isDestroyed: Bool = false
    func destroy() async {
        self.isDestroyed = true
        Task.init(priority: .background) {
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            await self.fireflyProjectTextSyncableDelegate.projectSyncedText.destroy()
            await self.liveProjectContent.destroy()
        }
    }
}
