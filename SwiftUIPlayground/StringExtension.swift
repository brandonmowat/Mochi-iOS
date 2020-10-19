//
//  StringExtension.swift
//  SwiftUIPlayground
//
//  Created by Brandon Mowat on 2020-10-18.
//  Copyright © 2020 Brandon Mowat. All rights reserved.
//

//  https://stackoverflow.com/a/35360697

import Foundation

extension String {

    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
