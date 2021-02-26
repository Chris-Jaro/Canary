//
//  ReportControllerOne.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerOne: UIViewController {
    
    var dataManagerOne = ReportManager() // Accessing data variables and methods

    @IBOutlet weak var tableView: UITableView!
    
    //## - Changes the color of battery and time an service to white
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    //## - Function is triggred then the view is loaded and performs actions:
        // -> sets the delegate and dataSource for the tableView
        // -> Adjusts the view of the cells (setting the height to 80px)
        // -> registering custom text cell
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
    }
    
    //## - Function is triggered right before the segue and performs action:
        // -> filters the list for night lines (depending on the time) and passes it to dataManager of ReportViewControllerTwo
        // -> passes the name of the chosen stop to the dataManager of ReportViewControllerTwo
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportTwo"{
            let destinationVC = segue.destination as! ReportControllerTwo
            if let stopsList = dataManagerOne.stopsInTheArea, let index = dataManagerOne.chosenStopIndex{
                destinationVC.dataManagerTwo.linesList = dataManagerOne.filterLineNumbers(lines: stopsList[index].lines)
                destinationVC.dataManagerTwo.stopName = stopsList[index].stopName
                
            }
        }
    }

}

//MARK: - TableView-related Methods
extension ReportControllerOne: UITableViewDataSource{
    
    //## - Function returns number of rows to be displayed on the TableView (if there is nothing to displayed error message will be displayed)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stopsList = dataManagerOne.stopsInTheArea, stopsList.count > 0  else { return 1 }
        
        return stopsList.count
    }
    
    //## - Functions determins exactly what is to be displayed in every cell one by one
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //## - This guard is executed if there are no stops in the 1km area from the user AND displays a message accordingly
        guard let stopsList = dataManagerOne.stopsInTheArea, stopsList.count > 0  else {
            tableView.rowHeight = tableView.estimatedRowHeight // Adjusts the row height to bigger message
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Brak przystnaków w promieniu 1km"
            cell.isUserInteractionEnabled = false
            cell.typeImage.image = UIImage(systemName: "exclamationmark.triangle.fill")
            cell.typeImage.isHidden = false
            return cell
        }
        
        //## - If there is at least one stop in the given area this part is executed
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
        cell.label?.text = stopsList[indexPath.row].stopName
        cell.typeImage.isHidden = false
        
        //#### Implemnting the image in the cell
        if stopsList[indexPath.row].type == "tram" {
            cell.typeImage.image = UIImage(systemName: "tram")
        } else if stopsList[indexPath.row].type == "bus" {
            cell.typeImage.image = UIImage(systemName: "bus")
        } else {
            cell.typeImage.image = UIImage(systemName: "face.smiling")
        }

        return cell
    }
}

extension ReportControllerOne: UITableViewDelegate{
    
    //## - Function is triggered when a row is selected and performs segue acordingly
        // -> saves the data about chosen stop in dataManager
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stopsList = dataManagerOne.stopsInTheArea, stopsList.count > 0  else { return }
        dataManagerOne.chosenStopIndex = indexPath.row
        performSegue(withIdentifier: "GoToReportTwo" , sender: self)
    }
    
}


