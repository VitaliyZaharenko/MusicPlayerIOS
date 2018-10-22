//
//  RootViewController.swift
//  MusicPlayer
//
//  Created by vitali on 10/22/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit


fileprivate struct Const {
    
    static let barItemToggleListImageActive = "list-active"
    static let barItemToggleListImageInactive = "list"
}

fileprivate enum PlayerState {
    case MusicList
    case MusicPlayer
    
    func toggle() -> PlayerState {
        switch self {
        case .MusicList: return .MusicPlayer
        case .MusicPlayer: return .MusicList
        }
    }
}

class RootViewController: UIViewController {
    
    
    //MARK: - Views
    
    
    @IBOutlet weak var toggleSongListBarItem: UIBarButtonItem!
    
    @IBOutlet weak var songListContainerView: UIView!
    @IBOutlet weak var songPlayerContainerView: UIView!
    
    
    //MARK: - Properties
    
    private var songListController: MusicListController!
    private var songPlayerController: MusicPlayerController!
    
    private let barItemToggleListImageInactive = UIImage(named: Const.barItemToggleListImageInactive)
    private let barItemToggleListImageActive = UIImage(named: Const.barItemToggleListImageActive)
    
    private var state: PlayerState = .MusicList {
        didSet {
            updateUI()
        }
    }
    
    private var editButtonTintColor: UIColor?
    
    //MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        
        findChildControllers()
        setupChildControllers()
        
        navigationItem.leftBarButtonItem = editButtonItem
        editButtonTintColor = navigationItem.leftBarButtonItem?.tintColor
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        songListController.setEditing(editing, animated: animated)
    }
    
    
    //MARK: - Actions
    
    @IBAction func togglePlayer(_ sender: UIBarButtonItem) {
        state = state.toggle()
    }
    
   

}


//MARK: - Private Helper Methods

fileprivate extension RootViewController {
    
    private func findChildControllers() {
        var listController: MusicListController? = nil
        var playerController: MusicPlayerController? = nil
        
        for child in childViewControllers {
            if let listCtrl = child as? MusicListController {
                listController = listCtrl
            }
            if let playerCtrl = child as? MusicPlayerController {
                playerController = playerCtrl
            }
        }
        
        guard let list = listController, let player = playerController else {
            fatalError("List Or Music Controller not found")
        }
        self.songListController = list
        self.songPlayerController = player
    }
    
    
    private func setupChildControllers(){
        songListController.musicListDelegate = self
        songPlayerController.musicPlayerDelegate = songListController
        updateUI()
    }
    
    private func updateUI(){
        switch state {
        case .MusicList:
            songPlayerContainerView.isHidden = true
            songListContainerView.isHidden = false
            navigationItem.title = Consts.MusicListController.navbarTitle
            navigationItem.leftBarButtonItem?.isEnabled = true
            navigationItem.leftBarButtonItem?.tintColor = editButtonTintColor
            toggleSongListBarItem.image = barItemToggleListImageActive
        case .MusicPlayer:
            songPlayerContainerView.isHidden = false
            songListContainerView.isHidden = true
            navigationItem.title = Consts.MusicPlayerController.navbarTitle
            navigationItem.leftBarButtonItem?.isEnabled = false
            navigationItem.leftBarButtonItem?.tintColor = UIColor.clear
            toggleSongListBarItem.image = barItemToggleListImageInactive
        }
    }
    
}

//MARK: - MusicListDelegate

extension RootViewController: MusicListDelegate {
    
    func songSelected(song: Song) {
        songPlayerController.play(song: song)
        state = .MusicPlayer
    }
}

