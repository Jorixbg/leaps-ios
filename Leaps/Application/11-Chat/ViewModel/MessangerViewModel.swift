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
    private var roomKey: String = ""
    
    init(chat: Chat?) {
        super.init()
        self.chat.value = chat
        
        guard let key = chat?.key else {
            return
        }
        roomKey = key
        chatMessagesRef = messagesRef.child(roomKey)
    }
    
    init(user: User) {
        super.init()
        guard let currentID = Int(UserManager.shared.userID ?? ""),
              let userID = user.userID else {
            return
        }
        roomKey = userID > currentID ? "room-\(currentID)-\(userID)-" : "room-\(userID)-\(currentID)-"
        chatMessagesRef = messagesRef.child(roomKey)
        
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
                let user2 = ChatUser(id: String(userID),
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
        guard let id = UserManager.shared.userID else {
            return
        }
        let chatMessage = ChatMessage(message: message, sender: id, date: Date())
        let child = chatMessagesRef?.childByAutoId()
        child?.setValue(chatMessage.toDict(), andPriority: nil)
        let lastMessageRef = roomsRef.child(roomKey).child("last_message")
        lastMessageRef.setValue(chatMessage.toDict())
    }
}

protocol MessangerElement {
    
}

struct MessangerDate:MessangerElement {
    let date:Date
}
