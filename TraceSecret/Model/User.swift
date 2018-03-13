//
//  User.swift
//  TraceSecret
//
//  Created by seirra on 2018/3/9.
//  Copyright © 2018年 zz. All rights reserved.
//

import UIKit

@objc protocol UserDelegate : class{
    @objc optional func loginFinishedWithResultof(state:Int)->Void
    @objc optional func registerFinishedWithresultof(state:Int)->Void
    
}

class User: NSObject, BTKTraceDelegate, BTKTrackDelegate {
    weak var delegate: UserDelegate!
    var username:String!
    var password:String!
    var id:String!
    var email:String!
    var headImage:UIImage!
    var isVertified:Bool!
    var registerTime:Date?
    var todayTrace:Trace?
    var recentTrace:[Trace]?
    var records:[Record]?
    var setting:CustomSeting?
    var state:String?
    private var serviceURL:String!
    
    override init() {
        super.init()
        username = ""
        password = ""
        email = ""
        headImage = UIImage()
        id = UIDevice.current.identifierForVendor?.uuidString
        isVertified = false
        serviceURL = "http://47.94.208.122/api/v1.0"
    }
    public func login(){
        let headers = [
            "content-type": "application/json",
            "authorization": "Basic eno6MjAxODAzMTI=",
            "cache-control": "no-cache",
            "postman-token": "0b343b6d-e26f-6f69-53a9-48beafa6eef2"
        ]
        let parameters = [
            "username": username,
            "password": password
            ] as [String : Any]
        
        do{
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let url = URL(string: "http://47.94.208.122/api/v1.0/login")
            let request = NSMutableURLRequest(url: url!,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    NSLog(error.debugDescription)
                    self.state = "网络错误"
                    self.delegate.loginFinishedWithResultof!(state: 0)
                } else {
                    let json = try?JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String: Any]
                    let status = json!["state"] as! Int
                    if status == 2{
                        self.state = "用户名或密码错误！"
                        self.delegate.loginFinishedWithResultof!(state: 0)
                    }else if status == 0{
                        // 登录成功
                        self.state = "登录成功！"
                        // 设置默认登录信息
                        let userDefault = UserDefaults.standard
                        userDefault.set(self.username, forKey: "username")
                        userDefault.set(self.password, forKey: "password")
                        // 解析用户信息
                        self.downImage()
                        let result = json!["result"] as! [String: String]
                        self.id = result["id"]
                        self.email = result["email"]
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        self.registerTime = dateFormatter.date(from: result["registerTime"]!)
                        // 开启轨迹采集
                        let bts:BTKStartServiceOption = BTKStartServiceOption.init(entityName: self.id)
                        BTKAction.sharedInstance().startService(bts, delegate: self)
                        BTKAction.sharedInstance().startGather(self)
                        self.delegate.loginFinishedWithResultof!(state: 1)
                    }else if status == 1{
                        self.state = "用户不存在！"
                        self.delegate.loginFinishedWithResultof!(state: 0)
                    }
                }
            })
            dataTask.resume()
        }
        catch let error{
            NSLog("JSON失败\(error)")
            self.state = "网络错误"
            self.delegate.loginFinishedWithResultof!(state: 0)
        }
    }
    public func register(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let headers = [
            "content-type": "application/json",
            "authorization": "Basic eno6MjAxODAzMTI=",
            "cache-control": "no-cache",
            "postman-token": "0b343b6d-e26f-6f69-53a9-48beafa6eef2"
        ]
        let parameters = [
            "username": username,
            "password": password,
            "id": id,
            "email": email!,
            "registerTime": dateFormatter.string(from: Date())
            ] as [String : Any]
        
        do{
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "http://47.94.208.122/api/v1.0/register")! as URL,
                                              cachePolicy: .useProtocolCachePolicy,
                                              timeoutInterval: 10.0)
            request.httpMethod = "PUT"
            request.allHTTPHeaderFields = headers
            request.httpBody = postData as Data
            let session = URLSession.shared
            let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
                if (error != nil) {
                    NSLog(error.debugDescription)
                    self.state = "网络错误"
                    self.delegate.registerFinishedWithresultof!(state: 0)
                } else {
                    let json = try?JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    let status = json?.object(forKey: "state") as! Int
                    if status != 0{
                        self.state = "用户名已存在！"
                        self.delegate.registerFinishedWithresultof!(state: 0)
                    }else{
                        // 注册成功
                        self.state = "注册成功！"
                        // 上传头像
                        self.uploadImage()
                        self.delegate.registerFinishedWithresultof!(state: 1)
                    }
                }
            })
            dataTask.resume()
        }
        catch let error{
            NSLog("JSON失败\(error)")
            self.state = "网络错误"
            self.delegate.registerFinishedWithresultof!(state: 0)
        }
    }
    public func emailVertify(){
        
    }
    public func getTodayTrace(){
        let endTime = UInt(Date().timeIntervalSince1970)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let yMdFormatter = DateFormatter()
        yMdFormatter.dateFormat = "yyyy-MM-dd"
        let startTime = UInt((dateFormatter.date(from: "\(yMdFormatter.string(from: Date())) 00:00:00")?.timeIntervalSince1970)!)
        let option = BTKQueryTrackProcessOption()
        // 去燥/绑路/保留GPS和WIFI点/步行/抽稀
        option.denoise = true
        option.mapMatch = true
        option.radiusThreshold = 0
        option.transportMode = .TRACK_PROCESS_OPTION_TRANSPORT_MODE_WALKING
        option.vacuate = true
        let request = BTKQueryHistoryTrackRequest(entityName: id, startTime: startTime, endTime: endTime, isProcessed: true, processOption: option, supplementMode: .TRACK_PROCESS_OPTION_SUPPLEMENT_MODE_WALKING, outputCoordType: BTKCoordType.COORDTYPE_BD09LL, sortType: BTKTrackSortType.TRACK_SORT_TYPE_ASC, pageIndex: 1, pageSize: 1000, serviceID: 150540, tag: 1)
        BTKTrackAction.sharedInstance().queryHistoryTrack(with: request, delegate: self)
    }
    public func gethistoryTrace(days:Int){
        
    }
    public func getRecords(){
        
    }
    public func getIdentity(type:Int){
        
    }
    public func editInfomation(){
        
    }
    // BTKTrace Delegate
    func onStartService(_ error: BTKServiceErrorCode) {
        NSLog("轨迹服务开启")
    }
    func onStartGather(_ error: BTKGatherErrorCode) {
        NSLog("开始轨迹采集")
    }
    // BTKTrack Delegate
    func onQueryHistoryTrack(_ response: Data!) {
        
    }
    // 上传和下载图片
    private func uploadImage(){
        let data=UIImagePNGRepresentation(headImage!)//把图片转成data
        let uploadurl:String="http://47.94.208.122/api/v1.0/uploadimage"//设置服务器接收地址
        let request=NSMutableURLRequest(url:URL(string:uploadurl)!)
        request.httpMethod="POST"//设置请求方式
        let boundary:String="-------------------21212222222222222222222"
        let contentType:String="multipart/form-data;boundary="+boundary
        request.addValue(contentType, forHTTPHeaderField:"Content-Type")
        let body=NSMutableData()
        //在表单中写入要上传的图片
        body.append(NSString(format:"--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition:form-data;name=\"headimage\";filename=\"\(self.username!).jpg\"\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        
        //body.appendData(NSString(format:"Content-Type:application/octet-stream\r\n\r\n").dataUsingEncoding(NSUTF8StringEncoding)!)
        body.append("Content-Type:image/png\r\n\r\n".data(using: String.Encoding.utf8)!)
        body.append(data!)
        body.append(NSString(format:"\r\n--\(boundary)--\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        //设置post的请求体
        request.httpBody=body as Data
        let que=OperationQueue()
        NSURLConnection.sendAsynchronousRequest(request as URLRequest, queue: que, completionHandler: {
            (response, data, error) ->Void in
            if (error != nil){
                NSLog("NetWork Unconnected")
                DispatchQueue.main.async(execute: {
                    self.state = "网络异常"
                })
            }else{
                let json = try?JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                let status = json?.object(forKey: "result") as! Int
                if status == 0{
                    NSLog("Upload Failed")
                    DispatchQueue.main.async(execute: {
                        self.state = "上传失败"
                    })
                }
            }
        })
    }
    private func downImage(){
        let url = URL(string: "http://47.94.208.122/api/v1.0/download/\(self.username!).jpg")!
        do{
            let data = try Data(contentsOf: url)
            headImage = UIImage(data: data)
        }catch{
            NSLog("网络错误")
            self.state = "网络异常"
        }
    }
}
