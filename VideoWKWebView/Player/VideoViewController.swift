//
//  VideoViewController.swift
//  VideoWKWebView
//
//  Created by Shingo Fukuyama on 2018/08/18.
//  Copyright © 2018 Shingo Fukuyama. All rights reserved.
//

import UIKit
import AVKit

class VideoViewController: UIViewController {

    fileprivate let player: Player = Player()

    fileprivate var playerForBackground: AVPlayer?

    fileprivate lazy var label: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        label.text = "Background play is available\nバックグラウンド再生可能"
        label.numberOfLines = 0
        return label
    }()

    required init?(coder aDecoder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    private override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    convenience init(with url: URL) {
        self.init(nibName: nil, bundle: nil)
        player.url = url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = #colorLiteral(red: 0.1410655081, green: 0.1400279999, blue: 0.1418641508, alpha: 1)

        player.playerDelegate = self
        player.playbackDelegate = self
        player.view.frame = view.bounds
        addChildViewController(player)
        view.addSubview(player.view)
        player.didMove(toParentViewController: self)
        player.playFromBeginning()
        // prevent default lifecycle
        player.playbackPausesWhenResigningActive = false
        player.playbackResumesWhenBecameActive = false
        player.playbackPausesWhenBackgrounded = false
        player.playbackResumesWhenEnteringForeground = false

        ext.setupAppStateObservers(to: #selector(self.didReceiveAppStateChange(notification:)))

        showLabel()
    }

}

extension VideoViewController: PlayerPlaybackDelegate {

    func playerCurrentTimeDidChange(_ player: Player) {

    }

    func playerPlaybackWillStartFromBeginning(_ player: Player) {

    }

    func playerPlaybackDidEnd(_ player: Player) {

    }

    func playerPlaybackWillLoop(_ player: Player) {

    }

}

extension VideoViewController: PlayerDelegate {

    func playerReady(_ player: Player) {

    }

    func playerPlaybackStateDidChange(_ player: Player) {

    }

    func playerBufferingStateDidChange(_ player: Player) {

    }

    func playerBufferTimeDidChange(_ bufferTime: Double) {

    }

    func player(_ player: Player, didFailWithError error: Error?) {

    }

}

fileprivate extension VideoViewController {

    /// Playing Audio from a Video Asset in the Background
    /// https://developer.apple.com/documentation/avfoundation/media_assets_playback_and_editing/creating_a_basic_video_player_ios_and_tvos/playing_audio_from_a_video_asset_in_the_background
    @objc func didReceiveAppStateChange(notification: Notification) {
        switch notification.name {
        case .UIApplicationWillEnterForeground:
            if let avPlayer = playerForBackground {
                player.playerView.player = avPlayer
                playerForBackground = nil
            }
            break
        case .UIApplicationDidBecomeActive:
            break
        case .UIApplicationWillResignActive:
            break
        case .UIApplicationDidEnterBackground:
            if let avPlayer = player.playerView.player {
                playerForBackground = avPlayer
                player.playerView.player = nil
            }
        case .UIApplicationWillTerminate:
            break
        default:
            break
        }
    }

    func showLabel() {
        view.addSubview(label)
        let sideMargin: CGFloat = 20
        let heightRatio: CGFloat = 0.2
        var labelRect = view.bounds
        labelRect.origin.y = labelRect.height * (1.0 - heightRatio)
        labelRect.size.height *= heightRatio
        labelRect.origin.x += sideMargin
        labelRect.size.width -= sideMargin * 2
        label.frame = labelRect
    }

}
