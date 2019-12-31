//
//  InitialsView.swift
//  Flyer
//
//  Created by David Williams on 12/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa

/**
 The sheet that allows a user to enter their initials
 */
class SaveScore: NSViewController, NSTextFieldDelegate {
    
    var topScores: TopScores?
    var score: Int?
    
    @IBOutlet var initialsField: NSTextField!
    @IBOutlet var addButton: NSButton!
    @IBOutlet var scoreLabel: NSTextField!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        if let score = self.score {
            //
            // Might as well reminder the user of their accomplishment
            //
            scoreLabel.stringValue = "\(score) is a new high score"
        }
        initialsField.delegate = self
    }

    //
    // Limit the initials to five characters.
    // As part of NSTextFieldDelegate.
    //
    func controlTextDidChange(_ obj: Notification) {
        if let textField = obj.object as? NSTextField, self.initialsField.identifier == textField.identifier {
            //
            // Limit "initials" to five characters
            //
            if textField.stringValue.count > 5 {
                textField.stringValue = String(textField.stringValue.suffix(5))
            }
            
            //
            // Add button is only enabled with non-blank initials
            //
            addButton.isEnabled = textField.stringValue.count > 0
        }
    }
    
    //
    // Handle "okay" button press.
    // Sends new score to top score list.
    //
    @IBAction func addPressed(_ sender: NSButton) {
        if let topScores = self.topScores, let score = self.score {
            topScores.registerScore( initials: initialsField.stringValue, score: score )
        }
        dismiss(self)
    }
}
