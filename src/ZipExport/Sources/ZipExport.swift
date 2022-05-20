//
//  ZipExport.swift
//

import Foundation
import AppMakerCore
import Zip
import SwiftUI

func zipexport_main() {
    let zipExport = ProjectExportOption(
        named: "Zip Export",
        infoURL: "https://github.com/marmelroy/Zip",
        cellTitle: "Export as ZIP",
        cellIcon: {
            Image(systemName: "doc.zipper")
        },
        onExportRequest: { url, progressCallback in
            do {
                let destURL: URL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent).appendingPathExtension("zip")
                try Zip.zipFiles(paths: [url], zipFilePath: destURL, password: nil, progress: progressCallback)
                return .success(destURL)
            } catch let error {
                return .failure(error)
            }
        }
    )
    try! zipExport.install()
}
