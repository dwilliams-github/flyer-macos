//
//  Preferences.swift
//  Flyer
//
//  Created by David Williams on 1/1/20.
//  Copyright © 2020 David Williams. All rights reserved.
//

import Cocoa

class Preferences: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var difficultyPopup: NSPopUpButton!
    @IBOutlet var keyBindingTable: NSTableView!
    
    private var settings: GameSettings?
    private var keyViewDict: [Int: KeyCodeTextView] = [:]

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Fetch settings
        //
        settings = GameSettings()
        
        //
        // Set current values
        //
        switch(settings?.difficultyKey) {
        case 0:
            difficultyPopup.selectItem(at:0)
        case 1:
            difficultyPopup.selectItem(at:1)
        case 2:
            difficultyPopup.selectItem(at:2)
        default:
            difficultyPopup.selectItem(at:1)
        }
        
        keyBindingTable.delegate = self
        keyBindingTable.dataSource = self
    }
    
    @IBAction func okayPressed(_ sender: Any) {
        settings?.difficultyKey = difficultyPopup.indexOfSelectedItem
        
        for (seq, view) in self.keyViewDict {
            settings?.setKeyValue( seq: seq, keycode: view.keycode )
        }
        
        dismiss(self)
    }

    //
    // Number rows of data (NSTableViewDataSource)
    //
    func numberOfRows(in tableView: NSTableView) -> Int {
        return settings?.numberKeyBindings ?? 0
    }

    //
    // View for given table cell (NSTableViewDelegate)
    //
    func tableView(_ tableView: NSTableView, viewFor: NSTableColumn?, row: Int) -> NSView? {
        if viewFor == tableView.tableColumns[0] {
            let view = NSTextView()
            view.isEditable = false
            view.string = settings?.keyDescription(seq: row) ?? ""
            return view
        }
        else if viewFor == tableView.tableColumns[1] {
            let view = KeyCodeTextView(keycode: settings?.keyValue(seq: row))
            self.keyViewDict[row] = view
            return view
        }
       
        return nil
    }
    
    //
    // Turn off row selection, which serves no purpose here
    // and is ugly (NSTableViewDelegate)
    //
    func tableView(_ tableView: NSTableView, shouldSelectRow row: Int) -> Bool {
        return false
    }
}
