//
//  PhotoObject.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

//  PhotoObject.swift
import Foundation
import SwiftData

@Model
class Course {
    @Attribute(.unique) var id: Int
    var name: String?
    var accountId: Int?
    var uuid: String?
    var courseCode: String?
    var enrollmentTermId: Int?
    
    @Relationship(deleteRule: .cascade, inverse: \AssignmentGroup.course)
    var assignmentGroups: [AssignmentGroup] = []
    
    var term: Term?
    
    init(id: Int, name: String?, accountId: Int? = nil, uuid: String? = nil, courseCode: String? = nil, enrollmentTermId: Int? = nil) {
        self.id = id
        self.name = name
        self.accountId = accountId
        self.uuid = uuid
        self.courseCode = courseCode
        self.enrollmentTermId = enrollmentTermId
    }
    
    convenience init(item: CourseDTO) {
        self.init(
            id: item.id,
            name: item.name,
            accountId: item.accountId,
            uuid: item.uuid,
            courseCode: item.courseCode,
            enrollmentTermId: item.enrollmentTermId
        )
    }
}
