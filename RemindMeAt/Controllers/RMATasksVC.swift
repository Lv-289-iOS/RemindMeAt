//
//  RMATasksVC.swift
//  RemindMeAt
//
//  Created by Yurii Tsymbala on 2/7/18.
//  Edited by Artem Rieznikov on 2/13/18.
//  Copyright © 2018 SoftServe Academy. All rights reserved.
//

import UIKit
import RealmSwift
import CoreLocation

private let reuseIdentifier = "cell"

class RMATasksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var taskList: Results<RMATask>?
    
    var searchResult = Array<RMATask>()
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var taskListsTableView: UITableView!
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        searchResult = Array(taskList!).filter() {
             $0.name.lowercased().contains(searchText.lowercased())
        }
        taskListsTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        self.tabBarController?.tabBar.tintColor = UIColor.Screens.tabBarTintColor
        readTasksAndUpdateUI()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        setScreenStyle()
    }
    
    func setScreenStyle() {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black], for: .normal)
        taskListsTableView.tableHeaderView = searchController.searchBar
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.orange]
        navigationController?.navigationBar.barTintColor = UIColor.Screens.navigationBarTintColor
        searchController.searchBar.placeholder = "Search Tasks"
        searchController.searchBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        searchController.searchBar.barTintColor = UIColor.Screens.searchBarTintColor
        searchController.searchBar.backgroundColor = UIColor.Screens.searchBarBackgroundColor
    }
    
    func readTasksAndUpdateUI() {
        taskList = RMARealmManager.getAllTasks()
        self.taskListsTableView.setEditing(false, animated: true)
        self.taskListsTableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource -
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
            return searchResult.count
        }
        
        if let listsTasks = taskList {
            return listsTasks.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as! CustomTableViewCell
        
        func formatDate(date: NSDate) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
            return dateFormatter.string(from: date as Date)
        }
        
        if var task = taskList?[indexPath.row] {
            
            if isFiltering() {
                task = searchResult[indexPath.row]
            }
            
            cell.name.text = task.name
            if task.date != nil {
                cell.date.text = formatDate(date: task.date!)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let taskToChange = self.taskList?[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
            RMARealmManager.deleteTask(taskToBeDeleted: taskToChange!)
            self.readTasksAndUpdateUI()
        }
        
        let completeAction: UITableViewRowAction?
        if !(taskToChange?.isCompleted)! {
            completeAction = UITableViewRowAction(style: .default, title: "Complete") { (completeAction, indexPath) -> Void in
                
                let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
                cell.accessoryType = .checkmark
                RMARealmManager.updateTaskCompletion(updatedTask: taskToChange!, taskIsCompleted: true)
                self.readTasksAndUpdateUI()
            }
        } else {
            completeAction = UITableViewRowAction(style: .default, title: "Incomplete") { (incompleteAction, indexPath) -> Void in
                
                let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
                cell.accessoryType = .disclosureIndicator
                
                RMARealmManager.updateTaskCompletion(updatedTask: taskToChange!, taskIsCompleted: false)
                self.readTasksAndUpdateUI()
            }
            
        }
        
        deleteAction.backgroundColor = UIColor.red
        completeAction?.backgroundColor = UIColor.darkGray
        
        return [deleteAction, completeAction!]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive {
            let selectedTaskList = self.searchResult[indexPath.row]
            self.performSegue(withIdentifier: "TaskListVCToNewTaskVC", sender: selectedTaskList)
        } else {
            if let selectedTaskList = self.taskList?[indexPath.row] {
                self.performSegue(withIdentifier: "TaskListVCToNewTaskVC", sender: selectedTaskList)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newTaskViewController = segue.destination as! RMANewTaskViewController
        newTaskViewController.taskToBeUpdated = sender as? RMATask
    }
}

extension RMATasksVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
