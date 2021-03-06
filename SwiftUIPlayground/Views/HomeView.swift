//
//  HomeView.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-19.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    let userData = UserData()
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedObject var articlesState: ArticlesState
    
    @State var loadingArticles: Bool = false
    @State var showSettings: Bool = false
    
        
    let decoder = JSONDecoder()
    
    var articles: some View {
        return List(articlesState.articlesState, id: \._id) { article in
            NavigationLink(destination: ContentView(article: article, viewRouter: self.viewRouter, articlesState: self.articlesState)) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(article.title != "" ? article.title : "UNTITLED ARTICLE")
                            .font(.title)
                            .padding(.bottom, 4)
                        Text(article.description!)
                            .font(.body)
                    }
                    Spacer()
                    PublishedLabel(article: article)
                }
            }
            .padding(12)
        }
    }
    
    var body: some View {
        NavigationView {
            
            
            if loadingArticles == true {
                ProgressView("Loading Articles. This may take a moment...")
            }
            
            articles
            
            .navigationBarTitle("Matcha & Mochi")
            .navigationBarItems(
                leading: HStack {
                    Button("Settings", action: {
                        self.showSettings.toggle()
                    }).sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
                },
                trailing: HStack {
                Button("New Post", action: {
                    let api = APIController()
                    
                      api.POST(
                      path: "articles/",
                      bodyDict: [
                        "title": "",
                        "body": "",
                        "description": ""],
                      callback: {(response: Any) -> Void in do {
                        
                        api.GET(path: "articles/", callback: {(response: Any) -> Void in do {
                            let decoder = JSONDecoder()
                            let articles: [Article] = try! decoder.decode([Article].self, from: response as! Data)

                            DispatchQueue.main.async {
                                self.articlesState.articlesState = articles
                            }
                            print(articles)
                                            
                            return
                        }})
                        
                        }})
                  }).offset(y: 0)
                
            })
            
            if (self.articlesState.articlesState.count > 0) {
                ContentView(article: self.articlesState.articlesState[0], viewRouter: self.viewRouter, articlesState: self.articlesState)
            }
                
        }
        // this forces a stack navigation style. Comment this out to use the default
        .navigationViewStyle(StackNavigationViewStyle())
        .onAppear {
            
            // Set loading indicator
            loadingArticles = true
            
            APIController().GET(path: "articles/", callback: {(response: Any) -> Void in do {
                let decoder = JSONDecoder()
                let articles: [Article] = try! decoder.decode([Article].self, from: response as! Data)
                
                loadingArticles = false

                DispatchQueue.main.async {
                    self.articlesState.articlesState = articles
                }
                                
                return
            }}, onError: {
                loadingArticles = false
                
                return
            })
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewRouter: ViewRouter(), articlesState: ArticlesState())
    }
}
