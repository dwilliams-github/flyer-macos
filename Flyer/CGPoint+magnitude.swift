//
//  CGPoint+magnitude.swift
//  Flyer
//
//  Created by David Williams on 11/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//
import Cocoa

extension CGPoint {

    /**
     Return magnitude of point
     - Returns: the magnitude
     */
    func magnitude() -> CGFloat {
        return (x*x + y*y).squareRoot()
    }
}
