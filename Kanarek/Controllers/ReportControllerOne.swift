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
//    var stopIndex: Int?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //
    }
    
   
}

extension ReportControllerOne: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stopsList = stops  else { return 0 }
        return stopsList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let stopsList = stops  else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Przystanek"
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
        cell.label?.text = stopsList[indexPath.row].stopName
        return cell
    }
    
}

extension ReportControllerOne: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        stopIndex = indexPath.row
        
        performSegue(withIdentifier: "GoToReportTwo" , sender: self)
    }
}


