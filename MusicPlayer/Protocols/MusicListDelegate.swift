//
//  MusicListDelegate.swift
//  MusicPlayer
//
//  Created by vitali on 10/22/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation


protocol MusicListDelegate: class {
    
    func songSelected(song: Song)
}
