//
//  MapViewController.swift
//  TraceSecret
//
//  Created by seirra on 2018/3/9.
//  Copyright © 2018年 zz. All rights reserved.
//

import UIKit

class MapViewController: UIViewController,BMKMapViewDelegate,BMKLocationServiceDelegate {
    @IBOutlet weak var waitView: UIView!
    @IBOutlet weak var mapView: UIView!
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 获得用户信息
        user = (self.navigationController?.topViewController as! TabBarViewController).user
        // 初始化地图
        // 获取当前定位
        // 获取用户轨迹
        // 在地图上绘制轨迹
        // 显示地图
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
