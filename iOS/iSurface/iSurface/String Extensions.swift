//
//  String Extentions.swift
//  iSurface
//
//  Created by iKing on 20.02.16.
//  Copyright © 2016 iKing. All rights reserved.
//

import Foundation

extension String {
    func trim() -> String {
        return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet())
    }
}