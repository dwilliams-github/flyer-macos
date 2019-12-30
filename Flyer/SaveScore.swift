//
//  InitialsView.swift
//  Flyer
//
//  Created by David Williams on 12/29/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa

class SaveScore: NSViewController {
    
    var topScores: TopScores?
    var score: Int?
    
    @IBOutlet var initialsField: NSTextField!
    
    
    @IBAction func initialsChanged(_ sender: Any) {
        print(initialsField.stringValue)
    }
    
    @IBAction func okayPressed(_ sender: NSButton) {
        if let topScores = self.topScores, let score = self.score {
            topScores.registerScore( initials: initialsField.stringValue, score: score )
        }
        dismiss(self)
    }
}
