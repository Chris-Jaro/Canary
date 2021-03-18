//
//  TextCell.swift
//  Kanarek
//
//  Created by Chris Yarosh on 02/12/2020.
//

import UIKit

class TextCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var labelBubble: UIView!
    @IBOutlet weak var typeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //UI config
        labelBubble.layer.cornerRadius = labelBubble.frame.size.height / 3
    }

    ///# - Function reacts to row selection:
        // Selection -> white background is changed to yellow
        // Deselection -> yellow background is changed to white (original)
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected{
            labelBubble.layer.backgroundColor = CGColor(red: 255/255, green: 201/255, blue: 60/255, alpha: 1)
        } else {
            labelBubble.layer.backgroundColor = UIColor.white.cgColor
        }
    }
    
}
