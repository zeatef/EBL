//
//  AllPlayersViewController.swift
//  EBL-Test
//
//  Created by Zeyad Atef on 2/2/20.
//  Copyright © 2020 Zeyad Atef. All rights reserved.
//

import UIKit
import Firebase
import SideMenu
import Kingfisher

class AllPlayersViewController: UIViewController {

    @IBOutlet weak var allPlayersTableView: UITableView!
    
    let dbManager = DatabaseManager.sharedInstance
    var playersArray : [Player] = []
    var selectedPlayerIndex : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewController()
    }

    func setupViewController() {
        dbManager.getAllPlayersInfo(source: .cache) { (players, error) in
            if let error = error {
                print(error)
            } else {
                self.playersArray = players!
                self.allPlayersTableView.reloadData()
                print(self.playersArray.count)
            }
        }
        //Register AllTeamsCell custom Cells

        allPlayersTableView.register(UINib(nibName: "AllTeamsCell", bundle: nil) , forCellReuseIdentifier: "AllTeamsCell")

    }
}

extension AllPlayersViewController : UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension AllPlayersViewController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "All Players (Season 2018/2019)"
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor(hexString: "595959")
            header.textLabel?.textColor = UIColor(hexString: "a3a3a3")
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return playersArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = allPlayersTableView.dequeueReusableCell(withIdentifier: "AllTeamsCell", for: indexPath) as? AllTeamsCell else {
            return UITableViewCell()
        }
        cell.teamName.text = playersArray[indexPath.row].knownAs.first + " " + playersArray[indexPath.row].knownAs.last
        cell.teamImage.image = UIImage(named: "player")
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(hexString: "2b2b2b")
        cell.selectedBackgroundView = backgroundView

        return cell
    }
}
