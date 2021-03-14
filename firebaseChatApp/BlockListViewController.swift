//
//  BlockListViewController.swift
//  firebaseChatApp
//
//  Created by 大石優真 on 2021/03/14.
//

import UIKit
import Firebase

class BlockListViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blockCell", for: indexPath)
        cell.textLabel?.text = blockList[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "解除"){(action, view , sucsess) in
            blockList.remove(at: indexPath.row)
            UserDefaults.standard.set(blockList,forKey: "blocked")
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            let alert = UIAlertController(title: "", message: "ブロックを解除しました。", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)

            sucsess(true)
                }
        deleteAction.backgroundColor = .red
        tableView.reloadData()
        return UISwipeActionsConfiguration(actions: [deleteAction])
            }
    

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
