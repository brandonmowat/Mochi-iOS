//
//  ArticlesState.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-23.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

struct Article: Decodable {
    var _id: String
    var created: String
    var publishedDate: String?
    var isPublished: Bool
    var title: String
    var description: String?
    var body: String
    var tags: String?
    
    
    init() {
        self._id = ""
        self.created = ""
        self.publishedDate = nil
        self.isPublished = false
        self.title = ""
        self.description = ""
        self.body = ""
        self.tags = ""
    }
}

class ArticlesState: ObservableObject {
    
    let objectWillChange = PassthroughSubject<ArticlesState,Never>()
    
    var articlesState: [Article] = [] {
        didSet {
            objectWillChange.send(self)
        }
    }
}

