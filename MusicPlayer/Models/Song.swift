//
//  Song.swift
//  MusicPlayer
//
//  Created by vitali on 10/13/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

struct Song {
    
    let name: String
    let url: URL
    
    init(filename: String){
        guard let url = Bundle.main.url(forResource: filename, withExtension: "mp3") else {
            fatalError("file not found: \(filename)")
        }
        self.url = url
        self.name = filename
    }
}
