//
//  HomeView.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-19.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedObject var articlesState: ArticlesState
        
    let decoder = JSONDecoder()
    
    var articles: some View {
        return List(articlesState.articlesState, id: \.id) { article in
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
//            .overlay(
//                RoundedRectangle(cornerRadius: 20)
//                .stroke(Color.purple, lineWidth: 5)
//            )

        }
        .padding(.leading, 20)
    }
    
    var body: some View {
        NavigationView {
            
            articles
            
            .navigationBarTitle("Matcha & Mochi")
            .navigationBarItems(trailing: HStack {
                Button("New Post", action: {
                    let api = APIController()
                    
                      api.POST(
                      path: "articles/",
                      bodyDict: [
                        "title": "",
                        "body": "",],
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
            APIController().GET(path: "articles/", callback: {(response: Any) -> Void in do {
                let decoder = JSONDecoder()
                let articles: [Article] = try! decoder.decode([Article].self, from: response as! Data)

                DispatchQueue.main.async {
                    self.articlesState.articlesState = articles
                }
                                
                return
            }})
        }
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(viewRouter: ViewRouter(), articlesState: ArticlesState())
    }
}
