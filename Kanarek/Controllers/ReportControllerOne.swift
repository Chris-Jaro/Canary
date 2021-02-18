//
//  ReportControllerOne.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerOne: UIViewController {
    
    var reportManagerOne = ReportManager()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 80
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportTwo"{
            let destinationVC = segue.destination as! ReportControllerTwo
            if let stopsList = reportManagerOne.stopsInTheArea, let index = reportManagerOne.chosenStopIndex{
                destinationVC.reportManagerTwo.linesList = filterLineNumbers(lines: stopsList[index].lines)
                destinationVC.reportManagerTwo.stopName = stopsList[index].stopName
                
            }
        }
    }
    
    //Function that filters the line numbers depending on the hour of the day (night/day lines) #### MOVE TO MANAGER
    func filterLineNumbers(lines: [Int]) -> [Int] {
        //Accessing the current hour of the device
        let now = Calendar.current.dateComponents(in: .current, from: Date())
        if let currentHour = now.hour {
            /*
             A -> If currentHour is between <5:00-22:00) -> We have day
             B -> if currentHour is between <22:00-00:00) + <04:00-05:00)  -> We have day&night
             C -> if currentHour is between <00:00-04:00) -> We have night
             */
            
            if 5 <= currentHour && currentHour < 22 {
//              --A--
                var filterdLines = [Int]()
                lines.forEach { (line) in
                    if line < 200 || line >= 300{
                        filterdLines.append(line)
                    }
                }
                return filterdLines
                
            } else if 0 <= currentHour && currentHour < 4 {
//              --B--
                var filterdLines = [Int]()
                lines.forEach { (line) in
                    if line >= 200 && line < 300{
                        filterdLines.append(line)
                    }
                }
                return filterdLines
        
            } else {
//              --C--
                return lines
            }

        } else {
            print("Could not get device's current hour -> Night Lines")
            return lines // If there is a problem loading the time
        }
    }

}

//MARK: - TableView-related Methods
extension ReportControllerOne: UITableViewDataSource{
    
    //#### - Function returns number of rows to be displayed on the TableView (if there is nothing to displayed error message will be displayed)
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stopsList = reportManagerOne.stopsInTheArea, stopsList.count > 0  else { return 1 }
        
        return stopsList.count
    }
    
    //#### - Functions determins exactly what is to be displayed on every cell one by one
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //## - This guard is executed if there are no stops in the 1km area from the user AND displays a message accordingly
        guard let stopsList = reportManagerOne.stopsInTheArea, stopsList.count > 0  else {
            tableView.rowHeight = tableView.estimatedRowHeight
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
    
    //#### - Function is triggered when a row is selected and performs segue acordingly
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stopsList = reportManagerOne.stopsInTheArea, stopsList.count > 0  else { return }

        reportManagerOne.chosenStopIndex = indexPath.row
        performSegue(withIdentifier: "GoToReportTwo" , sender: self)
    }
    
}


