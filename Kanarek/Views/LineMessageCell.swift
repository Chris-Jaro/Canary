//
//  LineMessageCell.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/05/2021.
//

import UIKit

class LineMessageCell: UITableViewCell {

    @IBOutlet weak var messageButton: UIButton!
    
    var delegate: ReportTwoTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageButton.layer.cornerRadius = 20
    }
    
    @IBAction func messageButtonTapped(_ sender: UIButton) {
        guard sender.isEnabled else { return }
        if let delegate = delegate{
            delegate.deselectAllCells()
        }
        if !sender.isSelected{
            //Neutral -> changed to selected state
            // It also works on the yellow buttons because they change colour and are deselected straight after selection
            sender.isSelected = true
            self.setSelected(true, animated: true) // sets cell's state to SELECTED
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if selected && messageButton.isSelected {
            if let theDelegate = delegate{
                theDelegate.performAction(with: nil, or: messageButton.currentTitle)
            }
            //Colour the button
            applyColor(to: messageButton)
            //Deselect the button
            messageButton.isSelected = false
            
        } else {
            //Deselect and colour (the order of this actions is very important)
            messageButton.isSelected = false
            applyColor(to: messageButton)
        }
    }
    
    func applyColor(to button: UIButton){
        if button.isSelected && button.isEnabled{
            //Every enabled button selected
            button.backgroundColor = UIColor.init(cgColor: CGColor(red: 255/255, green: 201/255, blue: 60/255, alpha: 1))
        } else if button.isEnabled{
            //Normal not-selected buttons
            button.backgroundColor = UIColor.white
        } else {
            // Disabled buttons
            button.backgroundColor = UIColor.clear
        }
    }

}
