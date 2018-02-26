//
//  RMAPeriodicityViewController.swift
//  RemindMeAt
//
//  Created by Yurii Tsymbala on 2/26/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit

class RMAPeriodicityViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var pickerView: UIPickerView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    let periodicityPack = ["Every day", "Every week", "Every month", "Every year", "Custom..."]
    
    let customNumbersPack = ["Every 1","Every 2", "Every 3", "Every 4", "Every 5", "Every 6", "Every 7", "Every 8", "Every 9", "Every 10", "Every 11", "Every 12", "Every 13", "Every 14", "Every 15"]
    
    let customDaysPack = ["days", "weeks", "months", "years"]
    
    
  //  let custom
    
    //MARK: TableView Methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periodicityPack.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = periodicityPack[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
    }
    
    //MARK: PickerView Methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
         if (component == 0){
        return customNumbersPack[row]
        }
        return customDaysPack[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (component == 0){
            return customNumbersPack.count
        }
         return customDaysPack.count
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //
    }
}
