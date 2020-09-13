//
//  PublishedLabel.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-08-23.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

import SwiftUI

struct PublishedLabel: View {
    var article: Article?
    var textLabel: Bool? = false

    var body: some View {
        let isPublished = self.article?.isPublished ?? false
        let color = isPublished ? Color.green : Color.yellow
        let copy = isPublished ? "Published" : "Unpublished"
        let icon = isPublished
            ? Image(systemName: "checkmark.circle.fill")
            : Image(systemName: "exclamationmark.circle.fill")
        
        return HStack {
            if (self.textLabel!) {
                Text(copy)
            }
            icon.foregroundColor(color)
        }
    }
}

struct PublishedLabel_Previews: PreviewProvider {
    static var previews: some View {
        PublishedLabel()
    }
}
