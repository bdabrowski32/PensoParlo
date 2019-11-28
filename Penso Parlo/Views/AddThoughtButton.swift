//
//  AddNotesButton.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 10/5/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 Button that handles starting speech dictation.
 */
@IBDesignable
public class AddThoughtButton: UIView {

    // MARK: Properties

    /// The button background image
    @IBInspectable var backgroundImage: UIImage! {
        didSet {
            self.button.setBackgroundImage(backgroundImage, for: .normal)
        }
    }

    /// The closure that runs when the button is pressed
    public var onButtonPressHandler: (() -> Void)?

    /// Allows disabling the button for dismissing the in call view
    @IBInspectable public var isEnabled: Bool = true {
        didSet {
            self.button.isEnabled = isEnabled
        }
    }

    // MARK: IBOutlet Properties

    /// The view of the entire xib
    @IBOutlet private weak var contentView: UIView!

    /// The button to press to start speech dictation.
    @IBOutlet private weak var button: UIButton!

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

    /**
     Loads xib file and adds it to the view.
     */
    private func loadFromXib() {
        let bundle = Bundle(for: AddThoughtButton.self)

        bundle.loadNibNamed("AddNotesButton", owner: self, options: nil)
        self.addSubview(contentView)
        self.contentView.frame = self.bounds
        self.contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
    }
}
