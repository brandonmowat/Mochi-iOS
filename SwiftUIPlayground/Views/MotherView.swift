//
//  MotherView.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-19.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

struct MotherView : View {
    
    @ObservedObject var viewRouter: ViewRouter
    @ObservedObject var articlesState: ArticlesState
    
    var body: some View {
            VStack {
                if viewRouter.currentPage == "HOME" {
                    HomeView(viewRouter: viewRouter, articlesState: articlesState)
                } else if viewRouter.currentPage == "NEW_POST" {
                    ContentView(article: Article(), viewRouter: viewRouter, articlesState: articlesState)
                }
            }
    }
}

#if DEBUG
struct MotherView_Previews : PreviewProvider {
    static var previews: some View {
        MotherView(viewRouter: ViewRouter(), articlesState: ArticlesState())
    }
}
#endif
