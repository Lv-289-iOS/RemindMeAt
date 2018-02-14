//
//  CalendarVC.swift
//  addNewAndEditTask
//
//  Created by Ganna Melnyk on 2/8/18.
//  Copyright © 2018 Ganna Melnyk. All rights reserved.
//

import UIKit

class CalendarVC: UIViewController {
    var strDate = ""

    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var selectedDate: UILabel!
    
    @IBAction func dataPickerAction(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
        strDate = dateFormatter.string(from: datePicker.date)
        self.selectedDate.text = strDate
    }
    
    
    @IBAction func pathData(_ sender: UIButton) {
        let dateForSenging: [String: String] = ["date": strDate]
         NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: dateForSenging)
        
        let controllerIndex = self.navigationController?.viewControllers.index(where: { (viewController) -> Bool in
            return viewController is NewTaskViewController
        })
        let destination = self.navigationController?.viewControllers[controllerIndex!]
        self.navigationController?.popToViewController(destination!, animated: true)

    }
    
}
