//
//  TeamPickerViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/3/19.
//  Copyright © 2019 Zeyad Atef. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import Kingfisher

class AllTeamsViewController: UIViewController {
    
    @IBOutlet weak var allTeamTableView: UITableView!
    
    let dbManager = DatabaseManager.sharedInstance
    
    var teamsArray : [TeamDisplayData] = []
    var selectedTeamIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }
    
    func setupViewController(){
        
        //Setup All Teams Array from Database
        teamsArray = dbManager.teamsDisplayData
        
        //Register AllTeamsCell custom Cells
        allTeamTableView.register(UINib(nibName: "AllTeamsCell", bundle: nil) , forCellReuseIdentifier: "AllTeamsCell")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(segue.identifier == "goToTeamOverview") {
            let destination = segue.destination as! TeamsViewController
            destination.team = teamsArray[selectedTeamIndex]
        }
    }
}

extension AllTeamsViewController : UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension AllTeamsViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All Teams"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor(hexString: "595959")
            header.textLabel?.textColor = UIColor(hexString: "a3a3a3")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return teamsArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = allTeamTableView.dequeueReusableCell(withIdentifier: "AllTeamsCell", for: indexPath) as? AllTeamsCell else {
            return UITableViewCell()
        }
        cell.teamName.text = teamsArray[indexPath.row].teamName
        cell.teamID = teamsArray[indexPath.row].teamID
        cell.teamImage.kf.setImage(with: dbManager.getTeamImageURL(teamID: teamsArray[indexPath.row].teamID))
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "2b2b2b")
        cell.selectedBackgroundView = backgroundView

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTeamIndex = indexPath.row
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "goToTeamOverview", sender: self)
    }
}
