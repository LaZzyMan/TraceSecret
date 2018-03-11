//
//  LoginViewController.swift
//  TraceSecret
//
//  Created by seirra on 2018/3/9.
//  Copyright © 2018年 zz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var waitLabel: UIActivityIndicatorView!
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 检查用户历史登录信息
        if let username = UserDefaults.standard.string(forKey: "username"){
            // 存在默认信息则直接登录
            let password = UserDefaults.standard.string(forKey: "password")
            user = User()
            user?.username = username
            user?.password = password
            DispatchQueue.main.async {
                self.user?.login()
                if (self.user?.isLogined)!{
                    self.performSegue(withIdentifier: "login", sender: self)
                }else{
                    // 提示密码已被修改，要求重新登录
                    NSLog("密码已更改")
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // TextField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    // button action
    @IBAction func onLoginBtnClicked(_ sender: Any) {
        self.waitLabel.startAnimating()
        let username = self.usernameTextField.text
        let password = self.passwordTextField.text
        self.user = User()
        user?.username = username
        user?.password = password
        DispatchQueue.main.async {
            self.user?.login()
            if (self.user?.isLogined)!{
                self.waitLabel.stopAnimating()
                self.performSegue(withIdentifier: "login", sender: self)
            }
        }
    }
    
    @IBAction func onRegisterBtnClick(_ sender: Any) {
        self.performSegue(withIdentifier: "register", sender: self)
    }
    // prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "login"{
            if let a = segue.destination as? TabBarViewController{
                a.user = user
            }else{
                NSLog("user传递失败")
            }
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
