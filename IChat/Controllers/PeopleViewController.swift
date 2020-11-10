//
//  PeopleViewController.swift
//  IChat
//
//  Created by Kirill Manvelov on 10.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class PeopleViewController: UIViewController {
    
    private let currentUser: MUser
    
    private var userListener: ListenerRegistration?
    var users = [MUser]()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, MUser>!
    
    enum Section: Int, CaseIterable {
        case users
        
        func headerName (userCount: Int) -> String {
            return "\(userCount) people nearby"
        }
    }
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    
    deinit {
        userListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainWhite()
        setupSearcBar()
        setupCollectionView()
        createDataSource()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "Sign Out", style: .plain, target: self, action: #selector(signOutTapped))
        
        userListener = ListenerService.shared.usersObserve(users: users, completion: { (result) in
            switch result {
            case .success(let users):
                self.users = users
                self.reloadData(with: nil)
            case .failure(_):
                self.showAlert(with: "Something goes wrong!", and: "Cannot load people around")
            }
        })
    }
    
    @objc func signOutTapped() {
        let ac = UIAlertController(title: nil, message: "Are you sure want to sign out?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        ac.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            do {
                try Auth.auth().signOut()
                UIApplication.shared.keyWindow?.rootViewController = AuthViewController()
            }
            catch {
                print("Error during sign out")
            }
        }))
        present(ac, animated: true, completion: nil)
    }
    
    private func setupSearcBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
        
    private func reloadData(with filter: String?) {
        let filtered = users.filter { (user) -> Bool in
            user.contains(filter: filter)
        }
        var snapshot = NSDiffableDataSourceSnapshot<Section, MUser>()
        snapshot.appendSections([.users])
        snapshot.appendItems(filtered, toSection: .users)
        dataSource?.apply(snapshot)
    }
    
}
// MARK: -Setup CollectionView
extension PeopleViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(UserCell.self, forCellWithReuseIdentifier: UserCell.reuseId)
        collectionView.delegate = self
    }
}

// MARK: -UISearchBarDelegate
extension PeopleViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        reloadData(with: searchText)
    }
}
// MARK: -Collection View Delegate
extension PeopleViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let user = self.dataSource.itemIdentifier(for: indexPath) else { return }
        let profileVC = ProfileViewController(user: user)
        present(profileVC, animated: true, completion: nil)
    }
}

//MARK: - Setup Layout
extension PeopleViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("No such section in enum")
            }
            
            switch section {
            case .users:
                return self.createUsersSection()
            }
        }
        return layout
    }
    
    private func createUsersSection() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                              heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitem: item, count: 2)
        group.interItemSpacing = .fixed(15)
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 15, bottom: 0, trailing: 15)
        section.interGroupSpacing = 15
        
        let header = createHeader()
        section.boundarySupplementaryItems = [header]
        return section
    }
    
    private func createHeader() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                heightDimension: .estimated(1))
        
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize,
                                                                 elementKind: UICollectionView.elementKindSectionHeader,
                                                                 alignment: .top)
        return header
    }
    
}

//MARK: - Data Source
extension PeopleViewController {
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MUser>(collectionView: collectionView, cellProvider: {(collectionView, indexPath, user) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("No such Section")
            }
            switch section {
            case .users:
                return self.configureCell(celltype: UserCell.self, with: user, indexPath: indexPath, collectionView: collectionView)
            }
        })
        
        dataSource?.supplementaryViewProvider = {
            (collectionView, kind, indexPath) in
            guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeader.reuseId, for: indexPath) as? SectionHeader else {
                fatalError("Cannot find Section Header")
            }
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("Unknown section kind")
            }
            let usersCount = self.dataSource.snapshot().itemIdentifiers(inSection: .users).count
            sectionHeader.configure(text: section.headerName(userCount: usersCount),
                                    font: .systemFont(ofSize: 36, weight: .light),
                                    color: .label)
            return sectionHeader
        }
    }
}

// MARK: -Preview Provider
import SwiftUI

struct PeopleControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable  {
        let viewController = MainTabBarController(currentUser: MUser(username: "placeholder", avatarStringURL: "placeholder", email: "placeholder", sex: "placeholder", description: "placeholder", id: "placeholder"))
        
        func makeUIViewController(context: Context) -> MainTabBarController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: PeopleControllerProvider.ContainerView.UIViewControllerType, context: Context) {
        }
    }
}
