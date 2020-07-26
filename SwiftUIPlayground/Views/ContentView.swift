//
//  ContentView.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-04.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

struct TextView: UIViewRepresentable {
    @Binding var text: String
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    func makeUIView(context: Context) -> UITextView {
        
        let myTextView = UITextView()
        myTextView.delegate = context.coordinator
        
        myTextView.font = UIFont(name: "HelveticaNeue", size: 20)
        myTextView.isScrollEnabled = true
        myTextView.isEditable = true
        myTextView.isUserInteractionEnabled = true
//        myTextView.backgroundColor = UIColor(white: 0.0, alpha: 0.05)
        
        return myTextView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        uiView.text = text
    }
    
    class Coordinator : NSObject, UITextViewDelegate {
        
        var parent: TextView
        
        init(_ uiTextView: TextView) {
            self.parent = uiTextView
        }
        
        func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
            return true
        }
        
        func textViewDidChange(_ textView: UITextView) {
            print("text now: \(String(describing: textView.text!))")
            self.parent.text = textView.text
        }
    }
}


struct ContentView: View {
    
    var article: Article?
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedObject var articlesState: ArticlesState
    
    @State var BlogPostTitle: String
    @State var BlogPostBody: String
    
    @State var showActionSheet = false
    
    init(article: Article?, viewRouter: ViewRouter, articlesState: ArticlesState) {
        self.viewRouter = viewRouter
        self.articlesState = articlesState
        self.article = article
        
        _BlogPostTitle = State(initialValue: article!.title)
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
    
    var body: some View {
        VStack {
            if (self.article == nil) {
                Text("No Article selected")
            } else {
                
                TextField("New Post", text: $BlogPostTitle).padding()
                TextView(text: $BlogPostBody).padding()
                    
                HStack {
                    Button("Post Actions", action: {self.showActionSheet.toggle()})
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
                }.padding()
                    
            }
            
        }.navigationBarTitle(self.BlogPostTitle)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(article: Article(), viewRouter: ViewRouter(), articlesState: ArticlesState())
    }
}
