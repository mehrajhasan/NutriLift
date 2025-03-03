//
//  signupView.swift
//  NutriLift
//
//  Created by Mohammad Hossain on 3/2/25.
//

import SwiftUI

struct CustomTextField: View {
    var placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    
    var body: some View {
        if isSecure {
            SecureField(placeholder, text: $text)
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(25)
                .overlay(
                    Text(placeholder)
                        .foregroundColor(text.isEmpty ? .gray : .clear) // placeholder is visible now
                        .padding(.leading, 15),
                    alignment: .leading
                )
        }
        else {
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.gray)) //placeholder visible now
                .padding()
                .background(Color.black)
                .foregroundColor(.white)
                .cornerRadius(25)
        }
    }
}

struct signupView: View {
    // state variable for user input storing
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
                CustomTextField(placeholder: "First Name", text: $firstName)
                CustomTextField(placeholder: "Last Name", text: $lastName)
                CustomTextField(placeholder: "Email", text: $email)
                CustomTextField(placeholder: "Create a Username", text: $username)
                CustomTextField(placeholder: "Create a Password", text: $password, isSecure: true)
                CustomTextField(placeholder: "Confirm Password", text: $confirmPassword, isSecure: true)
            }
            .padding(.horizontal, 30)   //Padding to align text boxes to be center
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
            
            Text("NutriLift")
                .font(.footnote)
                .foregroundColor(.black)
                .padding(.bottom, 10)
        }
        .padding()
    }
}

#Preview {
    signupView()
}
