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

//        cell.unneededView.backgroundColor = .black
        cell.contentView.backgroundColor = .orange
        print("hi bd! \(indexPath.item)")
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let collectionViewLayout = self.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }

        let cellWidthIncludingSpacing = collectionViewLayout.itemSize.width + collectionViewLayout.minimumLineSpacing

        let index = (targetContentOffset.pointee.x + scrollView.contentInset.left) / cellWidthIncludingSpacing
        let roundedIndex = round(index)

        if Int(roundedIndex) == thoughtGroups.startIndex {
            targetContentOffset.pointee = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        } else if Int(roundedIndex) == self.thoughtGroups.endIndex - 1 {
            targetContentOffset.pointee = CGPoint(x: roundedIndex * cellWidthIncludingSpacing + scrollView.contentInset.right, y: scrollView.contentInset.top)
        } else {
            targetContentOffset.pointee = CGPoint(x: roundedIndex * cellWidthIncludingSpacing - scrollView.contentInset.left + (scrollView.contentInset.right / 2), y: scrollView.contentInset.top)
        }

        self.collectionView(self.collectionView, didSelectItemAt: IndexPath(item: Int(roundedIndex), section: 0))
    }
}
