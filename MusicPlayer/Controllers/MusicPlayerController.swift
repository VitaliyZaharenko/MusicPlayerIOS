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
    static let noArtworkImage = "music"
    static let timeFormatString = "mm:ss"
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = Const.timeFormatString
        return formatter
    } ()
    static let maxDifferenceToNotUpdateSlider: Float = 1.1
    static let sliderUpdateTimeSeconds = 0.2
    static let artworkMetadataKey = "artwork"
    static let noSong = "No Song"
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
    var currentSong: Song?
    var currentSongAsset: AVAsset!
    weak var musicPlayerDelegate: MusicPlayerDelegate?
    private var playing = false {
        didSet {
            playPauseImageView.image = playing ? pauseImage : playImage
        }
    }
    private var endPlaying = true
    
    private var playImage = UIImage(named: Const.playImage)
    private var pauseImage = UIImage(named: Const.pauseImage)
    private var noArtworkImage = UIImage(named: Const.noArtworkImage)
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configurePlayPause()
        configurePrevButton()
        configureNextButton()
        configureSongInfoViews()
        
        if currentSong != nil {
            configureSong()
            configurePlayer()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if currentSong != nil {
            startPlayingSong()
        }
    }
    
    
    //MARK: - Callbacks
    
    
    @objc private func playPauseTapped(sender: UITapGestureRecognizer){
        
        guard currentSongAsset != nil else {
            return
        }
        
        if endPlaying {
            startPlayingSong()
        } else {
            if !playing {
                continuePlayingSong()
            } else {
                pauseSong()
            }
        }
    }
    
    @objc private func prevSongTapped(sender: UITapGestureRecognizer){
        let newSong = musicPlayerDelegate?.prevSong()
        play(song: newSong)
        
    }
    
    @objc private func nextSongTapped(sender: UITapGestureRecognizer){
        let newSong = musicPlayerDelegate?.nextSong()
        play(song: newSong)
        
    }
    
    @objc private func playerDidFinishPlaying(notification: Notification){
        playing = false
        endPlaying = true
        update(label: songCurrentTimeLabel, withTime: currentSongAsset.duration)
    }
    
    
    //MARK: - Actions
    
    @IBAction func setSongTime(_ sender: UISlider, forEvent event: UIEvent) {
        
        guard currentSongAsset != nil else {
            return
        }
        
        let time = CMTimeMakeWithSeconds(Double(sender.value), 1)
        update(label: songCurrentTimeLabel, withTime: time)
        if let touchEvent = event.allTouches?.first {
            switch touchEvent.phase {
            case .ended:
                player.seek(to: time, completionHandler: { _ in () })
            default:
                break
            }
        }
    }
}


//MARK: - Configuration Methods

fileprivate extension MusicPlayerController {
    
    private func configureSong(){
        guard let songUrl = currentSong?.url else {
            fatalError("Song url is nil")
        }
        currentSongAsset = AVURLAsset(url: songUrl)
    }
    
    private func configurePlayer(){
        let playerItem = AVPlayerItem(asset: currentSongAsset)
        player = AVPlayer(playerItem: playerItem)
        player.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(Const.sliderUpdateTimeSeconds, Int32(NSEC_PER_SEC)), queue: nil) { time in
            self.update(label: self.songCurrentTimeLabel, withTime: time)
            let difference = abs(self.songPositionSlider.value - Float(time.seconds))
            if difference < Const.maxDifferenceToNotUpdateSlider {
                self.updateSlider(time)
            }
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
    
    private func configurePrevButton(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(prevSongTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        prevSongImageView.isUserInteractionEnabled = true
        prevSongImageView.addGestureRecognizer(tapGestureRecognizer)
        set(button: prevSongImageView, enabled: musicPlayerDelegate?.hasPrevSong ?? false)
        
    }
    
    
    private func configureNextButton(){
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(nextSongTapped(sender:)))
        tapGestureRecognizer.numberOfTapsRequired = 1
        nextSongImageView.isUserInteractionEnabled = true
        nextSongImageView.addGestureRecognizer(tapGestureRecognizer)
        set(button: nextSongImageView, enabled: musicPlayerDelegate?.hasNextSong ?? false)
    }
    
    private func configureSongInfoViews(){
        songLabel.text = currentSong?.name ?? Const.noSong
        let startTime = kCMTimeZero
        update(label: songCurrentTimeLabel, withTime: startTime)
        updateSlider(kCMTimeZero)
        if let currentSongAsset = currentSongAsset{
            let endTime = currentSongAsset.duration
            songPositionSlider.maximumValue = Float(endTime.seconds)
            update(label: songEndTimeLabel, withTime: endTime)
            if let coverImage = extractArtwork(from: currentSongAsset) {
                songCoverImageView.image = coverImage
            } else {
                songCoverImageView.image = noArtworkImage
            }
        }
        
    }
}


//MARK: - Private Helper Methods

fileprivate extension MusicPlayerController {
    
    private func startPlayingSong(){
        playing = true
        endPlaying = false
        player.seek(to: kCMTimeZero)
        updateSlider(kCMTimeZero)
        player.play()
    }
    
    private func continuePlayingSong(){
        playing = true
        player.play()
    }
    
    private func pauseSong(){
        playing = false
        player.pause()
    }
    
    
    private func set(button: UIImageView, enabled: Bool){
        let tapGestureRecognizer = button.gestureRecognizers!.first!
        tapGestureRecognizer.isEnabled = enabled
        button.alpha = enabled ? 1.0 : 0.5
    }
    
    private func update(label: UILabel, withTime time: CMTime) {
        let convertedTime = Date(timeIntervalSince1970: time.seconds)
        label.text = Const.timeFormatter.string(from: convertedTime)
    }
    
    private func updateSlider(_ time: CMTime){
        songPositionSlider.value = Float(time.seconds)
    }
    
    private func extractArtwork(from asset: AVAsset) -> UIImage? {
        let metadata = asset.metadata
        for item in metadata {
            if let key = item.commonKey?._rawValue as String?, key == Const.artworkMetadataKey {
                guard let data = item.dataValue else {
                    return nil
                }
                
                return UIImage(data: data)
            }
        }
        return nil
    }
}


//MARK: - MusicPlayer

extension MusicPlayerController: MusicPlayer {
    func play(song: Song? = nil) {
        
        self.currentSong = song
        configureSong()
        configurePlayer()
        configureSongInfoViews()
        set(button: prevSongImageView, enabled: musicPlayerDelegate?.hasPrevSong ?? false)
        set(button: nextSongImageView, enabled: musicPlayerDelegate?.hasNextSong ?? false)
        startPlayingSong()
    }
    
    
    func pause(){
        pauseSong()
    }
}

