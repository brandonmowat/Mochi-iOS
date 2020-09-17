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
    
    // A function to get the correct action corresponding to an article that we're editing
    func getActionButton() -> Alert.Button {
        let publishAction = self.article?.isPublished ?? false
            ? Alert.Button.default(Text("Save & Unpublish"), action: {self.saveArticle(publish: false)})
            : Alert.Button.default(Text("Save & Publish"), action: {self.saveArticle(publish: true)})
        return publishAction
    }
    
    
    // The toolbar
    var Toolbar: some View {
        HStack {
            
            Spacer()
            Button("Post Actions", action: {self.showActionSheet.toggle()})
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(
                        title: Text("Actions"),
                        message: Text("Available actions"),
                        buttons: [
                            self.getActionButton(),
                            .default(Text("Just Save"), action: {self.saveArticle()}),
                            .destructive(Text("Delete Post"), action: {self.deletePost()})
                        ]
                    )
                }
                .padding()
        }
    }
    
    // This is where we write our posts
    var body: some View {
        VStack {
            
            if (self.article == nil) {
                Text("No Article selected")
            } else {
                ScrollView() {
                    VStack {
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
                    }.frame(minWidth: nil, idealWidth: 800, maxWidth: 800, minHeight: nil, idealHeight: nil, maxHeight: nil, alignment: .center)
                }
                // Keyboard Shortcuts
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("postActionsShortcut"))) { notification in
                    if let postActionsShortcutKey = notification.object as? String {
                        if postActionsShortcutKey == "s" {
                         self.saveArticle()
                        }
                    }
                }
                .padding(0)
                
                Divider()
                Toolbar

            }
            
        }
        .navigationBarItems(trailing: PublishedLabel(article: article, isUnsaved: article!.body != self.BlogPostBody))

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(article: Article(), viewRouter: ViewRouter(), articlesState: ArticlesState())
    }
}
