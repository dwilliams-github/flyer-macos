//
//  Preferences.swift
//  Flyer
//
//  Created by David Williams on 1/1/20.
//  Copyright © 2020 David Williams. All rights reserved.
//
import Cocoa

/**
 Handle game preference pane
 */
class Preferences: NSViewController, NSTableViewDelegate, NSTableViewDataSource {

    @IBOutlet var difficultyPopup: NSPopUpButton!
    @IBOutlet var keyBindingTable: NSTableView!
    @IBOutlet var volumeSlider: NSSlider!
    @IBOutlet var muteSwitch: NSButton!
    @IBOutlet var fullScreenButton: NSButton!
    
    private var settings: GameSettings = GameSettings.standard
    private var keyViewDict: [Int: KeyCodeTextView] = [:]

   
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        //
        // Set current values
        // (except keycodes, which we set as a delegate)
        //
        switch(settings.difficultyKey) {
            case 0:
                difficultyPopup.selectItem(at:0)
            case 1:
                difficultyPopup.selectItem(at:1)
            case 2:
                difficultyPopup.selectItem(at:2)
            default:
                difficultyPopup.selectItem(at:1)
        }
        
        volumeSlider.floatValue = settings.volume * 100.0
        muteSwitch.state = settings.volume == 0 ? .on : .off
        fullScreenButton.state = settings.fullScreen ? .on : .off
        
        keyBindingTable.delegate = self
        keyBindingTable.dataSource = self
    }
    
    /**
     Action associated with pushing the "Okay" button on the preference pane.
     */
    @IBAction func okayPressed(_ sender: Any) {
        //
        // Read controls and save settings
        //
        settings.difficultyKey = difficultyPopup.indexOfSelectedItem
        
        for (seq, view) in self.keyViewDict {
            settings.setKeyValue( seq: seq, keycode: view.keycode )
        }

        if muteSwitch.state == .on {
            settings.volume = 0
        } else {
            settings.volume = volumeSlider.floatValue * 0.01
        }
        
        //
        // Make the model dialog go away
        //
        dismiss(self)
    }
    
    @IBAction func setVolume(_ sender: Any) {
        if let slider = sender as? NSSlider {
            //
            // Standard behavior for MacOS:
            // Setting the volume to zero automatically checks mute.
            // In contrast, setting mute on leaves the volume slider unchanged.
            //
            muteSwitch.state = slider.doubleValue == 0 ? .on : .off
        }
    }
    
    @IBAction func setFullScreen(_ sender: Any) {
        if let button = sender as? NSButton {
            settings.fullScreen = button.state == .on
        }
    }
    
    //
    // Number rows of data (NSTableViewDataSource)
    //
    func numberOfRows(in tableView: NSTableView) -> Int {
        return settings.numberKeyBindings
    }

    //
    // View for given table cell (NSTableViewDelegate)
    //
    func tableView(_ tableView: NSTableView, viewFor: NSTableColumn?, row: Int) -> NSView? {
        if viewFor == tableView.tableColumns[0] {
            let view = NSTextView()
            view.isEditable = false
            view.string = settings.keyDescription(seq: row) ?? ""
            return view
        }
        else if viewFor == tableView.tableColumns[1] {
            //
            // Create views for the keycode, but also keep
            // track of them for later reference
            //
            let view = KeyCodeTextView(keycode: settings.keyValue(seq: row))
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
