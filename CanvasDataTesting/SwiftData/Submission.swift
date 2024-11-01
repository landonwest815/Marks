//
//  Submission.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation
import SwiftData

@Model
class Submission {
    @Attribute(.unique) var id: Int
    var enteredGrade: String?
    var enteredScore: Double?
    var gradedAt: String?
    var submittedAt: String?
    
    var assignment: Assignment?
    
    init(id: Int, enteredGrade: String? = nil, enteredScore: Double? = nil, gradedAt: String? = nil, submittedAt: String? = nil) {
        self.id = id
        self.enteredGrade = enteredGrade
        self.enteredScore = enteredScore
        self.gradedAt = gradedAt
        self.submittedAt = submittedAt
    }
    
    convenience init(item: SubmissionDTO) {
        self.init(
            id: item.id,
            enteredGrade: item.enteredGrade,
            enteredScore: item.enteredScore,
            gradedAt: item.gradedAt,
            submittedAt: item.submittedAt
        )
    }
}
