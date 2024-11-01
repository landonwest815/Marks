//
//  Assignment.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation
import SwiftData

@Model
class Assignment {
    @Attribute(.unique) var id: Int
    var name: String?
    var assignmentDescription: String?
    var dueAt: String?
    var pointsPossible: Double?
    var uuid: String?
    
    //@Relationship(deleteRule: .cascade, inverse: \Submission.assignment) var submissions: [Submission]?
    var assignmentGroup: AssignmentGroup?
    
    init(id: Int, name: String?, assignmentDescription: String? = nil, dueAt: String? = nil, pointsPossible: Double? = 20.0, uuid: String? = nil) {
        self.id = id
        self.name = name
        self.assignmentDescription = assignmentDescription
        self.dueAt = dueAt
        self.pointsPossible = pointsPossible
        self.uuid = uuid
    }
    
    convenience init(item: AssignmentDTO) {
        self.init(
            id: item.id,
            name: item.name,
            assignmentDescription: item.assignmentDescription,
            dueAt: item.dueAt,
            pointsPossible: item.pointsPossible,
            uuid: item.uuid
        )
    }
}
