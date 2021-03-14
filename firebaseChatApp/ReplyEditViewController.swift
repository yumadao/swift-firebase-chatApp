//
//  ReplyEditViewController.swift
//  firebaseChatApp
//
//  Created by 大石優真 on 2021/03/14.
//

import UIKit
import Firebase

class ReplyEditViewController: UIViewController {

    
    var chatroomID:String?
   
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var replyText: UITextField!
    @IBOutlet weak var repButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.placeholder = "名前を入力してください(未入力OK)"
        replyText.placeholder = "本文を入力してください"
        repButton.isEnabled = false
        if UserDefaults.standard.object(forKey: "name") != nil{
            self.nameText.text = UserDefaults.standard.string(forKey: "name")
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    
    @IBAction func replyEditingChanged(_ sender: Any) {
        repButton.isEnabled = !replyText.text!.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    @IBAction func doAction(_ sender: Any) {
        var name = nameText.text!
        if name.trimmingCharacters(in: .whitespaces).isEmpty { name = "匿名" }
        let talk = replyText.text!
        let uid = Auth.auth().currentUser?.uid
        let data = [
            "name":name,
            "msg":talk,
            "createdAt":Timestamp(),
            "uid":uid!
        ] as [String:Any]
        guard let docID = chatroomID else { return }
        Firestore.firestore().collection("chat").document(docID).collection("reply").addDocument(data: data){ err in
            DispatchQueue.main.async {
                if let err = err {
                    print("Error writing document: \(err)")
                } else {
                    self.replyText.text = ""
                }
                UserDefaults.standard.set(name,forKey: "name")
        
        self.navigationController?.popViewController(animated: true)
    }
   }
  }
 }
