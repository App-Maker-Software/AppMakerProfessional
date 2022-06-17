//
//  FireflyEditorSidebarConfiguration.swift
//

import Foundation
import SwiftUI
import AppMakerCore
import Firefly


internal final class FireflyEditorSidebarConfiguration: ObservableObject {
    
    @Published internal private(set) var showLineNumbers: Bool = true
    @Published internal private(set) var autoGutter: Bool = true
    @Published internal private(set) var gutterWidth: CGFloat = 20.0
    @Published internal private(set) var language: (key: String, displayName: String)?
    @Published internal private(set) var lightTheme: String = "Xcode Light"
    @Published internal private(set) var darkTheme: String = "Xcode Dark"
    
    var autoFlushDebounceNanoseconds: UInt64 {
        get {
            projectSyncedText.autoFlushDebounceNanoseconds
        }
        set {
            projectSyncedText.autoFlushDebounceNanoseconds = newValue
        }
    }
    
    let projectSyncedText: ProjectSyncedText
    
    init(projectSyncedText: ProjectSyncedText, desiredLanguageKey: String) {
        self.projectSyncedText = projectSyncedText
        if let first = Firefly.fireflyLanguages.first(where: {$0.key == desiredLanguageKey}),
           let displayName: String = first.value["display_name"] as? String {
            self.language = (first.key, displayName)
        } else if let first = Firefly.fireflyLanguages.first(where: {$0.key == "default"}),
                  let displayName: String = first.value["display_name"] as? String {
            self.language = (first.key, displayName)
       } else {
            self.language = nil
        }
    }
    
    func makeView() -> AnyView {
        AnyView(SidebarView(config: self))
    }
    
    private struct SidebarView: View {
        @Environment(\.colorScheme) var colorScheme: ColorScheme
        @ObservedObject var config: FireflyEditorSidebarConfiguration
        
        var body: some View {
            List {
                Section("Appearance") {
                    Toggle("Show Line Numbers", isOn: $config.showLineNumbers)
                    if config.showLineNumbers {
                        Toggle("Auto Gutter", isOn: $config.autoGutter)
                        if !config.autoGutter {
                            HStack {
                                Text("Gutter Width")
                                Slider(value: $config.gutterWidth, in: 10...40)
                            }
                        }
                    }
                    switch self.colorScheme {
                    case .light :
                        HStack {
                            Text("Light Theme")
                            Menu {
                                let keys: [String] = fireflyThemes.keys.map({$0})
                                ForEach(0..<keys.count) { (i: Int) in
                                    let key = keys[i]
                                    Button(key) {
                                        self.config.lightTheme = key
                                    }
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(config.lightTheme)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    default:
                        HStack {
                            Text("Dark Theme")
                            Menu {
                                let keys: [String] = fireflyThemes.keys.map({$0})
                                ForEach(0..<keys.count) { (i: Int) in
                                    let key = keys[i]
                                    Button(key) {
                                        self.config.darkTheme = key
                                    }
                                }
                            } label: {
                                HStack {
                                    Spacer()
                                    Text(self.config.darkTheme)
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                }
                Section("Syntax Highlighting") {
                    HStack {
                        Text("Language")
                        Menu {
                            let keys: [String] = fireflyLanguages.keys.map({$0})
                            ForEach(0..<keys.count) { (i: Int) in
                                let key = keys[i]
                                if let displayName: String = fireflyLanguages[key]?["display_name"] as? String {
                                    Button(displayName) {
                                        self.config.language = (key, displayName)
                                    }
                                }
                            }
                        } label: {
                            HStack {
                                Spacer()
                                Text(config.language?.displayName ?? "None")
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                }
                Section("Behavior") {
                    HStack {
                        Text("Flush Debounce")
                        Slider(
                            value: Binding<Float>.init(get: {
                                Float(config.autoFlushDebounceNanoseconds / 1_000_000)
                            }, set: { float in
                                config.autoFlushDebounceNanoseconds = UInt64(float) * 1_000_000
                            }),
                            in: 0...1_000,
                            step: 1
                        )
                    }
                }
            }.listStyle(InsetGroupedListStyle())
        }
    }
}
