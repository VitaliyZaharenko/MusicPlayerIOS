//
//  SongManager.swift
//  MusicPlayer
//
//  Created by vitali on 10/13/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

class SongManager {
    
    static let shared = SongManager()
    
    
    func all() -> [Song] {
        return predefinedSongs()
    }
    
    
    private func predefinedSongs() -> [Song] {
        return [Song(filename: Consts.StaticMp3.xFilesTheme),
                Song(filename: Consts.StaticMp3.feelItStill),
                Song(filename: Consts.StaticMp3.noTimeForCaution),
                Song(filename: Consts.StaticMp3.kosilYasKonushinu)]
    }
}
