//
//  GroupViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 4/19/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import UIKit

class GroupViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate {

    @IBOutlet weak var collectionView: UICollectionView!

    var thoughtGroups = [ThoughtGroup(name: "QuickThoughts"),
                         ThoughtGroup(name: "CaroleIsCrazy"),
                         ThoughtGroup(name: "Apps")]

    let cellScale: CGFloat = 0.6

    var indexPath: IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()

        let screenSize = UIScreen.main.bounds.size
        let cellWidth = floor(screenSize.width * cellScale)
//        let cellHeight = floor(screenSize.height * cellScale)
        let insetX: CGFloat = (view.bounds.width - cellWidth) / 2.0
        let insetY: CGFloat = 0//(view.bounds.height - cellHeight) / 2.0

//        let layout = collectionView!.collectionViewLayout as! UICollectionViewFlowLayout
//        layout.itemSize = CGSize(width: cellWidth, height: cellHeight)
        collectionView.contentInset = UIEdgeInsets(top: insetY, left: insetX, bottom: insetY, right: insetX)

        collectionView.dataSource = self
        collectionView.delegate = self
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return thoughtGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GroupCollectionViewCell", for: indexPath) as? GroupCollectionViewCell else {
            return UICollectionViewCell()
        }

        cell.thoughtGroup = thoughtGroups[indexPath.item]
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? GroupCollectionViewCell else {
            return
        }

        cell.contentView.backgroundColor = .orange
    }

    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let cell = self.collectionView.cellForItem(at: indexPath) as? GroupCollectionViewCell else {
            return
        }

        cell.contentView.backgroundColor = .green
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionViewLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let cellWidthIncludingSpacing = collectionViewLayout.itemSize.width + collectionViewLayout.minimumLineSpacing

        let index = (targetContentOffset.pointee.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        targetContentOffset.pointee = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left,
                                              y: scrollView.contentInset.top)

        self.indexPath = IndexPath(item: Int(roundedIndex), section: 0)

        self.changeItemAppearance(for: self.indexPath, shouldHighlightItem: true)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard let indexPath = self.indexPath else {
            print("IndexPath is nil")
            return
        }

        if self.collectionView.cellForItem(at: indexPath)?.isSelected == false {
            self.changeItemAppearance(for: indexPath, shouldHighlightItem: true)
        }
    }

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard let indexPath = self.indexPath else {
            print("IndexPath is nil")
            return
        }

        self.changeItemAppearance(for: indexPath, shouldHighlightItem: false)
    }

    func changeItemAppearance(for indexPath: IndexPath?, shouldHighlightItem: Bool) {
        guard let indexPath = indexPath else {
            print("IndexPath is nil")
            return
        }

        guard let cell = self.collectionView.cellForItem(at: indexPath) as? GroupCollectionViewCell else {
            return
        }

        if shouldHighlightItem {
            cell.contentView.backgroundColor = .orange
        } else {
            cell.contentView.backgroundColor = .green
        }
    }
}
