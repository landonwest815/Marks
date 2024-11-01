//
//  TermDTO.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation

struct TermDTO: Identifiable, Codable {
    let id: Int
    let name: String?
    let startAt: String?
    let endAt: String?
}
