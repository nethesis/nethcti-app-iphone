//
//  OutgoingCallTableViewCell.swift
//  NethCTI
//
//  Created by Administrator on 07/04/2021.
//

import UIKit

class OutgoingCallTableViewCell: HistoryTableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.callImage.image = UIImage(contentsOfFile: "call_outgoing.png")
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
