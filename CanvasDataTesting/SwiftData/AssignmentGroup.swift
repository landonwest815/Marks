//
//  AssignmentGroup.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation
import SwiftData

@Model
class AssignmentGroup {
    @Attribute(.unique) var id: Int
    var name: String?
    var weight: Double?
    
    @Relationship(deleteRule: .cascade, inverse: \Assignment.assignmentGroup)
    var assignments: [Assignment] = []
    var course: Course?
    
    init(id: Int, name: String?, weight: Double?) {
        self.id = id
        self.name = name
        self.weight = weight
    }
    
    convenience init(item: AssignmentGroupDTO) {
        self.init(
            id: item.id,
            name: item.name,
            weight: item.weight
        )
    }
}
