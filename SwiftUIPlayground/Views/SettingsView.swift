//
//  SettingsView.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-10-18.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    let userData = UserData()
    
    @State var apiURL: String
    @State var username: String
    @State var password: String
    
    init() {
        _apiURL = State(initialValue: userData.get(key: "apiURL"))
        _username = State(initialValue: userData.get(key: "username"))
        _password = State(initialValue: userData.get(key: "password"))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Blog Settings").font(.largeTitle)
            Text("API URL").font(.headline)
            TextField("Your API URL", text: $apiURL)
            Text("username").font(.headline)
            TextField("username", text: $username)
            Text("password").font(.headline)
            SecureField("password", text: $password)
            Spacer()
        }.padding(16)
        Button("Save", action: {
            userData.add(key: "apiURL", value: self.apiURL)
            userData.add(key: "username", value: self.username)
            userData.add(key: "password", value: self.password)
            userData.save()
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
