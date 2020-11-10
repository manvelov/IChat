//
//  MainTabBarController.swift
//  IChat
//
//  Created by Kirill Manvelov on 10.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {
    
    private let currentUser: MUser
    
    let boldConfig = UIImage.SymbolConfiguration(weight: .medium)
    
    init (currentUser: MUser){
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let convImage = UIImage(systemName: "bubble.left.and.bubble.right", withConfiguration: boldConfig)
        let peopleImage = UIImage(systemName: "person.2", withConfiguration: boldConfig)
        
        viewControllers = [
            generateVC(rootViewController: PeopleViewController(currentUser: currentUser), title: "People", image: peopleImage!),
            generateVC(rootViewController: ListViewController(currentUser: currentUser), title: "Conversations", image: convImage!)
            
        ]
        
        
    }
    
    private func generateVC(rootViewController: UIViewController, title: String, image: UIImage) -> UIViewController {
        let navigationVC = UINavigationController(rootViewController: rootViewController)
        navigationVC.tabBarItem.title = title
        navigationVC.tabBarItem.image = image
        return navigationVC
    }
    
}
