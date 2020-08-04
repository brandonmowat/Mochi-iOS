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
                    Text(article.title != "" ? article.title : "UNTITLED ARTICLE")
                    Spacer()
                }
            }
        }
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
                
        }.onAppear {
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
