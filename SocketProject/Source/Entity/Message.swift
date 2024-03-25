//
//  Message.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 01/03/24.
//

import Foundation

struct ChatMessage: Hashable {
    var sender: SenderType
    var content: String
    
    enum SenderType {
        case localUser
        case remoteUser
    }
}
