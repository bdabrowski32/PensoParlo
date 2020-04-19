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
class TypeThoughtViewController: AddThoughtViewController {

    // MARK: - Static Properties

    /// The title of the view when the user is adding a thought.
    private static let newThoughtViewTitle = "Add Thought"

    // MARK: - Member Properties

    /// The thought item to edit.
    var thoughtItem: ThoughtItem?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.setupDoneButtonActions()
    }

    /**
     Creates the view controller from the storyboard.
     */
    static func createFromStoryboard() -> TypeThoughtViewController? {
        let storyboard = UIStoryboard(name: "TypeThoughtView", bundle: nil)
        return storyboard.instantiateViewController(withIdentifier: "TypeThoughtView") as? TypeThoughtViewController
    }

    override func setupDoneButtonActions(completion: (() -> Void)? = nil) {
        self.doneButton.onButtonPressHandler = { [weak self] in
            if self?.navigationItem.title == Self.newThoughtViewTitle && self?.contentTextView.text.isEmpty == false {
                // Adding here if the user exits the view.
                self?.addThoughtToQuickThoughts()
            } else {
                self?.thoughtItem?.update(text: self?.contentTextView.text ?? "")
            }

            // Getting this error when calling super in a closure.
            // Using 'super' in a closure where 'self' is explicitly captured is not yet supported
            self?.setupDoneButtonActionsSuper()
        }
     }

    /**
     Adding this method because of compiler error. This is the best way to handle this in swift right now.
     Error: Using 'super' in a closure where 'self' is explicitly captured is not yet supported
     */
    private func setupDoneButtonActionsSuper() {
        super.setupDoneButtonActions()
    }

    override func setupGroupButtonActions() {
        self.selectGroupButton.onButtonPressHandler = { [weak self] in
            self?.setupGroupButtonActionsSuper()
        }
    }

    private func setupGroupButtonActionsSuper() {
        super.setupGroupButtonActions()
    }

    // MARK: - Text View Delegate Methods

    /**
     Responds to changes by the user in the text view. This does not respond to programmatic changes in the text view such
     as when a user updates the text view with speech, since technically that is programmatically because they are not physically typing
     into the text view.

     - parameter textView: The text view to listen to.
     */
    func textViewDidChange(_ textView: UITextView) {
        if !self.contentTextView.text.isEmpty {
            self.selectGroupButton.isEnabled = true
        } else {
            self.selectGroupButton.isEnabled = false
        }
    }

    /**
     Sets up this view based on if the user is adding a new thought or editing a thought.
     */
    func setupView() {
        if let thoughtItem = self.thoughtItem {
            self.contentTextView.text = thoughtItem.text
            self.selectGroupButton.isEnabled = true
        } else {
            self.contentTextView.text = ""
            self.navigationItem.title = Self.newThoughtViewTitle
        }

        self.setupKeyboardDismissal()
        self.contentTextView.delegate = self
        self.contentTextView.becomeFirstResponder()
    }

    /**
     Dismisses the keyboard when the dismiss button is pressed on the keyboard toolbar.
     */
    private func setupKeyboardDismissal() {
        let toolbar = UINib(nibName: "KeyboardToolbar", bundle: nil).instantiate(withOwner: nil, options: nil).first as? KeyboardToolbar

        toolbar?.dismissButtonPressed = { [weak self] in
            self?.view.endEditing(true)
        }

        self.contentTextView.inputAccessoryView = toolbar
    }
}
