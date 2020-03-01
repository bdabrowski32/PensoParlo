//
//  AddThoughtViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 2/20/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//
// swiftlint:disable private_outlet

import os
import UIKit

/**
Super class for the type thought view and the speak thought view. This sets up some of the view items so there is not repeated code between the two views.
 */
class AddThoughtViewController: UIViewController, UITextViewDelegate {

    // MARK: - IBOutlets

    /// The editable thought text.
    @IBOutlet weak var contentTextView: UITextView!

    /// The button that takes the user to the Group Selection View Controller.
    @IBOutlet weak var selectGroupButton: SelectGroupButton!

    /// The button that saves the thought and dismisses the view.
    @IBOutlet weak var doneButton: DoneButton!

    /// The button that dismisses the view without saving the thought.
    @IBOutlet weak var closeButton: UIButton!

    // MARK: - Static Properties

     /// The name of the segue that is used to segue to the Group Selection View Controller.
    static let chooseGroupViewSegue = "ChooseGroup"

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGroupButtonActions()
    }

    // MARK: - Button Methods

    /**
     Sets the action to be performed when the Select Group button is pressed.
     */
    func setupGroupButtonActions() {
        self.selectGroupButton.onButtonPressHandler = { [weak self] in
            self?.performSegue(withIdentifier: Self.chooseGroupViewSegue, sender: self)
        }
    }

    /**
     Sets the action to be performed when the Done button is pressed.
     */
    func setupDoneButtonActions(completion: (() -> Void)? = nil) {
        self.dismiss(animated: true)
        completion?()
    }

    /**
     Dismisses the view when the x button is pressed. This method does not save the thought.
     */
    @IBAction func closeView(_ sender: UIButton) {
        self.dismiss(animated: true)
    }

    // MARK: - Helper Methods

    /**
     Adds the thought to the quick thoughts group. This is added to quick thoughts group because no group is specified.
     The add method defaults to quick thoughts for the group.
     */
    func addThoughtToQuickThoughts() {
        ThoughtItem.add(text: self.contentTextView.text)
    }

    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let groupSelectionViewController = segue.destination as? GroupSelectionViewController {
            groupSelectionViewController.thoughtItem = ThoughtItem.add(text: self.contentTextView.text)
        } else {
            os_log("Unable to get a reference to the Group Selection View Controller.",
                   log: OSLog.default,
                   type: .debug)
        }
    }
}
