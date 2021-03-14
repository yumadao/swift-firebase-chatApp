//
//  chatRoom.swift
//  firebaseChatApp
//
//  Created by 大石優真 on 2021/03/14.
//

import Foundation
import Firebase

class ChatRoom {
    let name:String
    let msg:String
    let createdAt:Timestamp
    
    var documentId:String?
    var uid:String
  
    init(dic:[String:Any]) {
        self.name = dic["name"] as? String ?? ""
        self.msg = dic["msg"] as? String ?? ""
        self.createdAt = dic["createdAt"] as? Timestamp ?? Timestamp()
        self.uid = dic["uid"] as? String ?? ""
    }
}

