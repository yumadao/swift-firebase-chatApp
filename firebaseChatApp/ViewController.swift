//
//  ViewController.swift
//  firebaseChatApp
//
//  Created by 大石優真 on 2021/03/14.
//

import UIKit
import Firebase

var chat:CollectionReference!
var blockList:[String] = []

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource{
    
    
    var messages = [ChatRoom]()
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var firestore = Firestore.firestore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableView.automaticDimension
        tableView.tableFooterView = UIView()
        print("ブロックリスト:",blockList)
        
        
        if UserDefaults.standard.object(forKey: "blocked") != nil{
            blockList = UserDefaults.standard.stringArray(forKey: "blocked") ?? []
        }
        print("ユーザーID",Auth.auth().currentUser?.uid ?? "not user")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
        chat = firestore.collection("chat")
        chat.order(by: "createdAt", descending: true).addSnapshotListener { snapshot, e in
                if let snapshot = snapshot{
                    self.messages.removeAll()
                    snapshot.documentChanges.forEach({(documentChange) in
                        switch documentChange.type{
                        case .added:
                            let dic = documentChange.document.data()
                            let chatroom = ChatRoom(dic: dic)
                            chatroom.documentId = documentChange.document.documentID
                            self.messages.append(chatroom)
                        case .modified , .removed:
                            print("nothing to do ")
                        }
                    })
                    self.tableView.reloadData()
                }
            }
        }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toRep"{
            guard let index = self.tableView.indexPathForSelectedRow?.row else { return }
            let docID = messages.filter{v in !blockList.contains(v.uid)}[index].documentId
            let nextView = segue.destination as! ReplyViewController
            nextView.chatroomID = docID
        }
    }
    
    
    @IBAction func toEdit(_ sender: Any) {
        self.performSegue(withIdentifier: "toEdit", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.filter{v in !blockList.contains(v.uid)}.count
    }
    

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 80
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chatCell", for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.detailTextLabel?.numberOfLines = 0
        
        let result = messages.filter{v in !blockList.contains(v.uid)}
        print("UIDresults:",result)
        
        let dateVal = result[indexPath.row].createdAt.dateValue()
        let f = DateFormatter()
        f.locale = Locale(identifier: "ja_JP")
        f.dateStyle = .medium
        f.timeStyle = .short
        let date = f.string(from: dateVal)
        print("messages:",self.messages)
        cell.textLabel?.text = result[indexPath.row].msg
            cell.detailTextLabel?.text = "\(result[indexPath.row].name):\(date)"
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let selectedRow = self.messages.filter{v in !blockList.contains(v.uid)}[indexPath.row]
        
        let Action = UIContextualAction(style: .normal, title: "…"){(action,view,success) in
            let ActionSheet = UIAlertController(title: "投稿者ID", message: selectedRow.uid, preferredStyle: .actionSheet)
            let cancel = UIAlertAction(title: "閉じる", style: .cancel, handler: nil)
            let block = UIAlertAction(title: "投稿者をブロック", style: .destructive, handler: {(action:UIAlertAction) -> Void in
                blockList.append(selectedRow.uid)
                UserDefaults.standard.set(blockList,forKey: "blocked")
                print(blockList)
                tableView.reloadData()
                let alert = UIAlertController(title: "ユーザーID:\(selectedRow.uid)", message: "このユーザーをブロックしました。", preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                          self.present(alert, animated: true, completion: nil)
            })
            let report = UIAlertAction(title: "投稿を通報する", style: .destructive, handler: {(action:UIAlertAction) -> Void in
                let data = [
                    "uid":selectedRow.uid,
                    "reportedAt":Timestamp(),
                    "msg":selectedRow.msg
                ] as [String:Any]
                Firestore.firestore().collection("reported").addDocument(data: data){ err in
                    DispatchQueue.main.async {
                        if let err = err {
                            print("Error writing document: \(err)")
                        } else {
                            
                    }
                  }
                 }
                let alert = UIAlertController(title: selectedRow.msg, message: "この投稿を通報しました。", preferredStyle: .alert)
                           alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                           self.present(alert, animated: true, completion: nil)
            })
            ActionSheet.addAction(block)
            ActionSheet.addAction(report)
            ActionSheet.addAction(cancel)
            self.present(ActionSheet, animated: true, completion: nil)
            
            success(true)
        }
        Action.backgroundColor = .systemGray4
        return UISwipeActionsConfiguration(actions: [Action])
            }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "toRep", sender: nil)
    }
}


