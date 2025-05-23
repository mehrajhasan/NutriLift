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
                // Date Navigation with optional calendar picker. This was modified so that the two dates shown before are now combined into one
                HStack(spacing: 20) {   //combined
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.left")   //for left toggle
                            .font(.title2)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    
                    Button(action: {
                        selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) ?? selectedDate
                    }) {
                        Image(systemName: "chevron.right")  //for right toggle
                            .font(.title2)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(12)
                .shadow(radius: 2)
                
                //View/Change Macro Goals buttion
                NavigationLink(destination: SetMacroGoalsView()) {
                    Text("View/Change Macro Goals")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
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
    @State private var showDeleteAlert = false
    @State private var mealToDelete: LoggedMeal?
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
                    .frame(minHeight: 60)
            } else {
                ForEach(meals) { meal in
                    HStack{
                        VStack(alignment: .leading, spacing: 4) {
                            Text(meal.food_name)
                                .font(.headline)
                            Text("\(meal.calories) cal - \(formatMacro(meal.protein))g protein - \(formatMacro(meal.carbs))g carbs - \(formatMacro(meal.fats))g fat")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            mealToDelete = meal
                            showDeleteAlert = true
                            //deleteButton(meal)
                        }) {
                            Image(systemName: "trash")
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(6)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
                    .alert("Are You Sure You Want To Delete This Meal?", isPresented: $showDeleteAlert, presenting: mealToDelete) { meal in
                        Button("Yes", role: .destructive) {
                            deleteButton(meal)
                        }
                        Button("No", role: .cancel) { }
                    }
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

func formatMacro(_ value: Double) -> String {
    if value.truncatingRemainder(dividingBy: 1) == 0 {
        return String(format: "%.0f", value) // no decimals if it's whole
    } else {
        return String(format: "%.1f", value) // show only one decimal place if needed
    }
}

#Preview {
    TaskBarView()
}
