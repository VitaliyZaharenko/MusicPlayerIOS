//
//  MusicPlayerController.swift
//  MusicPlayer
//
//  Created by vitali on 10/12/18.
//  Copyright © 2018 vitcopr. All rights reserved.
//

import UIKit
import AVKit

fileprivate struct Const {
    
    static let playImage = "play"
    static let pauseImage = "pause"
    static let timeFormatString = "mm:ss"
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Const.timeFormatString
        return formatter
    } ()
}

class MusicPlayerController: UIViewController {
    
    //MARK: - Views
    
    @IBOutlet weak var songLabel: UILabel!
    @IBOutlet weak var songCoverImageView: UIImageView!
    @IBOutlet weak var songCurrentTimeLabel: UILabel!
    @IBOutlet weak var songEndTimeLabel: UILabel!
    @IBOutlet weak var songPositionSlider: UISlider!
    
    @IBOutlet weak var prevSongImageView: UIImageView!
    @IBOutlet weak var nextSongImageView: UIImageView!
    @IBOutlet weak var playPauseImageView: UIImageView!
    
    
    
    //MARK: - Properties
    
    private var player: AVPlayer!
    var currentSong: Song!
    var currentSongAsset: AVAsset!
    weak var musicPlayerDelegate: MusicPlayerDelegate!
    private var playing = false
    
    private var playImage: UIImage!
    private var pauseImage: UIImage!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        currentSong = SongManager.shared.all().first
        guard let songUrl = currentSong?.url else {
            fatalError("Song url is nil")
        }
        currentSongAsset = AVURLAsset(url: songUrl)
        
        configurePlayer()
        configurePlayPause()
        configurePrevSongButton()
        configurePrevSongButton()
        configureSongInfoViews()
    }
    
    
    //MARK: - Configuration methods
    
    private func configurePlayer(){
        let playerItem = AVPlayerItem(asset: currentSongAsset)
        player = AVPlayer(playerItem: playerItem)
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, Int32(NSEC_PER_SEC)), queue: nil) { time in
            self.update(label: self.songCurrentTimeLabel, withTime: time)
            self.updateSlider(time)
        }
    }
    
    private func configurePlayPause(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        playPauseImageView.isUserInteractionEnabled = true
        playPauseImageView.addGestureRecognizer(tapGestureRecognizer)
        
        playImage = UIImage(named: Const.playImage)
        pauseImage = UIImage(named: Const.pauseImage)
    }
    
    private func configurePrevSongButton(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(prevSongTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        prevSongImageView.isUserInteractionEnabled = true
        prevSongImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configureNextSongButton(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextSongTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        nextSongImageView.isUserInteractionEnabled = true
        nextSongImageView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func configureSongInfoViews(){
        songLabel.text = currentSong!.name
        let startTime = kCMTimeZero
        update(label: songCurrentTimeLabel, withTime: startTime)
        updateSlider(kCMTimeZero)
        
        let endTime = currentSongAsset.duration
        update(label: songEndTimeLabel, withTime: endTime)
        
    }
    
    //MARK: - Callbacks
    
    
    @objc private func playPauseTapped(sender: UITapGestureRecognizer){
        
        if !playing {
            playing = true
            player.play()
            playPauseImageView.image = pauseImage
        } else {
            playing = false
            player.pause()
            playPauseImageView.image = playImage
        }
        
    }
    
    @objc private func prevSongTapped(sender: UITapGestureRecognizer){
        
    }
    
    @objc private func nextSongTapped(sender: UITapGestureRecognizer){
        

    }
    
    
    //MARK: - Actions
    
    @IBAction func setSongTime(_ sender: UISlider) {
        
        let timeAsFloat = sender.value * Float(currentSongAsset.duration.seconds)
        let time = CMTime(seconds: timeAsFloat, preferredTimescale: )
        player.seek(to: time, completionHandler: <#T##(Bool) -> Void#>)
        
    }
    

}


//MARK: - Private helper methods
extension MusicPlayerController {
    
    private func update(label: UILabel, withTime time: CMTime) {
        let convertedTime = Date(timeIntervalSince1970: time.seconds)
        label.text = Const.timeFormatter.string(from: convertedTime)
    }
    
    private func updateSlider(_ time: CMTime){
        let position = time.seconds / currentSongAsset.duration.seconds
        songPositionSlider.value = Float(position)
    }
}

