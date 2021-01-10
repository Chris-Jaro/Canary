//
//  ReportControllerThree.swift
//  Kanarek
//
//  Created by Chris Yarosh on 24/11/2020.
//

import UIKit
import Firebase

class ReportControllerThree: UIViewController {
    
    let db = Firestore.firestore()
    
    var directions: [String] = []
    
    var chosenLineNr: Int?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: K.CustomCell.nibName, bundle: nil), forCellReuseIdentifier: K.CustomCell.identifier)

        guard let lineNumber = chosenLineNr else { return }

        loadLineDirections(for: lineNumber)
    }
    

    @IBAction func reportButtonPressed(_ sender: UIButton) {
        
        navigationController?.popToRootViewController(animated: true)
    }
    
//MARK: - Database-related Functions
    
    //#### Provides a list of a line directions
    func loadLineDirections(for chosenLineNumber: Int){
        db.collectionGroup(K.FirebaseQuery.linesCollectionName)
            .whereField(K.FirebaseQuery.lineNumber, isEqualTo: chosenLineNumber)
            .addSnapshotListener { (querySnapshot, error) in
                self.directions = []
                if let e = error {
                    print("There was an issue recieving data from firestore, \(e)")
                } else {
                    if let snapshotDocuments = querySnapshot?.documents {
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let lineDirections = data[K.FirebaseQuery.directions] as? [String]{
                               self.directions.append(contentsOf: lineDirections)
                            }
                        }
                        print(self.directions)
                        self.tableView.reloadData()
                    }
                }
            }
    }
    
    //#### - Updates status variable of a stop in the database
    func updatePointStatus(stopName: String, status: Bool, direction: String) {
        db.collection(K.FirebaseQuery.stopsCollectionName).document(stopName).setData([K.FirebaseQuery.status: status,
                                                                                       K.FirebaseQuery.date: Date.timeIntervalSinceReferenceDate,
                                                                                      K.FirebaseQuery.direction: direction], merge: true)
    }

}

extension ReportControllerThree: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if directions.count > 0{
            return directions.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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

extension ReportControllerThree: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    }
}
