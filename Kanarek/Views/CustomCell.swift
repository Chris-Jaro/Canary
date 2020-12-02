//
//  CustomCell.swift
//  Kanarek
//
//  Created by Chris Yarosh on 02/12/2020.
//

import UIKit

class CustomCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelBubble: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelBubble.layer.cornerRadius = labelBubble.frame.size.height / 3 
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
