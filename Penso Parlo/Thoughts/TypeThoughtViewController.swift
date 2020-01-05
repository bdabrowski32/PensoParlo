//
//  TypeThoughtViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 11/15/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 View controller used to edit thoughts.
 */
class TypeThoughtViewController: UIViewController {

    // MARK: - Static Properties

    /// The title of the view when the user is adding a thought.
    private static let newThoughtViewTitle = "Add Thought"

    /// The editable thought text.
    @IBOutlet private weak var contentTextView: UITextView!

    /// The thought item to edit.
    var thoughtItem: ThoughtItem?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
    }

    /**
     Creates the view controller from the storyboard.
     */
    static func createFromStoryboard() -> TypeThoughtViewController? {
        let storyboard = UIStoryboard(name: "TypeThoughtView", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "TypeThoughtView") as? TypeThoughtViewController
    }

    /**
     If the user is typing a new thought, it will add a new thought to realm.
     If the user is editing a thought this method updates the thought item and returns back to the previous view controller.

      - parameter sender:The back button on the navigation controller.
     */
    @IBAction private func back(_ sender: UIBarButtonItem) {
        if self.navigationItem.title == Self.newThoughtViewTitle && !self.contentTextView.text.isEmpty {
            ThoughtItem.add(text: self.contentTextView.text)
        } else {
            self.thoughtItem?.update(text: self.contentTextView.text)
        }

        self.navigationController?.popViewController(animated: true)
    }

    /**
     Sets up this view based on if the user is adding a new thought or editing a thought.
     */
    private func setupView() {
        if let thoughtItem = self.thoughtItem {
            self.contentTextView.text = thoughtItem.text
        } else {
            self.contentTextView.text = ""
            self.navigationItem.title = Self.newThoughtViewTitle
        }

        self.contentTextView.becomeFirstResponder()
    }
}
