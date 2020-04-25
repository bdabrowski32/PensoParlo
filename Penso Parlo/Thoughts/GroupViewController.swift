//
//  GroupViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 4/19/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

/**
 ViewController for displaying the groups created by the user.
 */
class GroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    // MARK: - Static Properties

    /// The reuseIdentifier for the cells in the collectionView.
    private static let groupCollectionViewCell = "GroupCollectionViewCell"

    // MARK: - Instance Properties

    var thoughtGroups = [ThoughtGroup(name: "QuickThoughts"),
                         ThoughtGroup(name: "CaroleIsCrazy"),
                         ThoughtGroup(name: "Apps")]

    /// The center-most displaying cell. Defaults to the most left cell in the collection.
    private var currentCellIndexPath = IndexPath(item: 0, section: 0)

    // MARK: - IBOutlets

    /// The collectionView that displays the user's thought groups.
    @IBOutlet private weak var collectionView: UICollectionView!

    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.shouldHighlightCell(true)
    }

    // MARK: - Helper Methods

    /**
     Configures the collectionView's insets, dataSource and delegates.
     */
    private func configureCollectionView() {
        let insetX: CGFloat = (self.view.bounds.width - GroupCollectionViewCell.unhighlightedCellSize.width) / 2.0
        self.collectionView.contentInset = UIEdgeInsets(top: 0, left: insetX, bottom: 0, right: insetX)

        self.collectionView.dataSource = self
        self.collectionView.delegate = self
    }

    /**
     Tells the cell if it should be highlighted or not.

     - parameter shouldHighlightCell: Determines if the cell should be highlighted or not.
     - parameter indexPath: The indexPath to identify the cell that should be highlighted or unhighlighted.
     */
    private func shouldHighlightCell(_ shouldHighlightCell: Bool, at indexPath: IndexPath? = nil) {
        if let cell = self.collectionView.cellForItem(at: indexPath ?? self.currentCellIndexPath) as? GroupCollectionViewCell {
            guard shouldHighlightCell else {
                cell.unhighlight()
                return
            }

            cell.highlight()
        }

        // Setting this in order to keep track of the currently highlighted cell for use by other functions in the class.
        self.currentCellIndexPath = indexPath ?? self.currentCellIndexPath
    }

    // MARK: - UICollectionView Methods

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thoughtGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Self.groupCollectionViewCell, for: indexPath) as? GroupCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.thoughtGroup = self.thoughtGroups[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return GroupCollectionViewCell.unhighlightedCellSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        // Unhighlights the previously selected cell.
        self.shouldHighlightCell(false)
        // Highlights the newly selected cell.
        self.shouldHighlightCell(true, at: indexPath)
    }

    // MARK: - UIScrollView Methods

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionViewLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let cellWidthIncludingSpacing = collectionViewLayout.itemSize.width + collectionViewLayout.minimumLineSpacing
        let roundedIndex = round((targetContentOffset.pointee.x + scrollView.contentInset.left) / cellWidthIncludingSpacing)

        // This is used to give the scrollview that snapping into place feeling.
        targetContentOffset.pointee = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left,
                                              y: scrollView.contentInset.top)

        // This uses the currentCellIndexPath above.
        self.shouldHighlightCell(true, at: IndexPath(item: Int(roundedIndex), section: 0))
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // If scrollViewWillEndDragging doesn't highlight the cell (which happens sometimes) then this method is a fallback to make
        // sure the cell gets highlighted indefinitely.
        if self.collectionView.cellForItem(at: self.currentCellIndexPath)?.isSelected == false {
            self.shouldHighlightCell(true)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.shouldHighlightCell(false)
    }
}
