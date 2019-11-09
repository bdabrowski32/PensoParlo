//
//  AddNoteButton.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 10/5/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

@IBDesignable
public class AddNotesButton: UIView {

    // MARK: Properties

    /// The button background image
    @IBInspectable var backgroundImage: UIImage! {
        didSet {
            self.button.setBackgroundImage(backgroundImage, for: .normal)
        }
    }

    /// The text for the label
    public var text: String! {
        didSet {
            self.buttonLabel.text = text
        }
    }

    /// The closure that runs when the button is pressed
    public var onButtonPressHandler: (() -> Void)?

    /// Allows disabling the button for dismissing the in call view
    @IBInspectable public var isEnabled: Bool = true {
        didSet {
            self.button.isEnabled = isEnabled
            self.buttonLabel.isEnabled = isEnabled
        }
    }

    // MARK: IBOutlet Properties

    /// The view of the entire xib
    @IBOutlet private weak var contentView: UIView!

    /// The button to press to terminate the call
    @IBOutlet private weak var button: UIButton!

    /// Describes what the button does
    @IBOutlet private weak var buttonLabel: UILabel!

    // MARK: IBAction Methods

    /// Called when the button is pressed normally
    @IBAction private func onTouchUpInside() {
        self.onButtonPressHandler?()
    }

    // MARK: Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.loadFromXib()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.loadFromXib()
    }

    // MARK: Private Methods

    private func loadFromXib() {
        let bundle = Bundle(for: AddNotesButton.self)

        bundle.loadNibNamed("AddNoteButton", owner: self, options: nil)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}

