//
//  LineCustomCell.swift
//  Kanarek
//
//  Created by Chris Yarosh on 17/02/2021.
//

import UIKit

protocol LineCustomCellDelegate {
    func performAction(with selectedLine:Int)
    func setDeselected()
}

class LineCustomCell: UITableViewCell {

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    
    var delegate: LineCustomCellDelegate? // ideally ReportControllerTwo
    var chosenNumber:String?
    
    //#### - Function configires the way a cell looks form the begining (UI config)
    override func awakeFromNib() {
        super.awakeFromNib()
        leftButton.layer.cornerRadius = 20 // to make the corners nicer
        leftButton.tintColor = UIColor.clear // to avoid the button-selected functionality of small blue swuare around the title
        rightButton.layer.cornerRadius = 20
        rightButton.tintColor = UIColor.clear
        
        
    }

    //#### - Function performed when the lineNumberButton is touched and action takes place (all the table cells are deselected | button's state is changed to "selected" | data chosen by the uesr is saved in a variable | cell's state is changed to selected)
    @IBAction func lineNumberButtonClicked(_ sender: UIButton) {
        guard sender.isEnabled else { return }
        if let delegate = delegate{
            delegate.setDeselected()
        }
        if !sender.isSelected{
            //Neutral -> changed to selected state
            // It also works on the yellow buttons becuase they change color and are deselected strainght afrter selection
            sender.isSelected = true
            chosenNumber = sender.currentTitle // save user's choise
            self.setSelected(true, animated: true) // sets cell's state to SELECTED
        }
    }
    
    //#### - Function reacts to the selection or deselection of the cells
    //## Selection : delegate performAction() is triggerd | buttons are recolored | the selected button is deselected but left with the color
    //## Deselection : all buttons are deselected | recolored accordingly
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
    
    //#### -> Function is responsible for the coloring of the buttons
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
