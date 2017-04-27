//
//  PostsNavigator.swift
//  RXSwiftTest
//
//  Created by xiaomabao on 2017/4/24.
//  Copyright © 2017年 sunxianglong. All rights reserved.
//

import UIKit
/// 屏幕宽度
let screenW = UIScreen.main.bounds.width
/// 屏幕高度
let screenH = UIScreen.main.bounds.height


//protocol SegueHandlerType {
//    associatedtype SegueIdentifier: RawRepresentable
//}
//extension SegueHandlerType where Self: UIViewController, SegueIdentifier.RawValue == String {
//    func performSegueWithIdentifier(identifier: SegueIdentifier, sender: AnyObject?) {
//        performSegue(withIdentifier: identifier.rawValue, sender: sender)
//    }
//    
//    func segueIdentifierForSegue(segue: UIStoryboardSegue) -> SegueIdentifier {
//        guard
//            let identifier = segue.identifier,
//            let segueIdentifier = SegueIdentifier(rawValue: identifier) else {
//                fatalError("INVALID SEGUE IDENTIFIER \(String(describing: segue.identifier))")
//        }
//        return segueIdentifier
//    }
//}


public extension NSObject {
    static var className: String {
        get {
            return self.description().components(separatedBy: ".").last!
        }
    }
}
protocol PostsNavigator {
    func toPost(_ post: goods)
}

class DefaultPostsNavigator: PostsNavigator {
    private let storyBoard: UIStoryboard
    private let navigationController: UINavigationController
   
    
    init(navigationController: UINavigationController,
         storyBoard: UIStoryboard) {
        self.navigationController = navigationController
        self.storyBoard = storyBoard
    }
    

    
    func toPost(_ post: goods) {
        navigationController.pushViewController(storyBoard.instantiateViewController(withIdentifier: "ViewController"), animated: true)
//        navigationController.childViewControllers.last?.performSegue(withIdentifier: "goods", sender: nil)
  }
    
}
