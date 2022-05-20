//
//  MarkdownPreviewer.swift
//

import Foundation
import AppMakerCore
import MarkdownUI
import SwiftUI

func markdownpreviewer_main() {
    // A basic markdown file previewer
    let markdownFilePreviewer: ContentPreviewer = ContentPreviewer(
        named: "Markdown File Previewer",
        shortName: "Markdown",
        basePriority: 1,
        shouldMakePreview: { validContent, contentId in
            if let validFileInfo = validContent as? ProjectFileInfoContent.ValidContent {
                guard validFileInfo.fileType.isString else {
                    return .shouldNotMakePreview
                }
                if validFileInfo.fileExtension?.lowercased() == "md" {
                    return .shouldMakePreview
                } else if validFileInfo.fullName.lowercased().contains("readme") {
                    return .shouldMakePreview
                } else {
                    return .shouldNotMakePreview
                }
            } else if validContent is ProjectDirectoryContent.ValidContent {
                return .shouldNotMakePreview
            }
            if let raw = contentId as? AnyRawProjectContentID {
                switch raw.path {
                case .root:
                    return .shouldNotMakePreview
                case .sub(_, let name):
                    let lowerName = name.lowercased()
                    if lowerName.contains("readme") {
                        return .shouldMakePreview
                    }
                    let split = lowerName.split(separator: ".")
                    if split.last?.lowercased() == "md" {
                        return .shouldMakePreview
                    } else {
                        return .notSure
                    }
                }
            } else {
                return .notSure
            }
        },
        makePreview: { (liveProjectContent: LiveReadableProjectContent<ProjectFileUTF8StringContent>) in
            switch liveProjectContent.state {
            case .valid(let text):
                guard let document: Document = try? Document(markdown: text.rawUTF8String, options: .smart) else {
                    // failed to create the markdown ui document
                    return .cantRenderAPreview
                }
                let handler: MarkdownImageHandler = .customLocalImage { url in
                    return UIImage(systemName: "questionmark.diamond")!.pngData()!
                }
                return .renderPreview {
                    Markdown(document)
                        .setImageHandler(handler, forURLScheme: "")
                        .setImageHandler(handler, forURLScheme: ":unknown_scheme:")
                        .padding()
                }
            case .invalid:
                return .cantRenderAPreview
            }
        }
    )
    markdownFilePreviewer.licenseInformation = [
        "MarkdownUI (c) Guillermo Gonzalez contributors, MIT license" // https://github.com/gonzalezreal/MarkdownUI/blob/main/LICENSE
    ]
    try! markdownFilePreviewer.install()
}
