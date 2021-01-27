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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "GoToReportThree"{
            let destinationVC = segue.destination as! ReportControllerThree
            if let lines = reportManagerTwo.linesList, let index = reportManagerTwo.chosenLineIndex, let stopName = reportManagerTwo.stopName{
                destinationVC.reportManagerThree.lineNr = lines[index]
                destinationVC.reportManagerThree.chosenStopName = stopName

            }
        }
    }

}

//MARK: - TableView-related Methods
extension ReportControllerTwo: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let lines = reportManagerTwo.linesList, lines.count > 0 else {return 1}
        
        return lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let lines = reportManagerTwo.linesList, lines.count > 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
            cell.label?.text = "Błąd - brak lini do wyświetlenia"
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.CustomCell.identifier, for: indexPath) as! CustomCell
        cell.label?.text = "\(lines[indexPath.row])"
        return cell
    }
    
}

extension ReportControllerTwo: UITableViewDelegate{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let lines = reportManagerTwo.linesList, lines.count > 0 else {return}
        
        if let cell = tableView.cellForRow(at: indexPath) as? CustomCell {
            cell.setSelected(true, animated: true)
        }
        reportManagerTwo.chosenLineIndex = indexPath.row
        performSegue(withIdentifier: "GoToReportThree" , sender: self)
    }
    
}
