//
//  HistoryTableViewCell.swift
//  NethCTI
//
//  Created by Administrator on 07/04/2021.
//

import UIKit
import linphone
import linphonesw

/// Single Table View Cell for Call History. See each specialization for lost calls, incoming...
class HistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var contactImage: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var callImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        contactImage.image = UIImage(contentsOfFile: "call_missed.png");
        callImage.image = UIImage(contentsOfFile: "call_missed.png");
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    @objc func setCall(_ s: String) {
        nameLabel.text = s
        addressLabel.text = "address"
    }
    
    /// Set the contact to show in info labels.
    /// TODO: How can we retreive the address?
    /// - Parameter contact: contact or address.
    @objc func setContact(contact: Contact) {
        nameLabel.text = contact.displayName
        addressLabel.text = "address"
    }
    
    /// Make a call to the address specified.
    /// - Parameter sender: sender button.
    @IBAction func onCallButtonTouchUpInside(_ sender: Any) {
        // TODO: Make a call.
    }
}
