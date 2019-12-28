//
//  TopScoreView.swift
//  Flyer
//
//  Created by David Williams on 12/26/19.
//  Copyright © 2019 David Williams. All rights reserved.
//

import Cocoa

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
    
    var scores: [Entry]?
    
    var tableView: NSTableView?
    
    init( table: NSTableView? ) {
        super.init()
        //self.scores = UserDefaults.standard.array(forKey: TopScores.defaultsKey) as? [Entry]
        
        let fake = Entry( name: "XYZ", score: 999999 )
        self.scores = [fake]

        self.tableView = table
        self.tableView?.dataSource = self

        updateView()
    }
    
    func updateView() {
        self.tableView?.reloadData()
    }
    

    //
    // Number rows of data, as part of NSTableViewDataSource protocol
    //
    func numberOfRows(in tableView: NSTableView) -> Int {
        return scores?.count ?? 0
    }
 
    //
    // Data for given table cell, as part of NSTableViewDataSource protocol
    //
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        if let entry = self.scores?[row] {
            if tableColumn == tableView.tableColumns[0] {
                return entry.name
            }
            else if tableColumn == tableView.tableColumns[1] {
                //
                // We can return the integer directly, but then we don't have
                // control over the formatting
                //
                return "\(entry.score)"
            }
        }
        
        return nil
    }
}
