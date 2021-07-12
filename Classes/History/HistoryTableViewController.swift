//
//  HistoryTableViewController.swift
//  NethCTI
//
//  Created by Administrator on 07/04/2021.
//

import UIKit

class HistoryTableViewController: UITableViewController {
    let cells:[String: String] = [
        "Incoming": "IncomingCallTableViewCell",
        "Outgoing": "OutgoingCallTableViewCell",
        "Lost": "LostCallTableViewCell"]
    
    let calls:[Date: [String]] = [
        Date(timeIntervalSinceNow: TimeInterval(-10000)): ["Adalia La Balia"],
        Date(timeIntervalSinceNow: TimeInterval(-100000)): ["Costanzo Giordano"]
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        // TODO: Disable editing.
        // TODO: Disable rearraging.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return calls.keys.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let index = calls.index(calls.startIndex, offsetBy: section)
        return calls[index].value.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Retreive the call.
        let index = calls.index(calls.startIndex, offsetBy: indexPath.section)
        let callsSubSet = calls[index].value
        let call = callsSubSet[indexPath.row]
        
        // Configure the cell.
        let identifier = cells["Incoming"] ?? "IncomingCallTableViewCell"
        // Cell could be a not History cell? If let? Guard let?
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! HistoryTableViewCell
        
        // TODO: Assign to the cell a contact with an address.
        cell.setCall(call)
        
        return cell
    }
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
