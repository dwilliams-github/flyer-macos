//
//  CGKeyCode+characters.swift
//  Flyer
//
//  Created by David Williams on 1/1/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
//  Extension to CGKeyCode to return a string representation.
//  Note that this is a pretty fragile operation, since it depends on
//  the user's keyboard.
//
//  This function returns more sensible strings than NSEvent.characters.
//  The latter won't work for isolated keycodes, like ones stored in UserDefaults.
//
//  Some code borrowed from:
//     Copyright © 2016 Shunsuke Furubayashi,
//          https://github.com/Clipy/Magnet/blob/master/Lib/Magnet/KeyCodeTransformer.swift
//     See also: https://avaidyam.github.io/2018/03/22/Exercise-Modern-Cocoa-Views.html
//
import Cocoa
import CoreServices
import Carbon

public extension CGKeyCode {
    var characters: String {
        if let special = CGKeyCode.specialKeyStrings[Int(self)] {
            //
            // Short cut for special key codes
            //
            return special
        }
        
        //
        // Otherwise use some crufty Carbon calls
        //
        let source = TISCopyCurrentASCIICapableKeyboardLayoutInputSource().takeUnretainedValue()
        let layoutData = TISGetInputSourceProperty(source, kTISPropertyUnicodeKeyLayoutData)
        let dataRef = unsafeBitCast(layoutData, to: CFData.self)
        let keyLayout = unsafeBitCast(CFDataGetBytePtr(dataRef), to: UnsafePointer<CoreServices.UCKeyboardLayout>.self)
        
        let keyTranslateOptions = OptionBits(CoreServices.kUCKeyTranslateNoDeadKeysBit)
        var deadKeyState: UInt32 = 0
        let maxChars = 256
        var chars = [UniChar](repeating: 0, count: maxChars)
        var length = 0
        
        let error = CoreServices.UCKeyTranslate(
            keyLayout,
            self,
            UInt16(CoreServices.kUCKeyActionDisplay),
            0,
            UInt32(LMGetKbdType()),
            keyTranslateOptions,
            &deadKeyState,
            maxChars,
            &length,
            &chars
        )
        
        return error == noErr ? NSString(characters: &chars, length: length).lowercased : "�"
    }
    
    private static let specialKeyStrings: [Int: String] = [
        kVK_F1:  "F1",
        kVK_F2:  "F2",
        kVK_F3:  "F3",
        kVK_F4:  "F4",
        kVK_F5:  "F5",
        kVK_F6:  "F6",
        kVK_F7:  "F7",
        kVK_F8:  "F8",
        kVK_F9:  "F9",
        kVK_F10: "F10",
        kVK_F11: "F11",
        kVK_F12: "F12",
        kVK_F13: "F13",
        kVK_F14: "F14",
        kVK_F15: "F15",
        kVK_F16: "F16",
        kVK_F17: "F17",
        kVK_F18: "F18",
        kVK_F19: "F19",
        kVK_F20: "F20",
        kVK_Space:            "space",
        kVK_Delete:           "⌫",
        kVK_ForwardDelete:    "⌦",
        kVK_ANSI_Keypad0:     "⌧",
        kVK_LeftArrow:        "←",
        kVK_RightArrow:       "→",
        kVK_UpArrow:          "↑",
        kVK_DownArrow:        "↓",
        kVK_End:              "⇲",
        kVK_Home:             "⇱",
        kVK_Escape:           "⎋",
        kVK_PageDown:         "⇟",
        kVK_PageUp:           "⇞",
        kVK_Return:           "↩",
        kVK_Tab:              "⇥",
        kVK_Help:             "?⃝",
        kVK_ANSI_KeypadClear: "⌧",
        kVK_ANSI_KeypadEnter: "⌅"
    ]
}

