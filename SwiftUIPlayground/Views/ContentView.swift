//
//  ContentView.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-04.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    var article: Article?
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedObject var articlesState: ArticlesState
    
    @State var BlogPostTitle: String
    @State var BlogPostDescription: String
    @State var BlogPostBody: String
        
    @State var showActionSheet = false
    
    init(article: Article?, viewRouter: ViewRouter, articlesState: ArticlesState) {
        self.viewRouter = viewRouter
        self.articlesState = articlesState
        self.article = article
        
        _BlogPostTitle = State(initialValue: article!.title)
        _BlogPostDescription = State(initialValue: article!.description ?? "")
        _BlogPostBody = State(initialValue: article!.body)
    }
    
    func saveArticle(publish: Bool? = nil) -> Void {
        let api = APIController()
        
        api.PATCH(
            path: "articles/\(self.article!.id)",
            bodyDict: [
                "id": self.article!.id,
                "created": self.article!.created,
                "isPublished": publish != nil ? publish! : self.article!.isPublished,
                "title": self.BlogPostTitle,
                "description": self.BlogPostDescription,
                "body": self.BlogPostBody],
            callback: {(response: Any) -> Void in do {
                api.GET(path: "articles/", callback: {(response: Any) -> Void in do {
                    let decoder = JSONDecoder()
                    let articles: [Article] = try! decoder.decode([Article].self, from: response as! Data)
                    
                    DispatchQueue.main.async {
                        self.articlesState.articlesState = articles
                    }
                    return
                    }})
                }})
    }
    
    func deletePost() -> Void {
        let api = APIController()
        
        api.DELETE(
            path: "articles/\(self.article!.id)",
            bodyDict: [
                "title": self.BlogPostTitle,
                "body": self.BlogPostBody],
            callback: {(response: Any) -> Void in do {
                api.GET(path: "articles/", callback: {(response: Any) -> Void in do {
                    let decoder = JSONDecoder()
                    let articles: [Article] = try! decoder.decode([Article].self, from: response as! Data)
                    
                    DispatchQueue.main.async {
                        self.articlesState.articlesState = articles
                    }
                    return
                    }})
                }})
    }
    
    // The toolbar
    var Toolbar: some View {
        HStack {
            Spacer()
            Button("Post Actions", action: {self.showActionSheet.toggle()})
                .padding()
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Actions"),
                message: Text("Available actions"),
                buttons: [
                    .default(Text("Just Save"), action: {self.saveArticle()}),
                    .default(Text("Save & Publish"), action: {self.saveArticle(publish: true)}),
                    .default(Text("Save & Unpublish"), action: {self.saveArticle(publish: false)}),
                    .destructive(Text("Delete Post"), action: {self.deletePost()})
                ]
            )
        }
    }
    
    // This is where we write our posts
    var body: some View {
        VStack {
            
            if (self.article == nil) {
                Text("No Article selected")
            } else {
                ScrollView {
                    TextField("Article Title", text: $BlogPostTitle)
                        .font(.largeTitle)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 8)
                    
                    TextField("Description", text: $BlogPostDescription)
                        .font(.headline)
                        .padding(.horizontal, 18)
                        .padding(.bottom, 8)
                    
                    MultilineTextField("Make your masterpiece", text: $BlogPostBody)
                        .padding(.horizontal, 14)
                }.padding(0)
                
                Divider()
                Toolbar

            }
            
        }

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(article: Article(), viewRouter: ViewRouter(), articlesState: ArticlesState())
    }
}
