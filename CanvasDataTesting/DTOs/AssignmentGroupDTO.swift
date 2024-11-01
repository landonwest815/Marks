//
//  AssignmentGroupDTO.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation

struct AssignmentGroupDTO: Identifiable, Codable {
    let id: Int
    let name: String?
    let weight: Double?
}
