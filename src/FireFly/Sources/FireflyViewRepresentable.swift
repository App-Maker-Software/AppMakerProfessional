//
//  FireflyViewRepresentable.swift
//

import Foundation
import Firefly
import AppMakerCore
import SwiftUI

@MainActor
struct FireflyViewRepresentable: ViewRepresentable, AppMakerEditorInstanceMainBody {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    
    @MainActor @ObservedObject var editorInstance: FireflyEditor
    @MainActor @ObservedObject var config: FireflyEditorSidebarConfiguration
    
    #if canImport(UIKit)
    @MainActor
    func makeUIView(context: Context) -> FireflySyntaxView {
        return self.editorInstance.fireflyProjectTextSyncableDelegate.fireflySyntaxView
    }
    @MainActor
    func updateUIView(_ uiView: FireflySyntaxView, context: Context) {
        self.updateView(uiView, context: context)
    }
    #elseif canImport(AppKit)
    @MainActor
    func makeNSView(context: Context) -> FireflySyntaxView {
        return self.editorInstance.projectTextSyncableFireflyDelegate.fireflySyntaxView
    }
    @MainActor
    func updateNSView(_ nsView: FireflySyntaxView, context: Context) {
        self.updateView(nsView, context: context)
    }
    #endif
    @MainActor
    private func updateView(_ view: FireflySyntaxView, context: Context) {
        if config.showLineNumbers {
            if config.autoGutter != view.dynamicGutterWidth {
                view.setDynamicGutter(enabled: config.autoGutter)
            }
            if !config.autoGutter {
                if config.gutterWidth != view.gutterWidth {
                    view.setGutterWidth(width: config.gutterWidth)
                }
            }
        }
        if config.showLineNumbers != view.showLineNumbers {
            view.setGutterWidth(width: config.gutterWidth)
            view.setLineNumbers(visible: config.showLineNumbers)
        }
        let configLanguageKey: String = config.language?.key ?? ""
        if configLanguageKey != view.language {
            view.setLanguage(language: configLanguageKey)
        }
        switch colorScheme {
        case .light:
            if config.lightTheme != view.theme {
                view.setTheme(name: config.lightTheme)
            }
        default:
            if config.darkTheme != view.theme {
                view.setTheme(name: config.darkTheme)
            }
        }
    }
}


