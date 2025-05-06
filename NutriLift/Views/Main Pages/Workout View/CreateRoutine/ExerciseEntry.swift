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
 
 Used for Create Routine Feature
 */

// holds data for one set in a workout
struct SetEntry: Codable, Identifiable, Equatable {
    var id: String = UUID().uuidString
    var weight: String
    var reps: String
}


// holds a full exercise and its list of sets
struct ExerciseEntry: Identifiable, Codable {
    var id: String // unique id for the exercise entry
    var name: String
    var sets: [SetEntry]

    // turns the exercise into a dictionary format for saving or sending
    func ExFormat() -> [String: Any] {
        return [
            "id": id,
            "name": name,
            "sets": sets.map { [
                "id": $0.id,
                "weight": $0.weight,
                "reps": $0.reps
            ]}
        ]
    }
}


// used to send a new routine to the server
struct RoutinePayload: Codable {
    let title: String
    let user_id: Int
    let exercises: [ExerciseEntry]
}


// represents the routine stored in the database
struct Routine: Codable, Identifiable{
    let id: Int
    let title: String
    let exercises: [ExerciseEntry]
    let created_at: String?
    let user_id: Int
}

// basic exercise info pulled from the database
struct Exercise: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let equipment: String?
}



