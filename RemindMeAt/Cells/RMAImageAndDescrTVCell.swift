//
//  imageAndDescrTVCell.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/9/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class RMAImageAndDescrTVCell: UITableViewCell {

    @IBOutlet weak var pictureView: UIImageView!
    @IBOutlet weak var descrTextView: UITextView!
    
    func cellParameters(name: String?, placeholder: String, image: UIImage) {
        descrTextView.autocorrectionType = .no
        descrTextView.autocapitalizationType = .none
        descrTextView.textAlignment = .right
        descrTextView.font = .systemFont(ofSize: 14)
        pictureView.image = image
        if name == nil {
            descrTextView.text = placeholder
            descrTextView.textColor = UIColor.lightGray
        } else {
            descrTextView.text = name
            descrTextView.textColor = UIColor.black
        }
    }
    
}
