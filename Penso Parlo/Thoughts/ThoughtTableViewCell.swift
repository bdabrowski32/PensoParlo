//
//  NotesTableViewCell.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 Table view cell that handles showing the note items.
 */
class ThoughtTableViewCell: UITableViewCell {

    private var onToggleCompleted: ((ThoughtItem) -> Void)?
    private var thoughtItem: ThoughtItem?

    @IBOutlet private var label: UILabel!
    @IBOutlet private var button: UIButton!

    @IBAction private func toggleCompleted() {
        guard let item = thoughtItem else { fatalError("Missing Todo Item") }

        onToggleCompleted?(item)
    }

    func configureWith(_ item: ThoughtItem, onToggleCompleted: ((ThoughtItem) -> Void)? = nil) {
        self.thoughtItem = item
        self.onToggleCompleted = onToggleCompleted

        label.attributedText = NSAttributedString(string: item.text,
                                                  attributes: item.isCompleted ? [.strikethroughStyle: true] : [:])
        button.setTitle(item.isCompleted ? "☑️": "⏺", for: .normal)
    }
}
