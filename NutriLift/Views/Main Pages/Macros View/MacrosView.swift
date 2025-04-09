import SwiftUI

struct MacrosView: View {
    @AppStorage("userId") var userID: Int = 0 //changed user_id to userID as thats what was used in loginview. Maybe that is current issue with userid constantly storing on user id 30? As notes by Jairo: when a user logs in, we set the primary key (user_id) into a foreign key (userID) that other tables on db use. So contacting primary key won't work
    @State private var selectedDate = Date()
    @State private var savedMeals: [LoggedMeal] = []
    
    var mealsForSelectedDate: [LoggedMeal] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let selectedDateString = formatter.string(from: selectedDate)
        
        return savedMeals.filter { meal in
            return meal.created_at.starts(with: selectedDateString)
        }
    }

    var body: some View {
        NavigationView {  // Wrap everything in NavigationView
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
                NavigationLink(destination: SummaryView(selectedDate: selectedDate, savedMeals: mealsForSelectedDate)) {
                    Text("View Summary")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                // Date Navigation
                // Date Navigation with optional calendar picker
                VStack {
                    HStack {
                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate //toggle backwards date
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.black)
                        }

                        Text(dateFormatter.string(from: selectedDate))
                            .font(.headline)
                            .padding(.horizontal)

                        Button(action: {
                            selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate //toggle forward date
                        }) {
                            Image(systemName: "chevron.right")
                                .foregroundColor(.black)
                        }
                    }
                    .padding(.bottom, 4)

                    // DatePicker
                    DatePicker("",  //allow user to choose which date to go to
                               selection: $selectedDate,
                               displayedComponents: [.date])
                        .datePickerStyle(.compact)
                        .labelsHidden()
                        .padding(.horizontal)
                }
                .padding()
                
                ScrollView {
                    mealSections
                        .padding()
                }
                //COMMENTING THIS PART OUT BECAUSE CODE NEEDS TO BE BROKEN UP INTO SMALLER PARTS. PRIOR ERROR:
                //"The compiler is unable to type-check this expression in reasonable time; try breaking up the expression into distinct sub-expressions"
                /*:
                // Scrollable Meal Sections
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        ForEach(["Breakfast", "Lunch", "Dinner"], id: \.self) { type in
                            MealSectionView(
                                mealType: type,
                                meals: mealsForSelectedDate.filter { $0.meal_type == type },
                                selectedDate: selectedDate,
                                deleteButton: deleteMeal
                            )
                        }
                    }
                    .padding()
                }
                */

                Spacer()
            }
            .onAppear {
                fetchMeals()
            }
            //.navigationTitle("Daily Macros Page")
        }
    }
    var mealSections: some View {
        VStack(alignment: .leading, spacing: 20) {
            ForEach(["Breakfast", "Lunch", "Dinner"], id: \.self) { type in
                MealSectionView(
                    mealType: type,
                    meals: mealsForSelectedDate.filter { $0.meal_type == type },
                    selectedDate: selectedDate,
                    deleteButton: { meal in
                        deleteMeal(mealID: meal.id)
                    }
                )
            }
        }
    }

    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }
    
    func fetchMeals() {
        guard let url = URL(string: "http://localhost:3000/api/macros/\(userID)") else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                do {
                    let decoded = try JSONDecoder().decode([LoggedMeal].self, from: data)
                    DispatchQueue.main.async {
                        self.savedMeals = decoded
                    }
                } catch {
                    print("Failed to decode saved meals:", error)
                }
            }
        }.resume()
    }
    
    func deleteMeal(mealID: Int) { //placeholder until I implemenet function.
        //print("This will delete a meal once implemented")
        guard let url = URL(string: "http://localhost:3000/api/macros/\(mealID)") else {
            print("There is an error with the delete URL in the deleteMeal function")
            return
        }
        
        var request = URLRequest(url: url)  //creating URL request object with above url
        request.httpMethod = "DELETE"   //telling server about request to remove an item
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Couldn't delete meal. See error:", error) //should let us know if error occured when requesting for deletion
                return
            }
            DispatchQueue.main.async {
                fetchMeals()    //fetch the meals again after deletion. Deleted meal shouldn't show up no more
            }
        }.resume()
    }
}

// Meal Section Component
struct MealSectionView: View {
    var mealType: String
    var meals: [LoggedMeal]
    var selectedDate: Date
    var deleteButton: (LoggedMeal) -> Void //will allow deleteMeal function to be passed in.
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(mealType)
                .font(.title2)
                .bold()
                .foregroundColor(.black)

            if meals.isEmpty {
                Text("No meals added yet")
                    .foregroundColor(.gray)
                    .italic()
            } else {
                ForEach(meals) { meal in
                    HStack{
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meal.food_name)
                                .font(.headline)
                            Text("\(meal.calories) cal - \(meal.protein)g protein - \(meal.carbs)g carbs - \(meal.fats)g fat")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            deleteButton(meal)
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(8)
                }
            }

            // NavigationLink to AddMealView
            NavigationLink(destination: AddMealView(mealType: mealType, selectedDate: selectedDate)) {
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

struct LoggedMeal: Identifiable, Decodable {
    let id: Int
    let user_id: Int
    let food_name: String
    let serving_size: String
    let calories: Int
    let protein: Double
    let carbs: Double
    let fats: Double
    let created_at: String
    let meal_type: String?

}

#Preview {
    TaskBarView()
}
