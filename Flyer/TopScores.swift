//
//  TopScoreView.swift
//  Flyer
//
//  Created by David Williams on 12/26/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa

protocol TopScoreIdentifier {
    func getInitials() -> String?
}

class TopScores : NSObject, NSTableViewDataSource {
    static private var defaultsKey = "topScores"
    
    class Entry: Codable {
        var name: String
        var score: Int
        
        init( name: String, score: Int ) {
            self.name = name
            self.score = score
        }
    }
    
    var scores: [Entry]

    var tableView: NSTableView?
    var identifier: TopScoreIdentifier?

    init( table: NSTableView? ) {
        self.scores = UserDefaults.standard.array(forKey: TopScores.defaultsKey) as? [Entry] ?? []
        super.init()

        //
        // The scores are supposed to be stored sorted, but it doesn't
        // hurt to re-sort them in any case
        //
        self.scores.sort{ $0.score > $1.score }

        self.tableView = table
        self.tableView?.dataSource = self

        updateView()
    }
    
    func updateView() {
        self.tableView?.reloadData()
    }
    
    func scoreInTopFive( score: Int ) -> Bool {
        return scores.count < 5 || score > scores.last!.score
    }
    
    func registerScore( initials: String, score: Int ) {
        //
        // Congrats! append and sort
        //
        scores.append(Entry(name: initials, score: score))
        scores.sort{ $0.score > $1.score }
        
        //
        // Keep to five elements
        //
        if scores.count > 5 { scores.removeLast() }
        
        //
        // Save
        //
        UserDefaults.standard.set(try? PropertyListEncoder().encode(self.scores), forKey: TopScores.defaultsKey)
        
        //
        // Update the view
        //
        updateView()
    }
    
    
    //
    // Number rows of data (NSTableViewDataSource)
    //
    func numberOfRows(in tableView: NSTableView) -> Int {
        return scores.count
    }
 
    //
    // Data for given table cell (NSTableViewDataSource)
    //
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if tableColumn == tableView.tableColumns[0] {
            return self.scores[row].name
        }
        else if tableColumn == tableView.tableColumns[1] {
            //
            // We can return the integer directly, but then we don't have
            // control over the formatting
            //
            return "\(self.scores[row].score)"
        }
        
        return nil
    }
}
