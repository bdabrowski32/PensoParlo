//
//  NotesTableViewCell.swift
//  Penso Parlo
//
//  Created by Dabrowski,Brendyn on 9/7/19.
//  Copyright © 2019 BDCreative. All rights reserved.
//

import UIKit

/**
 Table view cell that handles showing the note items.
 */
class GroupTableViewCell: UITableViewCell, UITextFieldDelegate {

    private var thoughtItem: ThoughtItem?

    private let gradientLayer = CAGradientLayer()

    var thoughtGroup: ThoughtGroup?

    weak var delegate: GroupCellDelegate!

    @IBOutlet var textField: UITextField!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var cancelButton: UIButton!

    // MARK: - Initialization

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        self.setupCell()
    }

    // MARK: - View Lifecycle

    override func layoutSubviews() {
        super.layoutSubviews()

        self.setupContentView()
        self.setupBackgroundView()
        self.setupGradientLayer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if selected {
            self.gradientLayer.isHidden = false
            self.textField?.textColor = .white
            self.textField.tintColor = .white
            self.setSelectedButtonColors()
        } else {
            self.gradientLayer.isHidden = true
            self.textField.textColor = #colorLiteral(red: 0.5215686275, green: 0.5490196078, blue: 0.6196078431, alpha: 1)
            self.textField.tintColor = #colorLiteral(red: 0.5215686275, green: 0.5490196078, blue: 0.6196078431, alpha: 1)
            self.setDeselectedButtonColors()
        }

//        self.thoughtItem?.update(text: self.thoughtItem?.text ?? "", group: self.thoughtGroup?.name ?? "")
    }

    // MARK: - IBActions

    func addNewCell() {
        self.startEditing()
        self.setSelected(true, animated: true)
    }

    @IBAction func editGroupName(_ sender: UIButton) {
        // If the text field is not empty, then we want to set the thought group object to the corresponding
        // thought group Realm object.
        if let textFieldText = self.textField.text, !textFieldText.isEmpty {
            if let thoughtGroup = self.thoughtGroup {
                self.thoughtGroup = ThoughtGroup.getThoughtGroup(byId: thoughtGroup.id)
            } else {
                self.thoughtGroup = ThoughtGroup.getThoughtGroup(byName: textFieldText.trimmingCharacters(in: .whitespaces))
            }
        }

        self.startEditing()
    }

    @IBAction private func cancelGroupEditing(_ sender: UIButton) {
        guard let thoughtGroup = self.thoughtGroup else {
            return
        }

        if let currentGroup = ThoughtGroup.getThoughtGroup(byId: thoughtGroup.id), currentGroup.name?.isEmpty == false {
            self.textField.text = thoughtGroup.name ?? ""
        } else {
            thoughtGroup.delete()
            self.thoughtGroup = nil
        }

        self.delegate.observeTableViewChanges(initialAction: nil)
        self.endEditing()
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let textFieldText = self.textField.text else {
            return false
        }

        let text = textFieldText.trimmingCharacters(in: .whitespaces)

        if !text.isEmpty && ThoughtGroup.getThoughtGroup(byName: text)?.name == text {
            self.presentInvalidNameAlert(title: "Group Name Already Exists",
                                         message: "Please select a different name for this group.")
        } else if text.isEmpty {
            self.presentInvalidNameAlert(title: "Group Name is Empty",
                                         message: "Please enter a name for this group. The group name cannot be empty.")
        } else {
            self.thoughtGroup?.update(name: text)
        }

        self.endEditing()
        return true
    }

    // MARK: - Helper Methods

    private func presentInvalidNameAlert(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.editGroupName(UIButton())
        })

        self.delegate.presentAlert(alert: alert)
    }

    private func startEditing() {
        self.textField.isUserInteractionEnabled = true
        self.textField.becomeFirstResponder()
        self.showCancelButton()
        self.delegate.disableCellEditing()
    }

    private func endEditing() {
        self.textField.endEditing(true)
        self.textField.isUserInteractionEnabled = false
        self.textField.resignFirstResponder()
        self.showEditButton()
        self.delegate.enableCellEditing()

        if self.isSelected {
            self.setSelectedButtonColors()
        } else {
            self.setDeselectedButtonColors()
        }
    }

    // MARK: - Button Settings

    private func showEditButton() {
        self.editButton.isHidden = false
        self.cancelButton.isHidden = true
    }

    private func showCancelButton() {
        self.editButton.isHidden = true
        self.cancelButton.isHidden = false
    }

    private func setSelectedButtonColors() {
        let tintableImage = self.editButton.currentImage?.withRenderingMode(.alwaysTemplate)
        self.editButton.imageView?.image = tintableImage
        self.editButton.imageView?.tintColor = .white
    }

    private func setDeselectedButtonColors() {
        self.editButton.imageView?.image = #imageLiteral(resourceName: "EditButton_Gradient")
    }

    // MARK: - Cell Setup

    private func setupCell() {
        self.backgroundColor = .clear
        self.setupShadowLayer()
    }

    private func setupShadowLayer() {
        let contentViewLayerBounds = self.contentView.layer.bounds

        let shadowRect = CGRect(x: contentViewLayerBounds.origin.x,
                                y: contentViewLayerBounds.origin.y,
                                width: contentViewLayerBounds.width,
                                height: contentViewLayerBounds.height)
        let shadowInsets = UIEdgeInsets(top: 20, left: 40, bottom: 0, right: 40)

        self.layer.masksToBounds = false
        self.layer.shadowOpacity = 0.23
        self.layer.shadowRadius = 10
        self.layer.shadowOffset = CGSize(width: 0, height: 30)
        self.layer.shadowColor = #colorLiteral(red: 0.262745098, green: 0.2745098039, blue: 0.3098039216, alpha: 1)
        self.layer.shadowPath = CGPath(roundedRect: shadowRect.inset(by: shadowInsets),
                                       cornerWidth: 1,
                                       cornerHeight: 1,
                                       transform: nil)
   }

    private func setupContentView() {
        self.textField.delegate = self

        self.contentView.frame = self.contentView.frame.inset(by: UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10))
        self.contentView.backgroundColor = .white
        self.contentView.layer.cornerRadius = 8
    }

    private func setupBackgroundView() {
        self.selectedBackgroundView?.layer.shadowColor = UIColor.clear.cgColor
        self.selectedBackgroundView?.backgroundColor = UIColor.clear
    }

    private func setupGradientLayer() {
        self.gradientLayer.startPoint = CGPoint(x: -0.3, y: 0.5)
        self.gradientLayer.isHidden = true

        self.contentView.addGradient(with: self.gradientLayer,
                                     gradientFrame: self.contentView.bounds,
                                     colorSet: [#colorLiteral(red: 0.3489752412, green: 0.7369459271, blue: 0.5592894554, alpha: 1), #colorLiteral(red: 0.3489752412, green: 0.8607151908, blue: 0.635782392, alpha: 1)],
                                     locations: [0.0, 1.0])
    }
}
