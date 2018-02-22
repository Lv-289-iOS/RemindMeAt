//
//  CustomTableViewCell.swift
//  RemindMeAt
//
//  Created by Vadym Dmytriiev on 2/19/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {

    @IBOutlet weak var name: UILabel!

    @IBOutlet weak var date: UILabel!
 
    @IBOutlet weak var location: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
