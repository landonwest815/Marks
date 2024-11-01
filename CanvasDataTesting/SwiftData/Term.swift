//
//  Term.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation
import SwiftData

@Model
class Term {
    @Attribute(.unique) var id: Int
    var name: String?
    var startAt: String?
    var endAt: String?
    
    @Relationship(deleteRule: .cascade, inverse: \Course.term)
    var courses: [Course] = []
    
    init(id: Int, name: String?, startAt: String? = nil, endAt: String? = nil) {
        self.id = id
        self.name = name
        self.startAt = startAt
        self.endAt = endAt
    }
    
    convenience init(item: TermDTO) {
        self.init(
            id: item.id,
            name: item.name,
            startAt: item.startAt,
            endAt: item.endAt
        )
    }
}
