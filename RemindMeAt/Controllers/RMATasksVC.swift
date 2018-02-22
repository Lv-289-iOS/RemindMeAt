
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

private let reuseIdentifier = "listCell"

class RMATasksVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    let searchController = UISearchController(searchResultsController: nil)
    
    var taskList: Results<RMATask>?
    
    var searchResult = Array<RMATask>()
    
    var isEditingMode = false
    
    var currentCreateAction: UIAlertAction!
    
    var locationManager = CLLocationManager()
    
    @IBOutlet weak var taskListsTableView: UITableView!
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        searchResult = Array(taskList!).filter({( task : RMATask) -> Bool in
            return task.name.lowercased().contains(searchText.lowercased())
        })
        print(searchResult)
        taskListsTableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tabBarController?.tabBar.isHidden = false
        readTasksAndUpdateUI()
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization()
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).setTitleTextAttributes([NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor.black], for: .normal)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Tasks"
        taskListsTableView.tableHeaderView = searchController.searchBar
        searchController.searchBar.tintColor = #colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.orange]
        navigationController?.navigationBar.barTintColor = UIColor.Screens.navigationBarTintColor
        searchController.searchBar.barTintColor = UIColor.Screens.searchBarTintColor
        searchController.searchBar.backgroundColor = UIColor.Screens.searchBarBackgroundColor
        
        
        // navigationItem.searchController = searchController
        definesPresentationContext = true
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func readTasksAndUpdateUI() {
        taskList = RMARealmManager.getAllTasks()
        self.taskListsTableView.setEditing(false, animated: true)
        self.taskListsTableView.reloadData()
    }
    
    // MARK: - User Actions -
    
    @IBAction func didSelectSortCriteria(_ sender: UISegmentedControl) {
        if let tasks = taskList {
            if sender.selectedSegmentIndex == 0 {
                self.taskList = RMARealmManager.sortTasksByName(listsTasks: tasks)
            } else {
                self.taskList = RMARealmManager.sortTasksByDate(listsTasks: tasks)
            }
            self.taskListsTableView.reloadData()
        }
    }
    
    @IBAction func didClickOnEditButton(_ sender: UIBarButtonItem) {
        isEditingMode = !isEditingMode
        self.taskListsTableView.setEditing(isEditingMode, animated: true)
    }
    
    @IBAction func didClickOnAddButton(_ sender: UIBarButtonItem) {
        displayAlertToAddTask(nil)
    }
    
    // Enable the create action of the alert only if textfield text is not empty
    @objc func listNameFieldDidChange(_ textField: UITextField) {
        self.currentCreateAction.isEnabled = (textField.text?.count)! > 0
    }
    
    func displayAlertToAddTask(_ updatedTask: RMATask!) {
        var title = "New Task"
        var doneTitle = "Create"
        if updatedTask != nil {
            title = "Update Task"
            doneTitle = "Update"
        }
        
        let alertController = UIAlertController(title: title, message: "Write the name of your task.", preferredStyle: UIAlertControllerStyle.alert)
        let createAction = UIAlertAction(title: doneTitle, style: UIAlertActionStyle.default) { (action) -> Void in
            
            let newTaskName = alertController.textFields?.first?.text
            
            if updatedTask != nil {
                // update mode
                RMARealmManager.updateTaskName(updatedTask: updatedTask, taskName: newTaskName!)
                self.readTasksAndUpdateUI()
            } else {
                let newTask = RMATask()
                newTask.name = newTaskName!
                
                newTask.date = NSDate()
                
                let newTag1 = RMATag()
                newTag1.name = "Tag #1"
                
                let newTag2 = RMATag()
                newTag2.name = "Tag #2"
                newTag2.color = UIColor.blue.hexString()
                
                newTask.tags.append(newTag1)
                newTask.tags.append(newTag2)
                
                newTask.location = RMALocation()
                newTask.location?.name = "Lviv"
                newTask.location?.latitude = 49.8383
                newTask.location?.longitude = 24.0232
                
                RMARealmManager.addTask(newTask: newTask)
                self.readTasksAndUpdateUI()
            }
        }
        
        alertController.addAction(createAction)
        createAction.isEnabled = false
        self.currentCreateAction = createAction
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        
        alertController.addTextField { (textField) -> Void in
            textField.placeholder = "Task Name"
            textField.addTarget(self, action: #selector(RMATasksVC.listNameFieldDidChange(_:)), for: UIControlEvents.editingChanged)
            if updatedTask != nil {
                textField.text = updatedTask.name
            }
        }
        
        self.present(alertController, animated: true, completion: nil)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CustomTableViewCell
        
        func formatDate(date: NSDate) -> String {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd-MMM-yyyy HH:mm"
            return dateFormatter.string(from: date as Date)
        }
        
        func extractNameFromLocation(){
            
        }
        
        if var task = taskList?[indexPath.row] {
            
            if isFiltering(){
                task = searchResult[indexPath.row]
            }
            
            cell.name.text = task.name
            if task.date != nil{
                cell.date.text = formatDate(date: task.date!)
            }
            // cell.location.text = task.location
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let taskToChange = self.taskList?[indexPath.row]
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (deleteAction, indexPath) -> Void in
            // Deletion will go here
            
            RMARealmManager.deleteTask(taskToBeDeleted: taskToChange!)
            self.readTasksAndUpdateUI()
        }
        
        let completeAction: UITableViewRowAction?
        if !(taskToChange?.isCompleted)! {
            completeAction = UITableViewRowAction(style: .default, title: "Complete"){(completeAction, indexPath) -> Void in
                
                let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
                cell.accessoryType = .checkmark
                RMARealmManager.updateTaskCompletion(updatedTask: taskToChange!, taskIsCompleted: true)
                self.readTasksAndUpdateUI()
                // method to rewrite isCompleted for task in DB
            }
        } else {
            completeAction = UITableViewRowAction(style: .default, title: "Incomplete"){(incompleteAction, indexPath) -> Void in
                
                let cell = tableView.cellForRow(at: indexPath) as! CustomTableViewCell
                cell.accessoryType = .disclosureIndicator
                
                RMARealmManager.updateTaskCompletion(updatedTask: taskToChange!, taskIsCompleted: false)
                self.readTasksAndUpdateUI()
                // method to rewrite isCompleted for task in DB
            }
            
        }
        
        
        deleteAction.backgroundColor = UIColor.red
        completeAction?.backgroundColor = UIColor.darkGray
        
        return [deleteAction, completeAction!]
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if searchController.isActive{
            let selectedTaskList = self.searchResult[indexPath.row]
            self.performSegue(withIdentifier: "TaskListVCToNewTaskVC", sender: selectedTaskList)
        }else{
            if let selectedTaskList = self.taskList?[indexPath.row] {
                self.performSegue(withIdentifier: "TaskListVCToNewTaskVC", sender: selectedTaskList)
            }
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newTaskViewController = segue.destination as! NewTaskViewController
        newTaskViewController.taskToBeUpdated = sender as? RMATask
        
        
        
        
        //        if let indexPath = taskListsTableView.indexPathForSelectedRow{
        //            let destinationController = segue.destination as! NewTaskViewController
        //            destinationController.task = (searchController.isActive) ? searchResult[indexPath.row] : taskList[indexPath.row]
        //        }
        
        
        
        //    let task: RMATask
        //         if isFiltering() {
        //         task = searchResult[indexPath.row]
        //         } else {
        //         task = taskList[indexPath.row]
        //         }
        
    }
}

extension RMATasksVC: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
