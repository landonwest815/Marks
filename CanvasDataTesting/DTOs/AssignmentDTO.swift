//
//  AssignmentDTO.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation

struct AssignmentDTO: Identifiable, Codable {
    let id: Int
    let name: String?
    let assignmentDescription: String?
    let dueAt: String?
    let pointsPossible: Double?
    let uuid: String?
    let assignment_group_id: Int?
}
