//
//  Config.swift
//  CanvasDataTesting
//
//  Created by Landon West on 4/16/25.
//

import Foundation

struct Config {
    static var apiKey: String {
        // Attempt to retrieve the API key from Info.plist.
        guard let key = Bundle.main.object(forInfoDictionaryKey: "API_KEY") as? String, !key.isEmpty else {
            fatalError("API_KEY must be set in Info.plist")
        }
        return key
    }
}
