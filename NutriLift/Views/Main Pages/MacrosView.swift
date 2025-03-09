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
            
            Button(action: { /* View summary action */ }) {
                Text("View Summary")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
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
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    MealSectionView(mealType: "Breakfast")
                    MealSectionView(mealType: "Lunch")
                    MealSectionView(mealType: "Dinner")
                }
                .padding()
            }
            
            Spacer()
            
            HStack {
                Spacer()
                Image(systemName: "chart.pie.fill")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "dumbbell.fill")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "chart.bar.fill")
                    .font(.largeTitle)
                Spacer()
                Image(systemName: "person.crop.circle.fill")
                    .font(.largeTitle)
                Spacer()
            }
            .padding()
            .background(Color.gray.opacity(0.2))
        }
        .navigationTitle("Daily Macros Page")
    }
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
}

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
    MacrosView()
}
