//
//  User.swift
//  TraceSecret
//
//  Created by seirra on 2018/3/9.
//  Copyright © 2018年 zz. All rights reserved.
//

import UIKit

class User: NSObject, BTKTraceDelegate {
    var username:String!
    var password:String!
    var id:String!
    var email:String!
    var headImage:UIImage!
    var isRegistered:Bool!
    var isLogined:Bool!
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
        isRegistered = false
        isVertified = false
        isLogined = false
        serviceURL = "http://10.127.135.254:8080"
    }
    public func login(){
        let headers = [
            "authorization": "Basic eGp5OjIwMTcwNzI0",
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "ee43bdf3-ee2a-7154-7594-1a0a63de0eb1"
        ]
        let parameters = [
            "username": username,
            "password": password
            ] as [String : Any]
        
        do{
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "\(serviceURL)/login")! as URL,
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
                } else {
                    let json = try?JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    let status = json?.object(forKey: "result") as! String
                    if status != "True"{
                        self.state = "用户名或密码错误！"
                    }else{
                        // 登录成功
                        self.isLogined = true
                        self.state = "ok"
                        // 设置默认登录信息
                        let userDefault = UserDefaults.standard
                        userDefault.set(self.username, forKey: "username")
                        userDefault.set(self.password, forKey: "password")
                        // 解析用户信息
                        self.downImage()
                        self.id = json?.object(forKey:"id") as! String
                        self.email = json?.object(forKey: "email") as! String
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd"
                        self.registerTime = dateFormatter.date(from: json?.object(forKey: "registerTime") as! String)
                        // 开启轨迹采集
                        let bts:BTKStartServiceOption = BTKStartServiceOption.init(entityName: self.id)
                        BTKAction.sharedInstance().startService(bts, delegate: self)
                        BTKAction.sharedInstance().startGather(self)
                    }
                }
            })
            dataTask.resume()
        }
        catch let error{
            NSLog("JSON失败\(error)")
            self.state = "网络错误"
        }
    }
    public func register(){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let headers = [
            "authorization": "Basic eGp5OjIwMTcwNzI0",
            "content-type": "application/json",
            "cache-control": "no-cache",
            "postman-token": "ee43bdf3-ee2a-7154-7594-1a0a63de0eb1"
        ]
        let parameters = [
            "username": username,
            "password": password,
            "email": email!,
            "registerTime": dateFormatter.string(from: Date())
            ] as [String : Any]
        
        do{
            let postData = try JSONSerialization.data(withJSONObject: parameters, options: [])
            let request = NSMutableURLRequest(url: NSURL(string: "\(serviceURL)/register")! as URL,
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
                } else {
                    let json = try?JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as AnyObject
                    let status = json?.object(forKey: "result") as! String
                    if status != "True"{
                        self.state = "用户名或密码错误！"
                    }else{
                        // 注册成功
                        self.isRegistered = true
                        self.state = "ok"
                        // 上传头像
                        DispatchQueue.main.async {
                            self.uploadImage()
                        }
                    }
                }
            })
            dataTask.resume()
        }
        catch let error{
            NSLog("JSON失败\(error)")
            self.state = "网络错误"
        }
    }
    public func emailVertify(){
        
    }
    public func getTodayTrace(){
        
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
    // 上传和下载图片
    private func uploadImage(){
        let data=UIImagePNGRepresentation(headImage!)//把图片转成data
        let uploadurl:String="http://www.sgmy.site/api/v2.0/uploadimage"//设置服务器接收地址
        let request=NSMutableURLRequest(url:URL(string:uploadurl)!)
        request.httpMethod="POST"//设置请求方式
        let boundary:String="-------------------21212222222222222222222"
        let contentType:String="multipart/form-data;boundary="+boundary
        request.addValue(contentType, forHTTPHeaderField:"Content-Type")
        let body=NSMutableData()
        //在表单中写入要上传的图片
        body.append(NSString(format:"--\(boundary)\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        body.append(NSString(format:"Content-Disposition:form-data;name=\"headimage\";filename=\"\(username).jpg\"\r\n" as NSString).data(using: String.Encoding.utf8.rawValue)!)
        
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
                        self.state = "网络异常"
                    })
                }
            }
        })
    }
    private func downImage(){
        let url = URL(string: "\(serviceURL)download/"+username+".jpg")!
        do{
            let data = try Data(contentsOf: url)
            headImage = UIImage(data: data)
        }catch{
            NSLog("网络错误")
            self.state = "网络异常"
        }
    }
}
