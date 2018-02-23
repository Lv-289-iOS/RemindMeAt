//
//  NameTVCell.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/8/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class RMASingleTaskFieldsTVCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var putNameHere: UITextView!
    @IBOutlet weak var label: UILabel!
    
    func cellParameters(labelName: String, name: String?, placeholder: String, isTextField: Bool) {
        nameLabel.text = labelName
        if isTextField {
            setTextField(name: name, placeholder: placeholder)
        } else {
            setLabel(name: name, placeholder: placeholder)
        }
    }
    
    func setTextField(name: String?, placeholder: String) {
        putNameHere.textAlignment = .right
        putNameHere.textContainer.maximumNumberOfLines = 1
        putNameHere.font = .systemFont(ofSize: 14)
        putNameHere.autocorrectionType = .no
        putNameHere.autocapitalizationType = .none
        label.isHidden = true
        putNameHere.isHidden = false
        if name?.count == 0 {
            putNameHere.text = placeholder
            putNameHere.textColor = UIColor.lightGray
        } else {
            putNameHere.text = name
            putNameHere.textColor = UIColor.black
        }
    }
    
    func setLabel(name: String?, placeholder: String) {
        label.textAlignment = .right
        label.font = label.font.withSize(14)
        label.isHidden = false
        putNameHere.isHidden = true
        if name == nil {
            label.text = placeholder
            label.textColor = UIColor.lightGray
        } else {
            label.text = name
            label.textColor = UIColor.black
        }
    }
    
    func cleanCell() {
        for cellSubview in self.subviews{
            if cellSubview != self.nameLabel && cellSubview != self.contentView && cellSubview != self.putNameHere {
                cellSubview.removeFromSuperview()
            }
        }
    }
}
