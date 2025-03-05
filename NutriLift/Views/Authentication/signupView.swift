//
//  signupView.swift
//  NutriLift
//
//  Created by Mohammad Hossain on 3/2/25.
//

import SwiftUI

struct SignupTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        if isSecure {   //secure fields needed to hide input when user enters password
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(25)
                .overlay(
                    Text(placeholder)   //allows placeholder texts to only show when no input
                        .foregroundColor(text.isEmpty ? .gray : .clear) // placeholder is visible now
                        .padding(.leading, 15),
                    alignment: .leading
                )
        }
        else {  //if its not secure field, just show regular text fields with placeholder
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray)) //placeholder visible now
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(25)
        }
    }
}

struct signupView: View {
    // state variable for user input storing for each field
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""

    
    var body: some View {
        VStack {
            Spacer()    //content is pushed to center of screen using spacer()
            Text("Register")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.bottom, 20) //adds space below text
            
            VStack(spacing: 15) {
                SignupTextField(placeholder: "First Name", text: $firstName)
                SignupTextField(placeholder: "Last Name", text: $lastName)
                SignupTextField(placeholder: "Email", text: $email)
                SignupTextField(placeholder: "Create a Username", text: $username)
                SignupTextField(placeholder: "Create a Password", text: $password, isSecure: true)
                SignupTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
            }
            .padding(.horizontal, 25)   //Padding to align text boxes to be center
            //will be button to sign up
            Button(action: {
                
            }) {
                Text("Sign Up")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(15)
            }
            .padding(.horizontal, 30) //borders for sign up
            .padding(.top, 20) //for sign up
            
            Spacer()    //content pushed to center of screen
            
            Text("Already have an account?")
                .padding(.top,-65)
                .foregroundColor(Color(hue: 0.6667, saturation: 1.0, brightness: 1.0))
            
            NavigationLink(destination: loginView()) {  //navigation link to go to login page
                Text("Sign in!")
                    .underline()
            }
            .padding(.top,-55)
            .foregroundColor(Color(hue: 0.6667, saturation: 1.0, brightness: 1.0))
            
            Text("NutriLift")
                .font(.footnote)
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
        .padding()
    }
}

#Preview {
    NavigationStack {
        signupView()
    }
}
