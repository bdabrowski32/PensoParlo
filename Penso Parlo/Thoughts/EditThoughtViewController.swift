//
//  EditThoughtViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 11/15/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 View controller used to edit thoughts.
 */
class EditThoughtViewController: UIViewController {

    /// The editable thought text.
    @IBOutlet private weak var contentTextView: UITextView!

    /// The thought item to edit.
    var thoughtItem: ThoughtItem?

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let thoughtItem = self.thoughtItem else {
            self.contentTextView.text = ""
            self.navigationItem.title = "Add Thought"
            return
        }
        self.contentTextView.text = thoughtItem.text
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.contentTextView.becomeFirstResponder()
    }

    /**
     Creates the view controller from the storyboard.
     */
    static func createFromStoryboard() -> EditThoughtViewController? {
        let storyboard = UIStoryboard(name: "EditNoteViewController", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "EditNoteViewController") as? EditThoughtViewController
    }

    /**
      Updates the thought item and returns back to the previous view controller.

      - parameter sender:The back button on the navigation controller.
     */
    @IBAction private func back(_ sender: UIBarButtonItem) {
        if self.navigationItem.title == "Add Thought" && !self.contentTextView.text.isEmpty {
            ThoughtItem.add(text: self.contentTextView.text)
        } else {
            self.thoughtItem?.update(text: self.contentTextView.text)
        }
        self.navigationController?.popViewController(animated: true)
    }
}
