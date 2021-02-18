//
//  ReportControllerThree.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerThree: UIViewController {
    
    var databaseManager = DatabaseManager()
    var reportManagerThree = ReportManager()

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reportButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        reportButton.isEnabled = false // User cannot report anything until he chooses a valid direction
        
        //### - Table View configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
        databaseManager.delegate = self

        guard let lineNumber = reportManagerThree.lineNr else { return } // Guards from no data -> To avoid error from databse
        //# Loads the directions for given line number from the database
        databaseManager.loadLineDirections(for: lineNumber)
    }
    
    //#### - Function takes all the provided data and sends the report to the databse and then pops to root view (history, and updates the stop status)
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        
        //## This guard statment is an additional precausion to disable the user from reporting without having chosen a valid direction
        guard let stopName = reportManagerThree.chosenStopName, let lineNumebr = reportManagerThree.lineNr else {return}
        let direction = databaseManager.getDirections()[reportManagerThree.directionIndex!]// cannot use the report button without chosing the index -> implement insurence for no directions
        
        //Reports History
        databaseManager.saveReport(stop: stopName, line: lineNumebr, direction: direction)
        //Updating the status to dangerous
        databaseManager.updatePointStatus(documentID: stopName, status: true, direction: "\(lineNumebr) towards \(direction)", date: Date.timeIntervalSinceReferenceDate)
        
        navigationController?.popToRootViewController(animated: true)
    }
}

//MARK: - DatabaseManager Delegate
extension ReportControllerThree: DatabaseManagerDelegate{
    //#### - Function updates the tableView with the direction data from the databse
    func updateUI(list:[Any]){
        tableView.reloadData()
    }
}

//MARK: - TableView DataSource Methods
extension ReportControllerThree: UITableViewDataSource{
    
    //#### - Function returns number of rows to be presented by the TableView (if no data one row is returnes to display error message)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let directions = databaseManager.getDirections()
        if directions.count > 0{
            return directions.count
        } else {
            return 1
        }
    }
    
    //#### - Functions determins exactly what is to be displayed on every cell one by one
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let directions = databaseManager.getDirections() // Loads the data from the manager
        
        //If there is no data error message is displayed
        if directions.count > 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = directions[indexPath.row]
            //##Because the data needs to load the First cell is the error cell for split second and it blocks userInteraction and reveals the image, therefore this has to be taken back while loading of the proper cells
            cell.typeImage.isHidden = true
            cell.isUserInteractionEnabled = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Błąd - Brak kierunków"
            cell.isUserInteractionEnabled = false
            cell.typeImage.image = UIImage(systemName: "exclamationmark.triangle.fill")
            cell.typeImage.isHidden = false
            return cell
        }
    }
}

//MARK: - TableViewDelegate Methods
extension ReportControllerThree: UITableViewDelegate{
    //#### Function is responsible for the performing certain action after a valid direction option is selected (saves the data and enables reportButton functionality)
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard databaseManager.getDirections().count > 0 else { return }
        
        reportButton.isEnabled = true
        reportManagerThree.directionIndex = indexPath.row
    }
}
