//
//  TagScreenTVCell.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/10/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class RMATagScreenTVCell: UITableViewCell {

    @IBOutlet weak var tagColorView: UIView!
    @IBOutlet weak var tagLabel: UILabel!
    @IBOutlet weak var tagIsChoosePic: UIImageView!
    
    func cellParameters(name: String, tagColor: UIColor) {
        tagColorView.layer.cornerRadius = 10
        tagColorView.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        tagColorView.layer.borderWidth = 2
        tagLabel.text = name
        tagColorView.backgroundColor = tagColor
    }
}
