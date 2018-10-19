//
//  MusicPlayerDelegate.swift
//  MusicPlayer
//
//  Created by vitali on 10/13/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

protocol MusicPlayerDelegate: class {
    
    func prevSong() -> Song
    func nextSong() -> Song
    
    func hasPrevSong() -> Bool
    func hasNextSong() -> Bool
}
