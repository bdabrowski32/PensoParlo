//
//  NotesTableViewCell.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

class NotesTableViewCell: UITableViewCell {

    private var onToggleCompleted: ((NotesItem) -> Void)?
    private var item: NotesItem?

    @IBOutlet private var label: UILabel!
    @IBOutlet private var button: UIButton!

    @IBAction private func toggleCompleted() {
        guard let item = item else { fatalError("Missing Todo Item") }

        onToggleCompleted?(item)
    }

    func configureWith(_ item: NotesItem, onToggleCompleted: ((NotesItem) -> Void)? = nil) {
        self.item = item
        self.onToggleCompleted = onToggleCompleted

        label.attributedText = NSAttributedString(string: item.text,
                                                  attributes: item.isCompleted ? [.strikethroughStyle: true] : [:])
        button.setTitle(item.isCompleted ? "☑️": "⏺", for: .normal)
    }
}
