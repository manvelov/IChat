//
//  SetupProfileViewController.swift
//  IChat
//
//  Created by Kirill Manvelov on 10.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import Firebase

class SetupProfileViewController: UIViewController {
    
    let welcomeLabel = UILabel(text: "Set up profile!", font: .avenir26())
    
    let fullNameLabel = UILabel(text: "Full name")
    let aboutMeLabel = UILabel(text: "About me")
    let sexLabel = UILabel(text: "Sex")
    
    let fullNameTextField = OneLineTextField(font: .avenir20())
    let aboutMeTextField = OneLineTextField(font: .avenir20())
    
    let sexSegmentedControl = UISegmentedControl(first: "Male", second: "Female")
    
    let fullImageView = AddPhotoView()
    
    let goToChatsButton = UIButton(title: "Go to chats", titleColor: .mainWhite(), backgroudColor: .buttonDark())
    
    private var currentUser: User
    
    init(currentUser: User) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        
        if let username = currentUser.displayName {
            fullNameTextField.text = username
        }
        
        if let photoUrl = currentUser.photoURL {
            fullImageView.circleImageView.sd_setImage(with: photoUrl, completed: nil)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupConstraints()
        
        goToChatsButton.addTarget(self, action: #selector(goToChatsButtonTapped), for: .touchUpInside)
        fullImageView.plusButton.addTarget(self, action: #selector(plusButtonTapped), for: .touchUpInside)
    }
    
    @objc private func plusButtonTapped() {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = .photoLibrary
        present(pickerController, animated: true, completion: nil)
    }
    
    @objc private func goToChatsButtonTapped() {
        FirestoreService.shared.saveProfileWith(id: currentUser.uid,
                                                email: currentUser.email!,
                                                sex: sexSegmentedControl.titleForSegment(at: sexSegmentedControl.selectedSegmentIndex),
                                                username: fullNameTextField.text,
                                                description: aboutMeTextField.text,
                                                avatarImage: fullImageView.circleImageView.image) { (result) in
                                                    switch result {
                                                        
                                                    case .success(let muser):
                                                        self.showAlert(with: "Success", and: "You profile is created", complition: {
                                                            let mainTabBarVC = MainTabBarController(currentUser: muser)
                                                            mainTabBarVC.modalPresentationStyle = .fullScreen
                                                            self.present(mainTabBarVC, animated: true, completion: nil)
                                                        })
                    
                                                    case .failure(let error):
                                                        self.showAlert(with: "Try again", and: error.localizedDescription)
                                                    }
        }
    }
}

// MARK: -
extension SetupProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {
            return
        }
        fullImageView.circleImageView.image = image
    }
}

// MARK: -Setup Constraints
extension SetupProfileViewController {
    private func setupConstraints() {
        
        goToChatsButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        let fullNameView = UIStackView(arrangedSubView: [fullNameLabel, fullNameTextField],
                                       axis: .vertical,
                                       spacing: 0)
        let aboutMeView = UIStackView(arrangedSubView: [aboutMeLabel, aboutMeTextField],
                                      axis: .vertical,
                                      spacing: 0)
        let sexSegmentedView = UIStackView(arrangedSubView: [sexLabel, sexSegmentedControl],
                                      axis: .vertical,
                                      spacing: 12)
        let mainStackView = UIStackView(arrangedSubView: [fullNameView, aboutMeView, sexSegmentedView, goToChatsButton],
                                        axis: .vertical,
                                        spacing: 40)
        
        welcomeLabel.translatesAutoresizingMaskIntoConstraints = false
        fullImageView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(welcomeLabel)
        view.addSubview(fullImageView)
        view.addSubview(mainStackView)
        
        
        NSLayoutConstraint.activate([
            welcomeLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 160),
            welcomeLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
               fullImageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 40),
               fullImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
           ])
        
       NSLayoutConstraint.activate([
                 mainStackView.topAnchor.constraint(equalTo: fullImageView.bottomAnchor, constant:  100),
                 mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  40),
                 mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant:  -40)
                    ])
    }
    
}

// MARK: -Preview Provider
import SwiftUI

struct SetupProfileVCProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable  {
        let viewController = SetupProfileViewController(currentUser: Auth.auth().currentUser!)
        
        func makeUIViewController(context: Context) -> SetupProfileViewController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: SetupProfileVCProvider.ContainerView.UIViewControllerType, context: Context) {
        }
    }
}
