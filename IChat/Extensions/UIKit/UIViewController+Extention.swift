//
//  UIViewController+Extention.swift
//  IChat
//
//  Created by Kirill Manvelov on 17.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit

extension UIViewController {
    func configureCell<T: SelfConfigureCell, U: Hashable>(celltype: T.Type, with value: U, indexPath: IndexPath, collectionView: UICollectionView) -> T {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: celltype.reuseId, for: indexPath) as? T else {
            fatalError("No such type \(celltype)")
        }
        cell.configure(with: value)
        return cell
    }
}

extension UIViewController {
    func showAlert(with title: String, and message: String, complition: @escaping () -> Void = {}) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .default) { (_) in
            complition()
        }
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}
