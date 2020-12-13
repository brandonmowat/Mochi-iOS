//
//  ContentView.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-04.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

extension View {
    func Print(_ vars: Any...) -> some View {
        for v in vars { print(v) }
        return EmptyView()
    }
}

struct ContentView: View {
    
    var article: Article?
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedObject var articlesState: ArticlesState
    
    @State var BlogPostPublishedDate: Date
    @State var BlogPostTags: String
    @State var BlogPostTitle: String
    @State var BlogPostDescription: String
    @State var BlogPostBody: String
            
    @State var showActionSheet = false
    @State var isSaving: Bool = false
    
    @State private var showingAlert = false
    
    
    init(article: Article?, viewRouter: ViewRouter, articlesState: ArticlesState) {
        self.viewRouter = viewRouter
        self.articlesState = articlesState
        self.article = article
                
        let isoformatter = ISO8601DateFormatter.init()
        
        _BlogPostPublishedDate = State(initialValue: isoformatter.date(from: article!.publishedDate ?? "") ?? Date())
        _BlogPostTags = State(initialValue: article!.tags ?? "")
        _BlogPostTitle = State(initialValue: article!.title)
        _BlogPostDescription = State(initialValue: article!.description ?? "")
        _BlogPostBody = State(initialValue: article!.body)
    }
    
    func saveArticle(publish: Bool? = nil) -> Void {
        let api = APIController()
        let isoformatter = ISO8601DateFormatter.init()
        
        self.isSaving = true
        
        api.PATCH(
            path: "articles/\(self.article!._id)",
            bodyDict: [
                "id": self.article!._id,
                "created": self.article!.created,
                "publishedDate": isoformatter.string(from: self.BlogPostPublishedDate),
                "tags": self.BlogPostTags,
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
                    
                    self.isSaving = false
                    return
                    }})
                }})
    }
    
    func deletePost() -> Void {
        let api = APIController()
        
        api.DELETE(
            path: "articles/\(self.article!._id)",
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
    
    func isUnsaved() -> Bool {
        return articlesState.articlesState.first(where: { $0._id == article?._id })?.body != self.BlogPostBody
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
                            .destructive(Text("Delete Post"), action: {self.showingAlert = true})
                        ]
                    )
                }
                .padding()
            
        // Alert the user to confirm deletion
        }.alert(isPresented: $showingAlert) {
            Alert(title: Text("Are you sure you want to delete this?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete")) {
                    self.deletePost()
                }, secondaryButton: .cancel())
        }
    }
    
    // This is where we write our posts
    var body: some View {
        ScrollView {
            
            if (self.article == nil) {
                Text("No Article selected")
            } else {
                VStack {
                    VStack {
                        DatePicker(selection: $BlogPostPublishedDate, in: ...Date(), displayedComponents: .date) {
                            Text("Published Date")
                        }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                        HStack {
                            Text("Tags").font(.caption)
                                .padding(.horizontal, 16)
                            Spacer()
                        }
                        
                        TextField("No tags yet :(", text: $BlogPostTags)
                            .font(.body)
                            .padding(.horizontal, 18)
                            .padding(.bottom, 16)
                        
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
                }.frame(minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 0,
                        maxHeight: .infinity,
                        alignment: .center
                )
                // Keyboard Shortcuts
                .onReceive(NotificationCenter.default.publisher(for: Notification.Name("postActionsShortcut"))) { notification in
                    if let postActionsShortcutKey = notification.object as? String {
                        if postActionsShortcutKey == "s" {
                         self.saveArticle()
                        }
                    }
                }
                

            }
            
        }
                                
        .navigationBarItems(trailing: PublishedLabel(article: self.article, isUnsaved: self.isUnsaved(), isSaving: self.isSaving))
        Divider()
        Toolbar

    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(article: Article(), viewRouter: ViewRouter(), articlesState: ArticlesState())
    }
}
