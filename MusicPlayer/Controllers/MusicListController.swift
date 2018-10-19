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
        controller.musicPlayerDelegate = self
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

//MARK: - MusicPlayerDelegate

extension MusicListController: MusicPlayerDelegate {
    func prevSong() -> Song {
        let selected = tableView.indexPathForSelectedRow!
        let prevRow = selected.row - 1
        
        if 0..<songs.count ~= prevRow {
            return selectNewRowAndReturnSong(row: prevRow, currentSelection: selected)
        } else {
            fatalError("Outside range, should check hasPrevSong if this call possible")
        }
    }
    
    func nextSong() -> Song {
        
        let selected = tableView.indexPathForSelectedRow!
        let nextRow = selected.row + 1
        
        if 0..<songs.count ~= nextRow {
            return selectNewRowAndReturnSong(row: nextRow, currentSelection: selected)
        } else {
            fatalError("Outside range, should check hasNextSong if this call psossible")
        }
    }
    
    var hasPrevSong: Bool {
        get {
            let selected = tableView.indexPathForSelectedRow!
            let prevRow = selected.row - 1
            return 0..<songs.count ~= prevRow
        }
    }
    
    var hasNextSong: Bool {
        get {
            let selected = tableView.indexPathForSelectedRow!
            let nextRow = selected.row + 1
            return 0..<songs.count ~= nextRow
        }
    }
    
    
    private func selectNewRowAndReturnSong(row: Int, currentSelection path: IndexPath) -> Song {
        let newSelection = IndexPath(row: row, section: path.section)
        tableView.selectRow(at: newSelection, animated: true, scrollPosition: .none)
        return songFor(newSelection)
    }
    
    
}
