//
//  InboxVIewModel.swift
//  Leaps
//
//  Created by Slav Sarafski on 27/11/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import Firebase

class InboxViewModel: BaseViewModel {
    
    var chats:Dynamic<[Chat]> = Dynamic([])
    
    private lazy var chatsRef = Database.database().reference().child("rooms")
    var chatsHandler:DatabaseHandle?
    
    func loadChats() {
        guard let userID = UserManager.shared.userID else {
            return
        }
        
        chatsRef.observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            var local:[Chat] = []
            
            for chat in snapshot.children {
                if let chat = chat as? DataSnapshot,
                   chat.key.contains("-\(userID)-")
                {
                    local.append(Chat(snapshot: chat))
                }
                self?.chats.value = local
            }
        })
    }
    
    func addChat(with id:String) {
        
    }
}

struct Chat {
    let current: ChatUser
    let other: ChatUser
    let messages: [ChatMessage]
    var lastMessage: ChatMessage?
    let key: String
    
    init(user1: ChatUser, user2: ChatUser, key: String) {
        if user1.isCurrent {
            current = user1
            other = user2
        }
        else {
            current = user2
            other = user1
        }
        messages = []
        lastMessage = nil
        self.key = key
    }
    
    init(snapshot: DataSnapshot) {
        var user1:ChatUser? = nil
        var user2:ChatUser? = nil
        lastMessage = nil
        key = snapshot.key
        messages = []
        
        for item in snapshot.children {
            let snap = item as! DataSnapshot
            if snap.key == "last_message" {
                lastMessage = ChatMessage(snapshot: snap)
            }
            if snap.key == "user1" {
                user1 = ChatUser(snapshot: snap)
            }
            if snap.key == "user2" {
                user2 = ChatUser(snapshot: snap)
            }
        }
        
        if let u1 = user1, let u2 = user2 {
            current = u1.isCurrent ? u1 : u2
            other = u1.isCurrent ? u2 : u1
        }
        else {
            current = ChatUser(id: "nil", name: "nil", image: "nil")
            other = ChatUser(id: "nil", name: "nil", image: "nil")
        }
    }
    
    func user(for id: String) -> ChatUser {
        if current.id == id { return current }
        else { return other }
    }
    
    func toDict() -> Dictionary<String, Any> {
        return ["user1": current.toDict(),
                "user2": other.toDict()]
    }
}

struct ChatUser {
    let id: String
    let name: String
    let image: String
    
    var isCurrent: Bool {
        get {
            return id == UserManager.shared.userID
        }
    }
    
    init(id: String, name: String, image: String) {
        self.id = id
        self.name = name
        self.image = image
    }
    
    init(snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String: Any],
              let id = data["id"] as? String,
              let name = data["name"] as? String,
              let image = data["image"] as? String else {
            self.init(id: "-1", name: "", image: "")
            return
        }
        self.init(id: id, name: name, image: image)
    }
    
    func toDict() -> Dictionary<String, Any> {
        return ["id": id,
                "name": name,
                "image": image]
    }
}

struct ChatMessage: MessangerElement {
    let message: String
    let senderID: String
    let time: Date
    //let type
    
//    func isSender(user: ChatUser) -> Bool {
//        return senderID == user.id
//    }
    
    init(message: String, sender: String, time: Int) {
        self.message = message
        self.senderID = sender
//        self.time = Date(timeIntervalSince1970: TimeInterval(time))
        self.time = Date(timeIntervalSince1970inMiliseconds: Int64(time))
    }
    
    init(message: String, sender: String, date: Date) {
        self.message = message
        self.senderID = sender
        self.time = date
    }
    
    init(snapshot: DataSnapshot) {
        guard let data = snapshot.value as? [String: Any],
              let message = data["message"] as? String,
              let sender = data["sender"] as? String,
              let time = data["time"] as? Int else {
                self.init(message: "", sender: "-1", time: 0)
                return
        }
        self.init(message: message, sender: sender, time: time)
    }
    
    func toDict() -> Dictionary<String, Any> {
        return ["message": message,
                "sender": senderID,
                "time": Int(time.timeIntervalSince1970Miliseconds)]
    }
}
