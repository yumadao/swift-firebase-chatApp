//
//  editViewController.swift
//  firebaseChatApp
//
//  Created by 大石優真 on 2021/03/14.
//

import UIKit
import Firebase

class EditViewController: UIViewController {

    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var button: UIBarButtonItem!
    @IBOutlet weak var talkText: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.placeholder = "名前を入力してください(未入力OK)"
        talkText.placeholder = "本文を入力してください"
        button.isEnabled = false
        
        if UserDefaults.standard.object(forKey: "name") != nil{
            self.nameText.text = UserDefaults.standard.string(forKey: "name")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func textEditingChanged(_ sender: Any) {
        button.isEnabled = !talkText.text!.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @IBAction func doAction(_ sender: Any) {
        var name = nameText.text!
        if name.trimmingCharacters(in: .whitespaces).isEmpty{ name = "匿名" }
        let talk = talkText.text!
        let uid = Auth.auth().currentUser?.uid
        let data = [
            "name":name,
            "msg":talk,
            "createdAt":Timestamp(),
            "uid":uid ?? ""
        ] as [String:Any]
        chat.addDocument(data: data){ err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.talkText.text = ""
                }
                UserDefaults.standard.set(name,forKey: "name")
        
        self.navigationController?.popViewController(animated: true)
    }
   }
  }
}

