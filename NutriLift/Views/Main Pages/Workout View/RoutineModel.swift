//
//  RoutineModel.swift
//  NutriLift
//
//  Created by Jairo Iqbal Gil on 3/16/25.
//
import SwiftUI
import Foundation


struct Routine: Identifiable, Codable {
    let id = UUID()
    let title: String
    let exercises: [String]
}

struct Exercise: Codable, Identifiable {
    let id: Int
    let name: String
    let category: String
    let equipment: String?
}
