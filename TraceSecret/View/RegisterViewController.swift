//
//  RegisterViewController.swift
//  TraceSecret
//
//  Created by seirra on 2018/3/9.
//  Copyright © 2018年 zz. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UserDelegate {

    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var usernameView: UIView!
    @IBOutlet weak var finishView: UIView!
    @IBOutlet weak var headImage: UIImageView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var waitProgressBar: UIActivityIndicatorView!
    @IBOutlet weak var finishLabel: UILabel!
    @IBOutlet weak var finishBtn: UIButton!
    var newUser: User?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // 三个页面调整位置
        usernameView.center.x += self.view.bounds.width
        finishView.center.x += self.view.bounds.width*2
        // 初始化
        newUser = User()
        newUser?.delegate = self
        emailTextField.delegate = self
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        headImage.isUserInteractionEnabled = true
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.chooseFromPhotos(_:)))
        headImage.addGestureRecognizer(tapGR)
        // UI调整
        headImage.layer.masksToBounds = true
        headImage.layer.cornerRadius = headImage.bounds.width/2
        headImage.layer.borderWidth = 2
        headImage.layer.borderColor = UIColor.gray.cgColor
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    // 按键响应
    @IBAction func emailViewToUsernameView(_ sender: Any) {
        // 检查电子邮件地址合法
        
        // 更新User
        self.newUser?.email = self.emailTextField.text
        // 更新UI
        UIView.animate(withDuration: 0.5, animations: {
            self.emailView.center.x -= self.view.bounds.width
            self.usernameView.center.x -= self.view.bounds.width
            self.finishView.center.x -= self.view.bounds.width
        })
    }
    @IBAction func usernameTextFieldToFinsihView(_ sender: Any) {
        // 检查用户名密码合法性
        
        // 更新User
        self.newUser?.username = self.usernameTextField.text
        self.newUser?.password = self.passwordTextField.text
        // 更新UI
        self.finishLabel.isHidden = true
        self.waitProgressBar.startAnimating()
        self.finishBtn.isHidden = true
        UIView.animate(withDuration: 0.5, animations: {
            self.emailView.center.x -= self.view.bounds.width
            self.usernameView.center.x -= self.view.bounds.width
            self.finishView.center.x -= self.view.bounds.width
        })
        // 向服务器完成注册
        DispatchQueue.main.async {
            self.newUser?.register()
        }
    }
    @IBAction func finish(_ sender: Any) {
        DispatchQueue.main.async {
            self.newUser?.login()
        }
    }
    // prepare
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "registerFinished"{
            if let a = segue.destination as? TabBarViewController{
                a.user = newUser
            }else{
                NSLog("user传递失败")
            }
        }else{
            NSLog("错误的identifier")
        }
    }
    // User Delegate
    func registerFinishedWithresultof(state: Int) {
        if state == 1{
            self.waitProgressBar.stopAnimating()
            self.finishLabel.isHidden = false
            self.finishBtn.isHidden = false
        }
    }
    func loginFinishedWithResultof(state: Int) {
        if state == 1{
            self.performSegue(withIdentifier: "registerFinished", sender: self)
        }
    }
    // textField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        emailTextField.resignFirstResponder()
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
    // 相片选择弹出框
    @objc func chooseFromPhotos(_ sender: Any) {
        let actionSheet = UIAlertController(title: "上传头像", message: nil, preferredStyle: .actionSheet)
        let cancelBtn = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        let takePhotos = UIAlertAction(title: "拍照", style: .default, handler: {
            (action: UIAlertAction) -> Void in
            //判断是否能进行拍照，可以的话打开相机
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }
            else
            {
                NSLog("相机不可用");
            }
        })
        let selectPhotos = UIAlertAction(title: "相册选取", style: .default, handler: {
            (action:UIAlertAction)
            -> Void in
            //调用相册功能，打开相册
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                picker.allowsEditing = true
                self.present(picker, animated: true, completion: nil)
            }else{
                NSLog("相册不可用")
            }
        })
        actionSheet.addAction(cancelBtn)
        actionSheet.addAction(takePhotos)
        actionSheet.addAction(selectPhotos)
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let type: String = (info[UIImagePickerControllerMediaType] as! String)
        //当选择的类型是图片
        if type == "public.image"
        {
            picker.dismiss(animated: true, completion: (
                {
                    let image = self.fixOrientation((info[UIImagePickerControllerOriginalImage] as! UIImage))
                    self.newUser?.headImage = image
                    self.headImage.image = image
                    
                }
            ))
        }
    }
    
    func fixOrientation(_ aImage: UIImage) -> UIImage {
        if aImage.imageOrientation == .up {
            return aImage
        }
        var transform: CGAffineTransform = CGAffineTransform.identity
        switch aImage.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.rotated(by: CGFloat(Double.pi/2))
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: aImage.size.height)
            transform = transform.rotated(by: CGFloat(-Double.pi/2))
        default:
            break
        }
        switch aImage.imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: aImage.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: aImage.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        let ctx: CGContext = CGContext(data: nil, width: Int(aImage.size.width), height: Int(aImage.size.height), bitsPerComponent: aImage.cgImage!.bitsPerComponent, bytesPerRow: 0, space: aImage.cgImage!.colorSpace!, bitmapInfo: aImage.cgImage!.bitmapInfo.rawValue)!
        ctx.concatenate(transform)
        switch aImage.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            // Grr...
            ctx.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.height, height: aImage.size.width))
        default:
            ctx.draw(aImage.cgImage!, in: CGRect(x: 0, y: 0, width: aImage.size.width, height: aImage.size.height))
        }
        let cgimg: CGImage = ctx.makeImage()!
        let img: UIImage = UIImage(cgImage: cgimg)
        return img
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
