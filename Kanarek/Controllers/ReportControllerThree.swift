//
//  ReportControllerThree.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerThree: UIViewController {
    
    var databaseManager = DatabaseManager() // Accessing the methods and variables for Firestore Database
    var dataManagerThree = DataManager() // Accessing the data variables and methods
    var errorManager = ErrorManager() // Accessing error-handling methods
    let reviewManager = ReviewManager() // Accessing review methods
    let userDefaults = UserDefaults.standard // Accessing UserDefaults
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var buttonRim: UIView!
    
    ///# - Function is called just before the view appears and performs action:
        // -> requests loading of the directionsList for the chosen line number in the current city from the Database
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let lineNumber = dataManagerThree.lineNr, let cityName = userDefaults.string(forKey: K.UserDefaults.cityName) else {
            errorManager.displayBasicAlert(title: "Błąd", subtitle: "Użytkownik jest po za obszarem dostępnego miasta.", controller: self)
            return
        } // Guards from no data -> To avoid error from database
        
        //# Loads the directions for given line number from the database for given city | If there is a city value in the defaults (to reach this stage there has to be)
        databaseManager.loadLineDirections(for: lineNumber, city: cityName)
    }
    
    ///# - Function triggers when the view is loaded and performs actions:
        // -> sets tableView delegate and dataSource
        // -> registers custom text cell
        // -> sets databaseManager delegate
        // -> disables the report button until user has chosen one of the direction options
    override func viewDidLoad() {
        super.viewDidLoad()
        reportButton.isEnabled = false // User cannot report anything until he chooses a valid direction
        reportButton.layer.cornerRadius = 15
        buttonRim.layer.cornerRadius = 15

        //### - Table View configuration
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.CustomCell.textNibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.textIdentifier)
        
        databaseManager.delegate = self
    }
    
    ///# - Function is triggered when the report button is tapped (which is only enabled after the direction is chosen) and performs actions:
        // -> updates the stop status to dangerous (with provided data) using databaseManager methods
        // -> creates a report file in the history database for the current city using database methods (which then triggers push notification)
        // -> calls reviewManager to save the number of reports
        // -> pops the user to root view in the current navigation controller (mainView with the map of stops)
    @IBAction func reportButtonPressed(_ sender: UIButton) {
        //## This guard statement is an additional precaution to disable the user from reporting without having chosen a valid direction and without providing cityName
        guard let stopName = dataManagerThree.chosenStopName, let lineNumber = dataManagerThree.lineNr, let cityName = userDefaults.string(forKey: K.UserDefaults.cityName) else {return}
        let direction = databaseManager.getDirections()[dataManagerThree.directionIndex!]
        
        //## saves the report and updates the stopStatus provided there is cityName (which has to be provided to start the reporting process)
        databaseManager.updatePointStatus(documentID: stopName, status: true, reportDetails: "\(lineNumber) w kierunku \(direction)", date: Date.timeIntervalSinceReferenceDate, city: cityName)
        databaseManager.saveReport(stop: stopName, line: lineNumber, direction: direction, city: cityName)
        
        //## calls reviewManager to save the number of reports
        reviewManager.saveReportNumber()
        
        //## pops to MainView
        navigationController?.popToRootViewController(animated: true)
    }
}

//MARK: - DatabaseManager Delegate
extension ReportControllerThree: DatabaseManagerDelegate{
    ///# - Function is triggered by the completion of fetching data (stop directions) from the database and performs action:
        // -> reloads the data in the tableView
    func updateUI(list:[Any]){
        tableView.reloadData()
    }
    
    ///# - Function is triggered by DatabaseManager if fails with error and performs action:
        // -> shows an alert with the error message
    func failedWithError(error: Error) {
        errorManager.displayBasicAlert(title: "Błąd", subtitle: "Prosimy o przesłanie błędu na nasz adres email.\n\(error.localizedDescription)", controller: self)
    }
}

//MARK: - TableView DataSource Methods
extension ReportControllerThree: UITableViewDataSource{
    
    ///# - Function returns number of rows to be presented by the TableView (if no data one row is returned to display error message)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let directions = databaseManager.getDirections()
        if directions.count > 0{
            return directions.count
        } else {
            return 1
        }
    }
    
    ///# - Functions determines exactly what is to be displayed on every cell one by one:
        // -> If there are directions for the chosen line number -> return cell for every direction and fill it with direction data
        // -> Else (there are no directions to display) -> error message is displayed
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let directions = databaseManager.getDirections() // Loads the data from the manager
        
        //If there is no data error message is displayed
        if directions.count > 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.textIdentifier, for: indexPath) as! TextCell
            if directions[indexPath.row] == "nan"{
                cell.isHidden = true
            }
            cell.label?.text = directions[indexPath.row]
            //##Because the data needs to load -> First cell is the error cell for split second and it blocks userInteraction and reveals the image, therefore this has to be taken back while loading of the proper cells
            cell.typeImage.isHidden = true
            cell.isUserInteractionEnabled = true
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.textIdentifier, for: indexPath) as! TextCell
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
    ///# - Function is triggered when on of the cells is selected by the user and performs actions:
        // -> saves the data about the direction selection of the user
        // -> enables the functionality of the report button
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard databaseManager.getDirections().count > 0 else { return }
        
        reportButton.isEnabled = true
        dataManagerThree.directionIndex = indexPath.row
    }
}
