//
//  InitialsView.swift
//  Flyer
//
//  Created by David Williams on 12/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa


class SaveScore: NSViewController, NSTextFieldDelegate {
    
    var topScores: TopScores?
    var score: Int?
    
    @IBOutlet var initialsField: NSTextField!
    @IBOutlet var addButton: NSButton!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        initialsField.delegate = self
    }

    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, self.initialsField.identifier == textField.identifier {
            //
            // Limit "initials" to five characters
            //
            if textField.stringValue.count > 5 {
                textField.stringValue = String(textField.stringValue.suffix(5))
            }
            
            //
            // Add is only enabled on non-blank initials
            //
            addButton.isEnabled = textField.stringValue.count > 0
        }
    }
    
    @IBAction func okayPressed(_ sender: NSButton) {
        if let topScores = self.topScores, let score = self.score {
            topScores.registerScore( initials: initialsField.stringValue, score: score )
        }
        dismiss(self)
    }
}
