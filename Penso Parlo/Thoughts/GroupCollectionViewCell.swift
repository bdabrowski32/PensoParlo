//
//  GroupCollectionViewCell.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 4/19/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

class GroupCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var thoughtItemCountLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var groupNameLabel: UILabel!
    @IBOutlet weak var unneededView: UIView!

    var thoughtGroup: ThoughtGroup! {
        didSet {
            self.updateUI()
        }
    }

    func updateUI() {
        self.thoughtItemCountLabel.text = "14" // Need to get a count of all the thought items with the particular group name.
        self.dateLabel.text = "4/19/20" // Get the date of the last thought item to be added to the group.
        self.groupNameLabel.text = self.thoughtGroup.name

        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.masksToBounds = true
    }
}
