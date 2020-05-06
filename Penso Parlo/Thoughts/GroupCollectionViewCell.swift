//
//  GroupCollectionViewCell.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 4/19/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

/**
 The thought group cell in the collection view.
 */
class GroupCollectionViewCell: UICollectionViewCell {

    // MARK: - Static Properties

    /// The size to scale the cell up to when it is highlighted.
    private static let highlightedCellScale = CGAffineTransform(scaleX: 1.065, y: 1.065)

    /// The default scale for the cell. This is used when we want to return to its original size in an unhighlighted state.
    private static let unhighlightedCellScale = CGAffineTransform(scaleX: 1, y: 1)

    /// The default size of the cell.
    static let unhighlightedCellSize = CGSize(width: 224, height: 389)

    // MARK: - Instance Properties

    /// The gradient layer object used to highlight the cell.
    private let gradientLayer = CAGradientLayer()

    /// The view used for underlining the groupNameLabel.
    private let groupNameLabelUnderlineView = UIView()

    // MARK: - IBOutlets

    /// The label in the middle of the cell that tells the user how many thought items are in the thought group.
    @IBOutlet private weak var thoughtItemCountLabel: UILabel!

    /// The label that displays the day of the month that an item in the group was added or modified
    @IBOutlet private weak var dayLabel: UILabel!

    /// The label that displays the month that an item in the group was added or modified
    @IBOutlet private weak var monthLabel: UILabel!

    /// The label that displays the year that an item in the group was added or modified
    @IBOutlet private weak var yearLabel: UILabel!

    /// The name of the thought group.
    @IBOutlet private weak var groupNameLabel: UILabel!

    // MARK: - Computed Properties

    /// The thought group's to use to display on the thought group cells. Populates the labels on the cell when set.
    var thoughtGroup: ThoughtGroup! {
        didSet {
            self.thoughtItemCountLabel.text = "29" // Need to get a count of all the thought items with the particular group name.
            self.dayLabel.text = "19"
            self.monthLabel.text = "Sep"
            self.yearLabel.text = "2020"
            self.groupNameLabel.text = self.thoughtGroup.name

            self.configureCell()
        }
    }

    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        self.configureGroupNameUnderline()
        self.configureGradientLayer()
    }

    // MARK: - Helper Methods

    /**
     Scales the cell to a larger size and adds the gradient layer.
     */
    func highlight() {
        self.enableGradientLayer()
        self.transform = Self.highlightedCellScale
    }

    /**
     Scales the cell back to its default size and removes the gradient layer.
     */
    func unhighlight() {
        self.disableGradientLayer()
        self.transform = Self.unhighlightedCellScale
    }

    /**
     Shows the gradient layer.
     */
    private func enableGradientLayer() {
        self.gradientLayer.isHidden = false
    }

    /**
     Hides the gradient layer.
     */
    private func disableGradientLayer() {
        self.gradientLayer.isHidden = true
    }

    // MARK: - Configuration Methods

    /**
     Configures visual settings for the cell.
     */
    private func configureCell() {
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.masksToBounds = true
    }

    /**
     Configures the gradient layer that is used to highlight the cell.
     */
    private func configureGradientLayer() {
        self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        self.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        self.gradientLayer.isHidden = true

        self.contentView.addGradient(with: self.gradientLayer,
                                     gradientFrame: self.contentView.bounds,
                                     colorSet: [#colorLiteral(red: 0, green: 0.6783246398, blue: 0.7026051283, alpha: 1), #colorLiteral(red: 0, green: 0.8996345401, blue: 0.6334514022, alpha: 1)],
                                     locations: [0.0, 1.0])
    }

    /**
     Configures constraints for the Group Name Label Underline.
     */
    private func configureGroupNameUnderline() {
        self.groupNameLabelUnderlineView.backgroundColor = .white
        self.groupNameLabelUnderlineView.layer.cornerRadius = 5.0

        // It is mandatory to add to subview and translate auto resizing masks into constraints before
        // adding constraints programmatically.
        self.contentView.addSubview(self.groupNameLabelUnderlineView)
        self.groupNameLabelUnderlineView.translatesAutoresizingMaskIntoConstraints = false

        self.groupNameLabelUnderlineView.widthAnchor.constraint(equalToConstant: self.groupNameLabel.intrinsicContentSize.width)
            .isActive = true
        self.groupNameLabelUnderlineView.heightAnchor.constraint(equalToConstant: 2)
            .isActive = true
        self.groupNameLabelUnderlineView.topAnchor.constraint(equalTo: self.groupNameLabel.bottomAnchor,
                                                              constant: 2)
            .isActive = true

        // This is the same constant as the trailing edge of the group name label.
        self.groupNameLabelUnderlineView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor,
                                                                   constant: -24)
            .isActive = true
    }
}
