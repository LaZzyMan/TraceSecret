//
//  LoginViewController.swift
//  TraceSecret
//
//  Created by seirra on 2018/3/9.
//  Copyright © 2018年 zz. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate, UserDelegate {

    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var waitLabel: UIActivityIndicatorView!
    var user:User?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 初始化
        user = User()
        user?.delegate = self
        passwordTextField.isSecureTextEntry = true
        // 检查用户历史登录信息
        if let username = UserDefaults.standard.string(forKey: "username"){
            // 存在默认信息则直接登录
            let password = UserDefaults.standard.string(forKey: "password")
            user?.username = username
            user?.password = password
            user?.state = "密码已变更"
            DispatchQueue.main.async {
                self.user?.login()
            }
        }
        // 添加键盘信息监听
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillShow, object: nil, queue: nil, using: keyboardWillChange(_:))
        NotificationCenter.default.addObserver(forName: Notification.Name.UIKeyboardWillHide, object: nil, queue: nil, using: keyboardWillChange(_:))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // keyboard delegate
    func keyboardWillChange(_ note:Notification){
        /*
        let duration:Double = note.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! Double
        if note.name == .UIKeyboardWillShow{
            UIView.animate(withDuration: duration, animations: {
                self.view.frame.origin.y = -220
            })
        }else{
            UIView.animate(withDuration: duration, animations: {
                self.view.frame.origin.y = 0
            })
        }
 */
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
        user?.username = username
        user?.password = password
        DispatchQueue.main.async {
            self.user?.login()
        }
    }
    
    @IBAction func onRegisterBtnClick(_ sender: Any) {
        self.performSegue(withIdentifier: "register", sender: self)
    }
    // User Delegate
    func loginFinishedWithResultof(state: Int) {
        self.waitLabel.stopAnimating()
        if state == 1{
            self.performSegue(withIdentifier: "login", sender: self)
        }else{
            self.errorLabel.text = self.user?.state
            self.errorLabel.isHidden = false
            self.passwordTextField.text = ""
        }
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
