//
//  CGPoint+magnitude.swift
//  Flyer
//
//  Created by David Williams on 11/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa

extension CGPoint {
    func magnitude() -> CGFloat {
        return (x*x + y*y).squareRoot()
    }
}
