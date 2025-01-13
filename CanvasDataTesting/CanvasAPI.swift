//
//  NetworkError.swift
//  CanvasDataTesting
//
//  Created by Landon West on 10/30/24.
//


//  WebService.swift
import Foundation
import SwiftData

enum NetworkError: Error {
    case badUrl
    case invalidRequest
    case badResponse
    case badStatus
    case failedToDecodeResponse
}

class CanvasAPI {
    var token: String
    
    init(token: String) {
        self.token = token
    }
    
    func fetchCourses() async throws -> [CourseDTO] {
        // Canvas API endpoint for listing courses
        guard let url = URL(string: "https://slcc.instructure.com/api/v1/courses?include[]=term&per_page=50") else {
            throw URLError(.badURL)
        }
        
        // Create the request and add authorization header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Perform the network request
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Print raw data as a string to see what's fetched
        if let responseString = String(data: data, encoding: .utf8) {
            //print("Fetched Data: \(responseString)")
        }
        
        // Decode the response data
        let courses = try JSONDecoder().decode([CourseDTO].self, from: data)
        return courses
    }
    
    func fetchGroups(courseId: Int) async throws -> [AssignmentGroupDTO] {
        // Canvas API endpoint for listing groups
        guard let url = URL(string: "https://utah.instructure.com/api/v1/courses/\(courseId)/assignment_groups?per_page=20") else {
            throw URLError(.badURL)
        }
        
        // Create the request and add authorization header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Perform the network request
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Print raw data as a string to see what's fetched
        if let responseString = String(data: data, encoding: .utf8) {
            //print("Fetched Data: \(responseString)")
        }
        
        // Decode the response data
        let groups = try JSONDecoder().decode([AssignmentGroupDTO].self, from: data)
        return groups
    }
    
    func fetchAssignments(courseId: Int) async throws -> [AssignmentDTO] {
        // Canvas API endpoint for listing groups
        guard let url = URL(string: "https://utah.instructure.com/api/v1/courses/\(courseId)/assignments?per_page=100") else {
            throw URLError(.badURL)
        }
        
        // Create the request and add authorization header
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        // Perform the network request
        let (data, _) = try await URLSession.shared.data(for: request)
        
        // Print raw data as a string to see what's fetched
        if let responseString = String(data: data, encoding: .utf8) {
            //print("Fetched Data: \(responseString)")
        }
        
        // Decode the response data
        let assignments = try JSONDecoder().decode([AssignmentDTO].self, from: data)
        return assignments
    }
    
    
    
}
