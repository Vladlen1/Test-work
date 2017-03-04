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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let locate = realm.objects(Location.self)
        
        return locate.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! HistoryTableViewCell
        let realm = try! Realm()
        let locate = realm.objects(Location.self)
        
        cell.cityNameLavel?.text = locate[indexPath.row].city
        cell.longitudeLabel?.text = locate[indexPath.row].longitude
        cell.latitudeLabel?.text = locate[indexPath.row].latitude
        cell.dateLabel?.text =  locate[indexPath.row].date

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        changeTabBar(hidden: false, animated: true)

        let realm = try! Realm()
        let locate = realm.objects(Location.self)
        
        let barViewControllers = self.tabBarController?.viewControllers
        let comeBack = barViewControllers![0] as! LocationViewController
        
        comeBack.cityName = locate[indexPath.row].city
        comeBack.latitude = locate[indexPath.row].latitude
        comeBack.longitude = locate[indexPath.row].longitude
        
        tabBarController?.selectedIndex = 0
        
//        var tabIndex = 0
//        
//        if let vc = self.tabBarController?.viewControllers?[tabIndex] as? LocationViewController {
//            vc.latitude = "vv"
//        }
//        self.tabBarController?.selectedIndex = tabIndex
        
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
    
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollView.panGestureRecognizer.translation(in: scrollView).y < 0{
            changeTabBar(hidden: true, animated: true)
        }
        else{
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
                                       completion: {
                                        print($0)
                                        if $0 {tabBar?.isHidden = hidden}
            })
        }
    }


//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        let realm = try! Realm()
//        let locate = realm.objects(Location.self)
//        
//        if segue.identifier == "LocateSegue" {
//            if let comeBack = segue.destination as? LocationViewController {
//                comeBack.cityName = locate[selectionCell].city
//                comeBack.latitude = locate[selectionCell].latitude
//                comeBack.longitude = locate[selectionCell].longitude
//            }
//        }
//    }
    
}
