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
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportTwo"{
            let destinationVC = segue.destination as! ReportControllerTwo
            if let stopsList = reportManagerOne.stopsInTheArea, let index = reportManagerOne.chosenStopIndex{
                destinationVC.reportManagerTwo.linesList = stopsList[index].lines
                destinationVC.reportManagerTwo.stopName = stopsList[index].stopName
                
            }
        }
    }

}

//MARK: - TableView-related Methods

extension ReportControllerOne: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stopsList = reportManagerOne.stopsInTheArea, stopsList.count > 0  else { return 1 }
        
        return stopsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stopsList = reportManagerOne.stopsInTheArea, stopsList.count > 0  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Brak przystnaków w promieniu 1km"
            return cell
        }
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stopsList = reportManagerOne.stopsInTheArea, stopsList.count > 0  else { return }

        if let cell = tableView.cellForRow(at: indexPath) as? CustomCell {
            cell.setSelected(true, animated: true)
        }
        reportManagerOne.chosenStopIndex = indexPath.row
        performSegue(withIdentifier: "GoToReportTwo" , sender: self)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomCell {
            cell.setSelected(false, animated: true)
        }
    }
}


