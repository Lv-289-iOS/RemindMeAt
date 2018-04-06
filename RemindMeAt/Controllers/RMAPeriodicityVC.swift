//
//  RMAPeriodicityViewController.swift
//  RemindMeAt
//
//  Created by Yurii Tsymbala on 2/26/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit

class RMAPeriodicityVC: UIViewController {
    
    let periodicityPack = ["Once", "Every day", "Every week", "Every month", "Every year"]
    
    var period = 0
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
}

extension RMAPeriodicityVC:  UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return periodicityPack.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "Cell")
        cell.textLabel?.text = periodicityPack[indexPath.row]
        if indexPath.row == period {
            cell.accessoryType = .checkmark
        }
        cell.backgroundColor = .clear
        return cell
    }
}

extension RMAPeriodicityVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.reloadData()
        if indexPath.row != period {
            tableView.cellForRow(at: [0,period])?.accessoryType = .none
        }
        tableView.cellForRow(at: indexPath)?.accessoryType = .checkmark
        period = indexPath.row
        let dateForSenging: [String: Int] = ["date": period]
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25, execute: {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: dateForSenging)
        let controllerIndex = self.navigationController?.viewControllers.index(where: { (viewController) -> Bool in
            return viewController is RMANewTaskVC
        })
        let destination = self.navigationController?.viewControllers[controllerIndex!]
        self.navigationController?.popToViewController(destination!, animated: true)
        })
    }
}
