//
//  KeyCodeTextView.swift
//  Flyer
//
//  Created by David Williams on 1/3/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import Cocoa

/**
 A TextView that captures key codes
 
 Note that we must always have a code, so the value
 can never be empty.
 */
class KeyCodeTextView: NSTextView {
    var keycode: CGKeyCode?
    
    convenience init( keycode: CGKeyCode? ) {
        self.init()
        self.keycode = keycode
        self.isEditable = true
        self.insertionPointColor = NSColor.clear
        self.string = keycode?.characters ?? ""
    }
    
    public override func keyDown(with event: NSEvent) {
        //
        // Store keycode for later retrieval
        //
        keycode = event.keyCode
        
        //
        // Change text to reflect the keycode, erase all prior content
        //
        self.string = event.keyCode.characters
    }
    
    override func becomeFirstResponder() -> Bool {
        let status = super.becomeFirstResponder()
        if status {
            self.drawsBackground = true
            self.backgroundColor = NSColor.selectedTextBackgroundColor
        }
        return status
    }
    
    override func resignFirstResponder() -> Bool {
        let status = super.resignFirstResponder()
        if status {
            self.drawsBackground = false
        }
        return status
    }
}
