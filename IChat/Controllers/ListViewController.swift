//
//  ListViewController.swift
//  IChat
//
//  Created by Kirill Manvelov on 10.09.2020.
//  Copyright © 2020 Kirill Manvelov. All rights reserved.
//

import UIKit
import FirebaseFirestore

class ListViewController: UIViewController {
    
    private let currentUser: MUser
    
    enum Section: Int, CaseIterable {
        case waitingChats
        case activeChats
        
        func headerName() -> String {
            switch self {
            case .waitingChats:
                return "Waiting Chats"
            case .activeChats:
                return "Active Chats"
            }
        }
    }
    
    var activeChats = [MChat]()
    var waitingChats = [MChat]()
    
    var collectionView: UICollectionView!
    var dataSource: UICollectionViewDiffableDataSource<Section, MChat>?
    
    private var waitingChatsListener: ListenerRegistration?
    private var activeChatsListener: ListenerRegistration?
    
    init(currentUser: MUser) {
        self.currentUser = currentUser
        super.init(nibName: nil, bundle: nil)
        title = currentUser.username
    }
    
    deinit {
        waitingChatsListener?.remove()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .mainWhite()
        setupSearchBar()
        setupCollectionView()
        createDataSource()
        reloadData()
        
        waitingChatsListener = ListenerService.shared.waitingChatObserve(chats: waitingChats, completion: { (result) in
            switch result {
            case .success(let chats):
                if self.waitingChats != [], self.waitingChats.count <= chats.count {
                    let chatRequestVC = ChatRequestViewController(chat: chats.last!)
                    chatRequestVC.delegate = self
                    self.present(chatRequestVC, animated: true, completion: nil)
                }
                self.waitingChats = chats
                self.reloadData()
            case .failure(let error):
                self.showAlert(with: "oops!", and: error.localizedDescription)
            }
        })
        
        activeChatsListener = ListenerService.shared.activeChatObserve(chats: activeChats, completion: { (result) in
            switch result {
            case .success(let chats):
                self.activeChats = chats
                self.reloadData()
            case .failure(let error):
                 self.showAlert(with: "oops!", and: error.localizedDescription)
            }
        })
    }
    
    private func reloadData() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, MChat>()
        snapshot.appendSections([.waitingChats,.activeChats])
        snapshot.appendItems(waitingChats, toSection: .waitingChats)
        snapshot.appendItems(activeChats, toSection: .activeChats)
        dataSource?.apply(snapshot)
        collectionView.reloadData()
    }
}

//MARK: -Setup SearchBar
extension ListViewController {
    private func setupSearchBar() {
        navigationController?.navigationBar.barTintColor = .mainWhite()
        navigationController?.navigationBar.shadowImage = UIImage()
        let searchController = UISearchController(searchResultsController: nil)
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
    }
}

//MARK: -Setup CollectionView
extension ListViewController {
    private func setupCollectionView() {
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createCompositionalLayout())
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .mainWhite()
        view.addSubview(collectionView)
        
        collectionView.register(SectionHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeader.reuseId)
        collectionView.register(ActiveChatCell.self, forCellWithReuseIdentifier: ActiveChatCell.reuseId)
        collectionView.register(WaitingChatCell.self, forCellWithReuseIdentifier: WaitingChatCell.reuseId)
        collectionView.delegate = self
    }
}

// MARK: -DataSourse
extension ListViewController {
    
    private func createDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, MChat>(collectionView: collectionView, cellProvider: {(collectionView, indexPath, chat) -> UICollectionViewCell? in
            guard let section = Section(rawValue: indexPath.section) else {
                fatalError("No such Section")
            }
            switch section {
            case .activeChats:
                return self.configureCell(celltype: ActiveChatCell.self, with: chat, indexPath: indexPath, collectionView: collectionView)
            case .waitingChats:
                return self.configureCell(celltype: WaitingChatCell.self, with: chat, indexPath: indexPath, collectionView: collectionView)
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
            sectionHeader.configure(text: section.headerName(), font: .laoSangamMN20(), color: #colorLiteral(red: 0.5725490196, green: 0.5725490196, blue: 0.5725490196, alpha: 1))
            return sectionHeader
        }
    }
}

// MARK: -Setup Layout
extension ListViewController {
    private func createCompositionalLayout() -> UICollectionViewLayout{
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, layoutEnviroment) -> NSCollectionLayoutSection? in
            
            guard let section = Section(rawValue: sectionIndex) else {
                fatalError("No such section in enum")
            }
            switch section {
            case .waitingChats:
                return self.createWaitingChats()
            case .activeChats:
                return self.createActiveChats()
            }
        }
        let layoutConfig = UICollectionViewCompositionalLayoutConfiguration()
        layoutConfig.interSectionSpacing = 20
        layout.configuration = layoutConfig
        return layout
    }
    
    private func createActiveChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(84))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 16
        
        let header = createHeader()
        section.boundarySupplementaryItems = [header]
        
        return section
    }
    
    private func createWaitingChats() -> NSCollectionLayoutSection {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .absolute(88), heightDimension: .absolute(88))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.contentInsets = NSDirectionalEdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 20)
        section.interGroupSpacing = 16
        section.orthogonalScrollingBehavior = .continuous
        
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

// MARK: -Collection View Delegate
extension ListViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let chat = self.dataSource?.itemIdentifier(for: indexPath) else {return}
        guard let section = Section(rawValue: indexPath.section) else {return}
        
        switch section {
        case .waitingChats:
            let chatRequestVC = ChatRequestViewController(chat: chat)
            chatRequestVC.delegate = self
            self.present(chatRequestVC, animated: true, completion: nil)
        case .activeChats:
           let chatsVC = ChatsViewController(user: currentUser, chat: chat)
           navigationController?.pushViewController(chatsVC, animated: true)
        }
    }
}

// MARK: -Chat Navigation Delegate
extension ListViewController: ChatNavigationDelegate {
    func removeWaitingСhat(chat: MChat) {
        FirestoreService.shared.removeWaitingChat(chat: chat) { (result) in
            switch result {
            case .success():
                self.reloadData()
                self.showAlert(with: "Success", and: "Chat with \(chat.friendUsername) is deleted")
            case .failure(let error):
                self.showAlert(with: "oops", and: error.localizedDescription)
            }
        }
    }
    
    func changeToActive(chat: MChat) {
        FirestoreService.shared.changeToActive(chat: chat) { (result) in
            switch result {
            case .success():
                self.reloadData()
                self.showAlert(with: "Success", and: "Chat with \(chat.friendUsername) is added")
            case .failure(let error):
                self.showAlert(with: "oops", and: error.localizedDescription)
            }
        }
    }
}

// MARK: -SearchBar Delegate
extension ListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("\(searchText)")
    }
}

// MARK: -Preview Provider
import SwiftUI

struct ListControllerProvider: PreviewProvider {
    static var previews: some View {
        ContainerView().edgesIgnoringSafeArea(.all)
    }
    
    struct ContainerView: UIViewControllerRepresentable  {
        let viewController = MainTabBarController(currentUser: MUser(username: "placeholder", avatarStringURL: "placeholder", email: "placeholder", sex: "placeholder", description: "placeholder", id: "placeholder"))
        
        func makeUIViewController(context: Context) -> MainTabBarController {
            return viewController
        }
        
        func updateUIViewController(_ uiViewController: ListControllerProvider.ContainerView.UIViewControllerType, context: Context) {
        }
    }
}




