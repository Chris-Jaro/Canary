//
//  ReportControllerTwo.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerTwo: UIViewController {
    
    let errorManager = ErrorManager()// Accessing error-handling methods
    var databaseManager = DatabaseManager()
    var dataManagerTwo = DataManager()
    @IBOutlet weak var tableView: UITableView!
    
    ///## - Function is triggered then the view is loaded and performs actions:
        // -> sets the dataSource and the delegate for tableView
        // -> sets row height to 100 (for the numbers)
        // -> registers both custom cells (text - for error message; number - for line numbers)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let chosenStopType = dataManagerTwo.chosenStopType else {
            return
        }
        databaseManager.loadLineNumbers(for: chosenStopType)
        
        databaseManager.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        // Regular line number cell
        tableView.register(UINib(nibName: K.CustomCell.numberNibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.numberIdentifier)
        
        // "Standing on the stop" Message cell
        tableView.register(UINib(nibName: "LineMessageCell", bundle: nil), forCellReuseIdentifier: "LineMessageCell")
        
        // Stop cell - used to display error message
        tableView.register(UINib(nibName: K.CustomCell.textNibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.textIdentifier)
    }

    ///# - Function is triggered right before the segue and performs action:
        // -> passes the chosen data (line number; stop name) to the dataManagerThree
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportThree"{
            let destinationVC = segue.destination as! ReportControllerThree
            if let _ = dataManagerTwo.linesList, let line = dataManagerTwo.selectedLine, let stopName = dataManagerTwo.stopName{
                destinationVC.dataManagerThree.lineNr = line
                destinationVC.dataManagerThree.chosenStopName = stopName

            }
        }
    }

}

//MARK: - Database Manager Delegate methods
extension ReportControllerTwo: DatabaseManagerDelegate{
    ///# - Function is triggered by DatabaseManager if fails with error and performs action:
        // -> shows an alert with the error message
    func failedWithError(error: Error) {
        errorManager.displayBasicAlert(title: "Błąd", subtitle: "Prosimy o przesłanie błędu na nasz adres email.\n\(error.localizedDescription)", controller: self)
    }
    
    func updateUI(list: [Any]) {
        guard let linesList = list as? [Int] else { return }
        dataManagerTwo.linesList = dataManagerTwo.filterLineNumbers(lines: linesList)
        tableView.reloadData()
    }
}

//MARK: - TableView-related Methods
extension ReportControllerTwo: UITableViewDataSource{
    
    ///# - Function provides the number of section in the TableView | "One Row per Section" policy is applied to enable creating the gap between the rows (by adding invisible headers of certain height)
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let lines = dataManagerTwo.linesList, lines.count > 0 else {return 1}
        let adjustedLines = dataManagerTwo.adjustLinesList(list: lines)
        
        return adjustedLines.count + 1 //# TO MAKE UP FOR THE ONE CELL -> "STANDING ON THE STOP"
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    ///# - Functions determines exactly what is to be displayed on every cell one by one:
        // -> If there are no lines -> error message is displayed
        // -> If there are lines the list is adjusted to conform with the two columns (list dimensions are changed [1,2,3,4] -> [[1,2][3,4]])
        // -> If lines.count is odd -> 0 is appended to the list and is button label is equal to 0 the button is disabled
        // -> delegate is set for the cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //## - Guard statement protects this function from the lack of data and displays the message accordingly
        guard let lines = dataManagerTwo.linesList, lines.count > 0 else {
            tableView.rowHeight = tableView.estimatedRowHeight
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.textIdentifier, for: indexPath) as! TextCell
            cell.label?.text = "Błąd - brak lini do wyświetlenia"
            cell.isUserInteractionEnabled = false
            cell.typeImage.image = UIImage(systemName: "exclamationmark.triangle.fill")
            cell.typeImage.isHidden = false
            return cell
        }
        
        if indexPath.section == 0 {
            tableView.rowHeight = 100
            let cell = tableView.dequeueReusableCell(withIdentifier: "LineMessageCell", for: indexPath) as! LineMessageCell
    
            cell.delegate = self
            return cell
            
        } else {
            let adjustedLines = dataManagerTwo.adjustLinesList(list: lines)
            tableView.rowHeight = 100
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.numberIdentifier, for: indexPath) as! NumberCell
            cell.leftButton.setTitle("\(adjustedLines[indexPath.section][0])", for: .normal)
            cell.rightButton.setTitle("\(adjustedLines[indexPath.section][1])", for: .normal)
            if cell.rightButton.currentTitle == "0"{
                cell.rightButton.isEnabled = false
            }
            cell.delegate = self
            return cell
        }
        
        
    }
}

extension ReportControllerTwo: UITableViewDelegate{
    
    ///# -> These two functions are responsible for the gap between the rows
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10 // the width of the gap between the cells in px
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //# creates the gap between the cells
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

//MARK: - NumberCellDelegate Methods
extension ReportControllerTwo: ReportTwoTableViewCellDelegate{
    
    ///# - Function is triggered by the buttonClicked actions
        // -> When a button with a line number is tapped the whole tableView gets deselected and then only the current button gets selected
    func deselectAllCells() {
        tableView.visibleCells.forEach { (cell) in
            cell.setSelected(false, animated: true)
        }
    }
    
    ///# - Function is triggered by tapping on one of the buttons in the number cell and performs actions:
        // -> saves data of the user's choice of line number
        // -> performs segue
    func performAction(with selectedLine:Int?, or message:String?) {
        if let lineNumber = selectedLine {
            print(lineNumber)
            dataManagerTwo.selectedLine = lineNumber
        } else if let message = message?.trimmingCharacters(in: .whitespaces) {
            print(message)
            dataManagerTwo.stopMessage = message
        }
//        performSegue(withIdentifier: K.Segues.toReportThree, sender: self)
        
    }
}

