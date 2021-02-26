//
//  NumberCell.swift
//  Kanarek
//
//  Created by Chris Yarosh on 17/02/2021.
//

import UIKit

protocol NumberCellDelegate {
    func performAction(with selectedLine:Int)
    func deselectAllCells()
}

class NumberCell: UITableViewCell {

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var delegate: NumberCellDelegate? // ideally ReportControllerTwo
    var chosenNumber:String?
    
    //## - Function configires the way a cell looks form the begining (UI config)
        // -> rounds the corners of the buttons of the cell
        // -> changes button tint color to clear to avoid the button-selected functionality of small blue square around the title
    override func awakeFromNib() {
        super.awakeFromNib()
        leftButton.layer.cornerRadius = 20 
        leftButton.tintColor = UIColor.clear
        rightButton.layer.cornerRadius = 20
        rightButton.tintColor = UIColor.clear
    }

    //## - Function is triggered by tapping of one of the buttons in the cell and performs action:
        // -> calls its delegate to deselect all the table cells - deselectAllCells()
        // -> button's state is changed to "selected"
        // -> data chosen by the uesr is saved in a variable
        // -> cell's state is changed to selected
    @IBAction func lineNumberButtonClicked(_ sender: UIButton) {
        guard sender.isEnabled else { return }
        if let delegate = delegate{
            delegate.deselectAllCells()
        }
        if !sender.isSelected{
            //Neutral -> changed to selected state
            // It also works on the yellow buttons becuase they change color and are deselected strainght afrter selection
            sender.isSelected = true
            chosenNumber = sender.currentTitle // save user's choise
            self.setSelected(true, animated: true) // sets cell's state to SELECTED
        }
    }
    
    //## - Function reacts to the selection or deselection of the cells
        // -> Selection : delegate's performAction() is triggerd | buttons are recolored | the selected button is deselected but left with the color
        // -> Deselection : all buttons are deselected | recolored accordingly
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
        if selected && (rightButton.isSelected || leftButton.isSelected){
            //SELECTION - where at least one of the buttons has to be selected
            if let delegate = delegate{
                delegate.performAction(with: Int(chosenNumber!) ?? 0)
            }
            applyColor(to: rightButton)
            applyColor(to: leftButton)
            
            if rightButton.isSelected {
                rightButton.isSelected = false
            }
            if leftButton.isSelected {
                leftButton.isSelected = false
            }
            
        } else {
            //DESELECTION
            leftButton.isSelected = false
            rightButton.isSelected = false
            applyColor(to: rightButton)
            applyColor(to: leftButton)
        }
        
    }
    
    //## - Function is responsible for the coloring of the buttons
        // -> if enabled button is selected -> color to yellow
        // -> if enabled button (has to be deselected because all selected are already yellow) starts with 2 and has 3 digits -> color black | text color to white
        // -> if enabled button is neutral (others then the two cases specified above) -> color to white
        // -> if disabled button -> color to clear (invisible and not working)
    func applyColor(to button: UIButton){
        let title = button.currentTitle!
        if button.isSelected && button.isEnabled{
            //Every enabled button selected
            button.backgroundColor = UIColor.init(cgColor: CGColor(red: 255/255, green: 210/255, blue: 40/255, alpha: 1))
        } else if button.isEnabled && (title[title.startIndex] == "2" && title.count == 3){
            //Night line button (need to be before all other not-selected enabled buttons)
            button.backgroundColor = UIColor.black
            button.setTitleColor(UIColor.white, for: .normal)
        } else if button.isEnabled{
            //Normal not-selected buttons
            button.backgroundColor = UIColor.white
        } else {
            // Disabled buttons
            button.backgroundColor = UIColor.clear
        }
    }
    
}
