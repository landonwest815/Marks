//
//  PhotoDTO.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//

//  PhotoDTO.swift
import Foundation
import SwiftUI

struct CourseDTO: Identifiable, Decodable {
    let id: Int
    let name: String?
    let accountId: Int?
    let uuid: String?
    let courseCode: String?
    let enrollmentTermId: Int?
    let term: TermDTO?
}
