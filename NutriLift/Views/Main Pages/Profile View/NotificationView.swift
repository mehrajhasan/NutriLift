//
//  NotificationView.swift
//  NutriLift
//
//  Created by Mehraj Hasan on 3/24/25.
//

import SwiftUI

struct NotificationView: View {
    @State private var notifs: Bool = false
    
    var body: some View {
        if(!notifs){
            Text("Nothing to see here")
        }
        else if(notifs){
            Text("There are notifications")
        }
    }
}

#Preview {
    NotificationView()
}
