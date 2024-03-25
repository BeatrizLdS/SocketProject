//
//  UIApplicationExtension.swift
//  SocketProject
//
//  Created by Beatriz Leonel da Silva on 06/03/24.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
