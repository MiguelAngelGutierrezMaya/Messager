//
//  StatusTableViewController.swift
//  Messenger
//
//  Created by Miguel Angel Gutierrez Maya on 18/04/24.
//

import UIKit

class StatusTableViewController: UITableViewController {
    
    // MARK: - Vars
    var allStatuses: [String] = []
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        loadUserStatus()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        return allStatuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let status = allStatuses[indexPath.row]
        
        cell.textLabel?.text = status
        cell.accessoryType = status == User.currentUser?.status ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateCellCheck(indexPath)
        tableView.reloadData()
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    // MARK: - Loading Status
    private func loadUserStatus() {
        allStatuses = userDefaults.object(forKey: kSTATUS) as? [String] ?? []
        tableView.reloadData()
    }
    
    private func updateCellCheck(_ indexpath: IndexPath) {
        if var user = User.currentUser {
            user.status = allStatuses[indexpath.row]
            saveUserLocally(user)
            FirebaseUserListener.shared.saveUserToFirestore(user)
        }
    }
}
