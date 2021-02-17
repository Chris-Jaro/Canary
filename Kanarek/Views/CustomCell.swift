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
    @IBOutlet weak var typeImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        labelBubble.layer.cornerRadius = labelBubble.frame.size.height / 3 
        
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected{
            labelBubble.layer.backgroundColor = CGColor(red: 255/255, green: 210/255, blue: 40/255, alpha: 1)
        } else {
            if let text = label.text{
                if text[text.startIndex] == "2" && text.count > 1{
                    labelBubble.layer.backgroundColor = UIColor.black.cgColor
                    label.textColor = UIColor.white
                } else {
                    labelBubble.layer.backgroundColor = UIColor.white.cgColor
                }
            }
        }
    }
    
}
