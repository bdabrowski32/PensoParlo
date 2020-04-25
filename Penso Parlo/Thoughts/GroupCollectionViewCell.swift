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

    // MARK: - IBOutlets

    /// The label in the middle of the cell that tells the user how many thought items are in the thought group.
    @IBOutlet private weak var thoughtItemCountLabel: UILabel!

    /// The date on the cell to tell the user the date of the last added thought item to the thought group.
    @IBOutlet private weak var dateLabel: UILabel!

    /// The name of the thought group.
    @IBOutlet private weak var groupNameLabel: UILabel!

    // MARK: - Computed Properties

    /// The thought group's to use to display on the thought group cells. Populates the labels on the cell when set.
    var thoughtGroup: ThoughtGroup! {
        didSet {
            self.thoughtItemCountLabel.text = "14" // Need to get a count of all the thought items with the particular group name.
            self.dateLabel.text = "4/19/20" // Get the date of the last thought item to be added to the group.
            self.groupNameLabel.text = self.thoughtGroup.name

            self.configureCell()
        }
    }

    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupGradientLayer()
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
     Configues visual settings for the cell.
     */
    private func configureCell() {
        self.contentView.layer.cornerRadius = 10.0
        self.contentView.layer.masksToBounds = true
    }

    // MARK: - Gradient Layer Methods

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

    /**
     Configures the gradient layer that is used to highlight the cell.
     */
    private func setupGradientLayer() {
        self.gradientLayer.startPoint = CGPoint(x: 0.0, y: 1.0)
        self.gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.0)
        self.gradientLayer.isHidden = true

        self.contentView.addGradient(with: self.gradientLayer,
                                     gradientFrame: self.contentView.bounds,
                                     colorSet: [#colorLiteral(red: 0, green: 0.6783246398, blue: 0.7026051283, alpha: 1), #colorLiteral(red: 0, green: 0.8996345401, blue: 0.6334514022, alpha: 1)],
                                     locations: [0.0, 1.0])
    }
}
