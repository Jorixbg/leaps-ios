//
//  MessangerViewModel.swift
//  Leaps
//
//  Created by Slav Sarafski on 2/12/17.
//  Copyright © 2017 Chavdar Nedialkov. All rights reserved.
//

import UIKit
import FirebaseDatabase

class MessangerViewModel: NSObject {
    
    var messages:Dynamic<[MessangerElement]> = Dynamic([])
    var chat:Dynamic<Chat?> = Dynamic(nil)
    
    private lazy var messagesRef = Database.database().reference().child("messages")
    private lazy var roomsRef = Database.database().reference().child("rooms")
    private var chatMessagesRef: DatabaseReference?
    private var seenRef: DatabaseReference?
    private var roomKey: String = ""
    
    let seenElement = MessengerSeen()
    
    init(chat: Chat?) {
        super.init()
        self.chat.value = chat

        guard let key = chat?.key,
              let id = Int(UserManager.shared.userID ?? "") else {
            return
        }
        roomKey = key
        chatMessagesRef = messagesRef.child(roomKey)
        seenRef = roomsRef.child("seen\(id)")
    }
    
    init(user: User) {
        super.init()
        guard let id = Int(UserManager.shared.userID ?? ""),
              let other = user.userID else {
            return
        }
        roomKey = id > other ? "room-\(other)-\(id)-" : "room-\(id)-\(other)-"
        chatMessagesRef = messagesRef.child(roomKey)
        seenRef = roomsRef.child("seen\(id)")
        
        roomsRef.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard let roomKey = self?.roomKey else {
                return
            }
            
            if snapshot.hasChild(roomKey) {
                self?.chat.value = Chat(snapshot: snapshot.childSnapshot(forPath: roomKey))
                self?.loadMessages()
            }
            else {
                let user1 = ChatUser(id: UserManager.shared.userID ?? "",
                                     name: UserManager.shared.userName ?? "",
                                     image: UserManager.shared.userImage ?? "")
                let user2 = ChatUser(id: String(other),
                                     name: user.fullname,
                                     image: user.imageURL ?? "")
                let chat = Chat(user1: user1, user2: user2, key: roomKey)
                
                let roomRef = self?.roomsRef.child(roomKey)
                roomRef?.setValue(chat.toDict(), withCompletionBlock: {(error, ref) in
                    self?.chat.value = chat
                    self?.loadMessages()
                })
            }
        }
    }
    
    func loadMessages() {
        chatMessagesRef?.observe(.value, with: { [weak self] (snapshot) in
            var local:[MessangerElement] = []
            var groupDate:Date? = nil
            
            for message in snapshot.children {
                if let messageSnapshot = message as? DataSnapshot {
                    let chatMessage = ChatMessage(snapshot: messageSnapshot)
                    if groupDate == nil || !Calendar.current.isDate(groupDate!, inSameDayAs: chatMessage.time) {
                        groupDate = chatMessage.time
                        local.append(MessangerDate(date: groupDate!))
                    }
                    local.append(chatMessage)
                }
            }
            self?.messages.value = local.reversed()
        })
    }
    
    func send(message: String) {
        guard let id = UserManager.shared.userID,
              let other = chat.value?.other.id else {
            return
        }
        
        let chatMessage = ChatMessage(message: message, sender: id, date: Date())
        let child = chatMessagesRef?.childByAutoId()
        let notificationsRef = Database.database().reference().child("notifications").child(other).childByAutoId()
        
        let values:[String:Any] = ["messages/\(roomKey)/\(child!.key)" : chatMessage.toDict(),
                                   "rooms/\(roomKey)/last_message": chatMessage.toDict(with: id < other),
                                   "notifications/\(other)/\(notificationsRef.key)": ["from": id,
                                                                                      "type": "message"]]
        
        Database.database().reference().updateChildValues(values) { (error, ref) in
            //print(error)
        }
    }
    
    func seenMessage(message: ChatMessage) {
        seenRef?.setValue(message.key)
    }
    
    func setMessengerSeen(key: String) {
        //let index = messages.value.index(where: { ($0 as? ChatMessage)?.key == key })
        
    }
}

protocol MessangerElement {
    func isEqualTo(_ other: MessangerElement) -> Bool
}

extension MessangerElement where Self: Equatable {
    func isEqualTo(_ other: MessangerElement) -> Bool {
        guard let otherElement = other as? Self else { return false }
        return self == otherElement
    }
}

struct MessangerDate: MessangerElement, Equatable {
    static func ==(lhs: MessangerDate, rhs: MessangerDate) -> Bool {
        return lhs.date == rhs.date
    }
    
    let date:Date
}

struct MessengerSeen: MessangerElement, Equatable {
    var index: Int?
    
    static func ==(lhs: MessengerSeen, rhs: MessengerSeen) -> Bool {
        return true
    }
}
