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
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var taskList: Results<RMATask>?
    
    var searchResult = Array<RMATask>()
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var taskListsTableView: UITableView!
    
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        searchResult = Array(taskList!).filter() {
            
            var doesCategoryMatch = false
            
            if $0.tags.count == 0 {
                doesCategoryMatch = true
            } else {
                for oneTag in $0.tags {
                    let nameOfTag = oneTag.name
                    doesCategoryMatch = (scope == "All") || (nameOfTag == scope)
                    if doesCategoryMatch == true {
                        break
                    }
                }
            }
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch &&  $0.name.lowercased().contains(searchText.lowercased())
            }
        }
        taskListsTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
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
        searchController.searchBar.scopeButtonTitles = ["All", "holidays", "home", "shopping"]
        searchController.searchBar.delegate = self
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
                // cell.imageView
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
    
    func readTasksAndUpdateUI() {
        taskList = RMARealmManager.getAllTasks()
        self.taskListsTableView.setEditing(false, animated: true)
        self.taskListsTableView.reloadData()
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        // setting initial state
        
        cell.alpha = 0
        let transform = CATransform3DTranslate(CATransform3DIdentity, -250, 30, 0)
        cell.layer.transform = transform
        
        // animationg to final state
        
        UIView.animate(withDuration: 0.7) {
            cell.alpha = 1
            cell.layer.transform = CATransform3DIdentity
        }
    }

    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newTaskViewController = segue.destination as! RMANewTaskVC
        newTaskViewController.taskToBeUpdated = sender as? RMATask
    }
}
//to respond to the search bar
//to update search results based on information the user enters into the search bar.
extension RMATasksVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // to send currently selected scope in filter
        let searchBar = searchController.searchBar
        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        if topConstraint.constant == 0 || searchController.isActive {
            topConstraint.constant = 50
        } else {
            topConstraint.constant = 0
        }
        filterContentForSearchText(searchController.searchBar.text!, scope: scope)
    }
}

//when the user switches the scope in the scope bar
extension RMATasksVC: UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}

