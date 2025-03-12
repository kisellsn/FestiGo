//
//  Utilities.swift
//  FestiGo
//
//  Created by kisellsn on 02/04/2025.
//

import Foundation
import UIKit

final class Utilities{
//    static let shared = Utilities()
//    private init(){}
//    
//    @MainActor
//    func rootViewController(controller: UIViewController? = nil) -> UIViewController? {
//        let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
//        if let navigationController = controller as? UINavigationController {
//            return topViewController(controller: navigationController.visibleViewController)
//        }
//        if let tabController = controller as? UITabBarController {
//            if let selected = tabController.selectedViewController {
//                return topViewController(controller: selected)
//            }
//        }
//        if let presented = controller?.presentedViewController {
//            return topViewController(controller: presented)
//        }
//        return controller
//    }
    static var rootViewController: UIViewController{
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else{
            return .init()
            
        }
        
        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        
        return root
    }
    
}
