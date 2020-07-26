//
//  ViewRouter.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-07-19.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

class ViewRouter: ObservableObject {
    
    let objectWillChange = PassthroughSubject<ViewRouter,Never>()
    
    var currentPage: String = "HOME" {
        didSet {
            objectWillChange.send(self)
        }
    }
}
