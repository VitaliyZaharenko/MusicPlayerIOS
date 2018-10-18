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
    private var playing = false {
        didSet {
            playPauseImageView.image = playing ? pauseImage : playImage
        }
    }
    private var endPlaying = false
    
    private var playImage = UIImage(named: Const.playImage)
    private var pauseImage = UIImage(named: Const.pauseImage)
    
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
        NotificationCenter.default.addObserver(self, selector: #selector(MusicPlayerController.playerDidFinishPlaying(notification:)),
                                               name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
    }
    
    private func configurePlayPause(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(playPauseTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        playPauseImageView.isUserInteractionEnabled = true
        playPauseImageView.addGestureRecognizer(tapGestureRecognizer)
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
        let endTime = currentSongAsset.duration
        songPositionSlider.maximumValue = Float(endTime.seconds)
        update(label: songCurrentTimeLabel, withTime: startTime)
        updateSlider(kCMTimeZero)
        update(label: songEndTimeLabel, withTime: endTime)
        
    }
    
    //MARK: - Callbacks
    
    
    @objc private func playPauseTapped(sender: UITapGestureRecognizer){
        
        if endPlaying {
            endPlaying = false
            player.seek(to: kCMTimeZero)
        }
        
        if !playing {
            playing = true
            player.play()
        } else {
            playing = false
            player.pause()
        }
        
    }
    
    @objc private func prevSongTapped(sender: UITapGestureRecognizer){
        
    }
    
    @objc private func nextSongTapped(sender: UITapGestureRecognizer){
        

    }
    
    @objc private func playerDidFinishPlaying(notification: Notification){
        playing = false
        endPlaying = true
        update(label: songCurrentTimeLabel, withTime: currentSongAsset.duration)
    }
    
    
    //MARK: - Actions
    
    @IBAction func setSongTime(_ sender: UISlider) {
        
        let time = CMTimeMakeWithSeconds(Double(sender.value), 1)
        player.seek(to: time, completionHandler: { _ in () })
        
    }
    

}


//MARK: - Private helper methods
extension MusicPlayerController {
    
    private func update(label: UILabel, withTime time: CMTime) {
        let convertedTime = Date(timeIntervalSince1970: time.seconds)
        label.text = Const.timeFormatter.string(from: convertedTime)
    }
    
    private func updateSlider(_ time: CMTime){
        songPositionSlider.value = Float(time.seconds)
    }
}

