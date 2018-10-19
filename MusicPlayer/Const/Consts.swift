//
//  Consts.swift
//  MusicPlayer
//
//  Created by vitali on 10/12/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import Foundation

struct Consts {
    
    struct StaticMp3 {
        static let xFilesTheme = "TheXFilestheme"
        static let noTimeForCaution = "hans zimmer no time for caution"
        static let kosilYasKonushinu = "Песняры – Косил Ясь Конюшину"
        static let feelItStill = "portugal man - feel it still"
    }
    
    struct Segues {
        
        static let playSong = "playSongSegueId"
    }
    
    struct Storyboards {
        static let main = "Main"
    }
    
    struct Cells {
        struct SongCell {
            
            static let xib = "SongCell"
            static let reuseIdentifier = "SongCellId"
        }
    }
    
    struct MusicPlayerController {
        static let storyboardId = "MusicPlayerControllerId"
    }
    
}
