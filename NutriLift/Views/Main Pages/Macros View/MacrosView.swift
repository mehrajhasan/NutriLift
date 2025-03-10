//
//  MacrosView.swift
//  NutriLift
//
//  Created by Mohammad Hossain on 3/8/25.
//

import SwiftUI

struct MacrosView: View {
    @State private var selectedDate = Date()

    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                Text("Macronutrients")
                    .font(.largeTitle)
                    .bold()
                Spacer()
                Button(action: { /* Open menu */ }) {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(.black)
                        .font(.title)
                }
            }
            .padding()
            
            // View Summary Button
            Button(action: { /* View summary action */ }) {
                Text("View Summary")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            // Date Navigation
            HStack {
                Button(action: { /* Go to previous day */ }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
                
                Text(dateFormatter.string(from: selectedDate))
                    .font(.headline)
                    .padding(.horizontal)
                
                Button(action: { /* Go to next day */ }) {
                    Image(systemName: "chevron.right")
                        .foregroundColor(.black)
                }
            }
            .padding()
            
            // Scrollable Meal Sections
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    MealSectionView(mealType: "Breakfast")
                    MealSectionView(mealType: "Lunch")
                    MealSectionView(mealType: "Dinner")
                }
                .padding()
            }

            Spacer()
        }
        .navigationTitle("Daily Macros Page")
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
}

// Meal Section Component
struct MealSectionView: View {
    var mealType: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(mealType)
                .font(.title2)
                .bold()
                .foregroundColor(.black)
            
            Text("No meals added yet")
                .foregroundColor(.gray)
                .italic()
            
            Button(action: { /* Add meal action */ }) {
                Text("Add Meal")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.2))
        .cornerRadius(10)
    }
}

#Preview {
    TaskBarView()
}
