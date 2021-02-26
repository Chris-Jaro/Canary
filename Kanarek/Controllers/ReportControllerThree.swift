//
//  ReportControllerThree.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerThree: UIViewController {
    
    var databaseManager = DatabaseManager() // Accessing the methods and variables for Firestore Database
    var dataManagerThree = DataManager() // Accessing the data variabeles and mathods
    let userDefaults = UserDefaults.standard // Accessing UserDefualts
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reportButton: UIButton!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    
    //## - Function triggers when the view is loaded and perfroms actions:
        // -> sets tableView delegate and dataSource
        // -> registers custom text cell
        // -> sets databaseManager delegate
        // -> loads line directions list for given line number and current city name
        // -> disables the report button until user has chosen one of the direction options
    override func viewDidLoad() {
        super.viewDidLoad()
        reportButton.isEnabled = false // User cannot report anything until he chooses a valid direction

        //### - Table View configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
        databaseManager.delegate = self

        guard let lineNumber = dataManagerThree.lineNr else { return } // Guards from no data -> To avoid error from databse
        
        //# Loads the directions for given line number from the database for given city | If there is a city value in the defaults
        //# else if there is no city name it loads default for poznan
        if let cityName = userDefaults.string(forKey: K.UserDefualts.cityName){
            databaseManager.loadLineDirections(for: lineNumber, city: cityName)
        } else {
            databaseManager.loadLineDirections(for: lineNumber)
        }
        
    }
    
    //## - Function is triggered when the report button is tapped (which is only enabled after the direction is chosen) and performs actions:
        // -> updates the stop status to dangerous (with provided data) using databaseManager methods
        // -> creats a report file in the history database for the current city usin database methods (which then triggers push notification)
        // -> popps the user to root view in the current navigation controller (mainView with the map of stops)
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        //## This guard statment is an additional precausion to disable the user from reporting without having chosen a valid direction
        guard let stopName = dataManagerThree.chosenStopName, let lineNumebr = dataManagerThree.lineNr else {return}
        let direction = databaseManager.getDirections()[dataManagerThree.directionIndex!]
        
        //## If there is cityName | Else default
        if let cityName = userDefaults.string(forKey: K.UserDefualts.cityName){
            databaseManager.saveReport(stop: stopName, line: lineNumebr, direction: direction, city: cityName)
            databaseManager.updatePointStatus(documentID: stopName, status: true, reportDetails: "\(lineNumebr) towards \(direction)", date: Date.timeIntervalSinceReferenceDate, city: cityName)
        } else {
            //Reports History
            databaseManager.saveReport(stop: stopName, line: lineNumebr, direction: direction)
            //Updating the status to dangerous
            databaseManager.updatePointStatus(documentID: stopName, status: true, reportDetails: "\(lineNumebr) towards \(direction)", date: Date.timeIntervalSinceReferenceDate)
        }
        
        navigationController?.popToRootViewController(animated: true)
    }
}

//MARK: - DatabaseManager Delegate
extension ReportControllerThree: DatabaseManagerDelegate{
    //#### - Function is triggered by the completion of fetching data (stop directions) from the database and pergorms action:
        // -> reloads the data in the tableView
    func updateUI(list:[Any]){
        tableView.reloadData()
    }
}

//MARK: - TableView DataSource Methods
extension ReportControllerThree: UITableViewDataSource{
    
    //## - Function returns number of rows to be presented by the TableView (if no data one row is returnes to display error message)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let directions = databaseManager.getDirections()
        if directions.count > 0{
            return directions.count
        } else {
            return 1
        }
    }
    
    //## - Functions determins exactly what is to be displayed on every cell one by one
        // -> If there are directions for the chosen line number -> return cell for every direction and fill it with direction data
        // -> Else (there are no directions to display) -> error message is displayed
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
    //## - Function is triggered when on of the cells is selected by the user and performs actions:
        // -> saves the data about the direction selection of the user
        // -> enables the functionality of the report button
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard databaseManager.getDirections().count > 0 else { return }
        
        reportButton.isEnabled = true
        dataManagerThree.directionIndex = indexPath.row
    }
}
