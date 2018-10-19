//
//  MusicListController.swift
//  MusicPlayer
//
//  Created by vitali on 10/12/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit

fileprivate struct Const {
    
    static let navBarTitle = "All songs"
}


class MusicListController: UIViewController {
    
    //MARK: - Views
    
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: - Properties
    
    private var songs = [Song]()
    
    //MARK: - Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        songs = SongManager.shared.all()
        
        configureNavbar()
        configureTableView()
        
    }
    
}

//MARK: - Configuration Methods

fileprivate extension MusicListController {
    private func configureNavbar(){
        navigationItem.title = Const.navBarTitle
    }
    
    private func configureTableView(){
        let nib = UINib(nibName: Consts.Cells.SongCell.xib, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: Consts.Cells.SongCell.reuseIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
}

//MARK: - Private Helper Methods

fileprivate extension MusicListController {
    
    private func songFor(_ path: IndexPath) -> Song {
        return songs[path.row]
    }
    
    private func setup(cell: SongCell, for song: Song) -> SongCell {
        cell.songNameLabel.text = song.name
        return cell
    }
}


//MARK: - UITableViewDelegate

extension MusicListController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: Consts.Storyboards.main, bundle: Bundle.main)
        let controller = storyboard.instantiateViewController(withIdentifier: Consts.MusicPlayerController.storyboardId) as! MusicPlayerController
        let song = songFor(indexPath)
        controller.currentSong = song
        navigationController?.pushViewController(controller, animated: true)
        
    }
}

//MARK: - UITableViewDataSource

extension MusicListController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Consts.Cells.SongCell.reuseIdentifier,
                                                 for: indexPath) as! SongCell
        
        let song = songFor(indexPath)
        return setup(cell: cell, for: song)
    }
}
