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
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
        reportButton.isEnabled = false
        
        databaseManager.delegate = self

        guard let lineNumber = reportManagerThree.lineNr else { return }

        databaseManager.loadLineDirections(for: lineNumber)
    }
    
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        guard let stopName = reportManagerThree.chosenStopName, let lineNumebr = reportManagerThree.lineNr else {return}
        
        databaseManager.saveReport()
        databaseManager.updatePointStatus(documentID: stopName, status: true, direction: "\(lineNumebr) towards \(databaseManager.getDirections()[reportManagerThree.directionIndex!])", date: Date.timeIntervalSinceReferenceDate)
        // cannot use the report button without chosing the index -> implement insurence for no directions
        
        navigationController?.popToRootViewController(animated: true)
    }
}

//MARK: - DatabaseManager Delegate
extension ReportControllerThree: DatabaseManagerDelegate{
    func updateUI(list:[Any]){
        tableView.reloadData()
    }
}

//MARK: - TableView DataSource Methods
extension ReportControllerThree: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let directions = databaseManager.getDirections()
        if directions.count > 0{
            return directions.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let directions = databaseManager.getDirections()
        if directions.count > 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = directions[indexPath.row]
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Błąd - Brak kierunków"
            return cell
        }
    }
    
}

//MARK: - TableViewDelegate Methods
extension ReportControllerThree: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard databaseManager.getDirections().count > 0 else { return }
        if let cell = tableView.cellForRow(at: indexPath) as? CustomCell {
            cell.setSelected(true, animated: true)
        }
        reportButton.isEnabled = true
        reportManagerThree.directionIndex = indexPath.row
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? CustomCell {
            cell.setSelected(false, animated: true)
        }
    }
}
