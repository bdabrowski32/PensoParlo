//
//  AddThoughtViewController.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 2/20/20.
//  Copyright © 2020 BDCreative. All rights reserved.
//

import os
import UIKit

class AddThoughtViewController: UIViewController, UITextViewDelegate {

    /// The editable thought text.
    @IBOutlet weak var contentTextView: UITextView!

    /// The button that takes the user to the Group Selection View Controller.
    @IBOutlet weak var selectGroupButton: SelectGroupButton!

    @IBOutlet weak var doneButton: ContinueSpeakingButton!

     /// The name of the segue that is used to segue to the Group Selection View Controller.
    static let chooseGroupViewSegue = "ChooseGroup"

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupGroupButtonActions()
    }

    func setupGroupButtonActions() {
        self.selectGroupButton.onButtonPressHandler = {
            self.performSegue(withIdentifier: Self.chooseGroupViewSegue, sender: self)
        }
    }

    func setupDoneButtonActions() {
        self.dismiss(animated: true, completion: nil)
    }

    func addThoughtToQuickThoughts() {
        ThoughtItem.add(text: self.contentTextView.text)
    }

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
