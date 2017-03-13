//
//  HistoryViewController.swift
//  Test
//
//  Created by Влад Бирюков on 03.03.17.
//  Copyright © 2017 Влад Бирюков. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    
    @IBOutlet weak var tableView: UITableView!
    
    var lastOffsetY :CGFloat = 0

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let location = realm.objects(Location.self)
        
        return location.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryTableViewCell
        let realm = try! Realm()
        let location = realm.objects(Location.self)
        
        cell.cityNameLavel?.text = location[indexPath.row].city
        cell.longitudeLabel?.text = location[indexPath.row].longitude
        cell.latitudeLabel?.text = location[indexPath.row].latitude
        cell.dateLabel?.text =  location[indexPath.row].date

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeTabBar(hidden: false, animated: true)

        let realm = try! Realm()
        let location = realm.objects(Location.self)
        
        let barViewControllers = self.tabBarController?.viewControllers
        let locationController = barViewControllers![0] as! LocationViewController
        
        locationController.cityName = location[indexPath.row].city
        locationController.latitude = location[indexPath.row].latitude
        locationController.longitude = location[indexPath.row].longitude
        
        tabBarController?.selectedIndex = 0
        
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        
    }
    
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete", handler: { (actin, indexPath) -> Void in
            
            let realm = try! Realm()
            
            let keys = realm.objects(Location.self)
            try! realm.write {
                realm.delete(keys[indexPath.row])
            }
            
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.reloadData()
            
        })
        return [deleteAction]
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView){
        lastOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView){
        if scrollView.contentOffset.y > self.lastOffsetY{
            changeTabBar(hidden: true, animated: true)

        }else{
            changeTabBar(hidden: false, animated: true)

        }
        
    }
    
    func changeTabBar(hidden:Bool, animated: Bool){
        let tabBar = self.tabBarController?.tabBar
        if tabBar!.isHidden == hidden{ return }
        let frame = tabBar?.frame
        let offset = (hidden ? (frame?.size.height)! : -(frame?.size.height)!)
        let duration:TimeInterval = (animated ? 0.5 : 0.0)
        tabBar?.isHidden = false
        if frame != nil
        {
            UIView.animate(withDuration: duration,
                           animations: {tabBar!.frame = frame!.offsetBy(dx: 0, dy: offset)},
                           completion: { if $0 {tabBar?.isHidden = hidden}
            })
        }
    }
}


