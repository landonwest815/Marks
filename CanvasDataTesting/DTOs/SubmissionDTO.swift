//
//  SubmissionDTO.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

import Foundation

struct SubmissionDTO: Identifiable, Codable {
    let id: Int
    let enteredGrade: String?
    let enteredScore: Double?
    let gradedAt: String?
    let submittedAt: String?
}
