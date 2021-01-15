//
//  ReportControllerOne.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit

class ReportControllerOne: UIViewController {
    
    var reportCoortdinates: String?
    var stops: [Stop]?
    var chosenStopIndex: Int?

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
            if let stopsList = stops, let index = chosenStopIndex{
                destinationVC.linesList = stopsList[index].lines
                destinationVC.stopName = stopsList[index].stopName
            }
        }
    }
    
   
}

extension ReportControllerOne: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stopsList = stops, stopsList.count > 0  else { return 1 }
        
        return stopsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stopsList = stops, stopsList.count > 0  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Brak przystnaków w promieniu 1km"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
        cell.label?.text = stopsList[indexPath.row].stopName
        return cell
    }
    
}

extension ReportControllerOne: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let stopsList = stops, stopsList.count > 0  else { return }
//        SEARCH ON GOOGLE
//        let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
//        tableView.cellForRow(at: indexPath)?.labelBubble.layer
//        tableView.cellForRow(at: indexPath)?.contentView.backgroundColor = UIColor.systemYellow
        chosenStopIndex = indexPath.row
        performSegue(withIdentifier: "GoToReportTwo" , sender: self)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
//        tableView.cellForRow(at: indexPath)?.backgroundColor = UIColor.white
    }
}


