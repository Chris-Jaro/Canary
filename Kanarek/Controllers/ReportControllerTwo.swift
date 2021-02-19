//
//  ReportControllerTwo.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerTwo: UIViewController {
    
    var reportManagerTwo = ReportManager()

    @IBOutlet weak var tableView: UITableView!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = 100
        // Regular line number cell
        tableView.register(UINib(nibName: K.CustomCell.lineNibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.lineIdentifier)
        // Stop cell - used to display error message
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportThree"{
            let destinationVC = segue.destination as! ReportControllerThree
            if let _ = reportManagerTwo.linesList, let line = reportManagerTwo.selectedLine, let stopName = reportManagerTwo.stopName{
                destinationVC.reportManagerThree.lineNr = line
                destinationVC.reportManagerThree.chosenStopName = stopName

            }
        }
    }

}

//MARK: - TableView-related Methods
extension ReportControllerTwo: UITableViewDataSource{
    
    //#### - Function provides the number of section in the TableView | "One Row per Section" policy is applied to enable creating of the gap between the rows (by adding invisible headers of certain height)
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let lines = reportManagerTwo.linesList, lines.count > 0 else {return 1}
        let adjustedLines = reportManagerTwo.adjustLinesList(list: lines)
        
        return adjustedLines.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //#### - Functions determins exactly what is to be displayed on every cell one by one
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //## - Guard statement protects this function from the lack of data and displays the message accordingly
        guard let lines = reportManagerTwo.linesList, lines.count > 0 else {
            tableView.rowHeight = tableView.estimatedRowHeight
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Błąd - brak lini do wyświetlenia"
            cell.isUserInteractionEnabled = false
            cell.typeImage.image = UIImage(systemName: "exclamationmark.triangle.fill")
            cell.typeImage.isHidden = false
            return cell
        }
        
        //#### -> HERE ID and class downcast
        let adjustedLines = reportManagerTwo.adjustLinesList(list: lines)
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.lineIdentifier, for: indexPath) as! LineCustomCell
        cell.leftButton.setTitle("\(adjustedLines[indexPath.section][0])", for: .normal)
        cell.rightButton.setTitle("\(adjustedLines[indexPath.section][1])", for: .normal)
        if cell.rightButton.currentTitle == "0"{
            cell.rightButton.isEnabled = false
        }
        cell.delegate = self
        return cell
    }
}

extension ReportControllerTwo: UITableViewDelegate{
    
    //#### -> These two functions are responsible for the gap between the rows
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 10 // width of the gap between the cells
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        //# creates the gap between the cells
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
}

//MARK: - LineCustomCellDelegate Methods
extension ReportControllerTwo: LineCustomCellDelegate{
    
    //#### - Function deselects all the cells and is initiated by the buttonClicked actions
    func setDeselected() {
        tableView.visibleCells.forEach { (cell) in
            cell.setSelected(false, animated: true)
        }
    }
    
    //#### - Function performs action (saves data of the user's choise of line number and performs segue) | function id triggered by clicking the button
    func performAction(with selectedLine: Int) {
        reportManagerTwo.selectedLine = selectedLine
        performSegue(withIdentifier: "GoToReportThree" , sender: self)
    }
}

