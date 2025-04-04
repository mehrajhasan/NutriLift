//
//  ExerciseEntry.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/25/25.
//

import SwiftUI
import Foundation

/*
 Notes: Might have to find alternative to UUID can make Sql slower as it unbalances B tree
 */

struct SetEntry: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var weight: String
    var reps: String
}

struct ExerciseEntry: Codable, Identifiable {
    var id: String = UUID().uuidString
    var name: String
    var sets: [SetEntry] = []
}

struct RoutinePayload: Codable {
    let title: String
    let user_id: Int
    let exercises: [ExerciseEntry]
}

struct Routine: Codable, Identifiable {
    let id: Int
    let title: String
    let exercises: [ExerciseEntry]
    let created_at: String?
    let user_id: Int
}


struct Exercise: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let equipment: String?
}
