//
//  UIAlertController++Extension.swift
//  BibleNote
//
//  Created by Chae_Haram on 1/23/24.
//

import UIKit

extension UIAlertController {
    static func warningAlert(title: String, message: String, viewController: UIViewController) {
        let alert = UIAlertController(title: title, message: message , preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(cancelButton)
        viewController.present(alert, animated: true, completion: nil)
    }
}
