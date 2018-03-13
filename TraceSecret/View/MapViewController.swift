//
//  MapViewController.swift
//  TraceSecret
//
//  Created by seirra on 2018/3/9.
//  Copyright © 2018年 zz. All rights reserved.
//

import UIKit

class MapViewController: UIViewController,BMKMapViewDelegate,BMKLocationServiceDelegate {
    @IBOutlet weak var waitProgressBar: UIActivityIndicatorView!
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var mapView: UIView!
    var user:User!
    var locationService:BMKLocationService!
    var currentLocation:CLLocationCoordinate2D!
    var map:BMKMapView!
    var isWaiting:Bool!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 获得用户信息
        user = (self.navigationController?.topViewController as! TabBarViewController).user
        isWaiting = true
        // 初始化地图
        let stylePath = Bundle.main.path(forResource: "mapConfigBlack", ofType: "")
        BMKMapView.customMapStyle(stylePath)
        BMKMapView.enableCustomMapStyle(true)
        map = BMKMapView(frame: mapView.frame)
        map.isBuildingsEnabled = true
        map.userTrackingMode = BMKUserTrackingModeFollow
        map.isZoomEnabled = true
        map.isOverlookEnabled = true
        mapView.addSubview(map)
        // 获取当前定位
        locationService=BMKLocationService()
        DispatchQueue.main.async {
            self.locationService.startUserLocationService()
        }
        // 获取用户轨迹
        DispatchQueue.main.async {
            self.user.getTodayTrace()
        }
        // 在地图上绘制轨迹
    }
    override func viewWillAppear(_ animated: Bool) {
        map.delegate = self
        locationService.delegate=self
    }
    override func viewWillDisappear(_ animated: Bool) {
        map.delegate = nil
        locationService.delegate=nil
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        map.region = BMKCoordinateRegionMake(map.centerCoordinate, BMKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02))
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 得到定位信息
    func didUpdate(_ userLocation: BMKUserLocation!) {
        map.updateLocationData(userLocation)
        if !isWaiting{
            // 结束等待
            UIView.animate(withDuration: 0.5, animations: {
                self.waitProgressBar.stopAnimating()
                self.waitView.center.y -= self.view.bounds.height
            })
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
