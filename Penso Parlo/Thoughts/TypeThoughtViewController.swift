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

    @IBOutlet private weak var selectGroupButton: SelectGroupButton!

     /// The name of the segue that is used to segue to the Group Selection View Controller.
     private static let chooseGroupViewSegue = "ChooseGroupAfterType"

    /// The thought item to edit.
    var thoughtItem: ThoughtItem?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupView()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupButtonActions()
        self.observeNotifications()
    }

    private func observeNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.adjustForKeyboard),
                                               name: UIResponder.keyboardWillHideNotification,
                                               object: nil)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.adjustForKeyboard),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
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

        self.setupKeyboardDismissal()
        self.contentTextView.becomeFirstResponder()
    }

    private func setupButtonActions() {
        self.selectGroupButton.onButtonPressHandler = {
            self.performSegue(withIdentifier: Self.chooseGroupViewSegue, sender: self)
        }
    }

    private func setupKeyboardDismissal() {
        let toolbar = UINib(nibName: "KeyboardToolbar", bundle: nil).instantiate(withOwner: nil, options: nil).first as? KeyboardToolbar

        toolbar?.buttonPressed = {
            self.doneClicked()
        }

        self.contentTextView.inputAccessoryView = toolbar
    }

    @objc
    private func doneClicked() {
        self.view.endEditing(true)
    }

    @objc
    private func adjustForKeyboard(notification: Notification) {
        guard let keyboardValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {
            return
        }

        if notification.name == UIResponder.keyboardWillHideNotification {
            self.contentTextView.contentInset = .zero
        } else {
            self.contentTextView.contentInset = UIEdgeInsets(top: 0,
                                                             left: 0,
                                                             bottom: view.convert(keyboardValue.cgRectValue,
                                                                                  from: self.view.window).height - view.safeAreaInsets.bottom,
                                                             right: 0)
        }

        self.contentTextView.scrollIndicatorInsets = self.contentTextView.contentInset
        self.contentTextView.scrollRangeToVisible(self.contentTextView.selectedRange)
    }
}
