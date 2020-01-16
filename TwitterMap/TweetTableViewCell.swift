////
////  TweetTableViewCell.swift
////  TwitterMap
////
////  Created by Russell Weber on 2020-01-14.
////  Copyright © 2020 Russell Weber. All rights reserved.
////
//
//import UIKit
//import AVFoundation
//
//class TweetTableViewCell: UITableViewCell {
//    
//    @IBOutlet weak var profilePicImageView: UIImageView!
//    @IBOutlet weak var nameLabel: UILabel!
//    @IBOutlet weak var handleLabel: UILabel!
//    @IBOutlet weak var bodyLabel: UILabel!
//    @IBOutlet weak var inlineImageView: UIImageView!
//    @IBOutlet weak var likeButton: UIButton!
//    @IBOutlet weak var retweetButton: UIButton!
//    
//    var tweet: Tweet!
//    
////    var playerController: ASVideoPlayerController?
//    var videoLayer: AVPlayerLayer = AVPlayerLayer()
//    var videoURL: String? {
//        didSet {
//            if let videoURL = videoURL {
//                ASVideoPlayerController.sharedVideoPlayer.setupVideoFor(url: videoURL)
//            }
//            videoLayer.isHidden = videoURL == nil
//        }
//    }
//    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        videoLayer.backgroundColor = UIColor.clear.cgColor
//        videoLayer.videoGravity = AVLayerVideoGravity.resize
//        inlineImageView.layer.addSublayer(videoLayer)
//        selectionStyle = .none
//    }
//    
//    
//    override func prepareForReuse() {
//        inlineImageView.imageURL = nil
//        super.prepareForReuse()
//    }
//    
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        let horizontalMargin: CGFloat = 20
//        let width: CGFloat = bounds.size.width - horizontalMargin * 2
//        let height: CGFloat = (width * 0.9).rounded(.up)
//        videoLayer.frame = CGRect(x: 0, y: 0, width: width, height: height)
//    }
//    
//    func visibleVideoHeight() -> CGFloat {
//        if (self.inlineImageView.imageURL != nil) {
//            let videoFrameInParentSuperView: CGRect? = self.superview?.superview?.convert(inlineImageView.frame, from: inlineImageView)
//            guard let videoFrame = videoFrameInParentSuperView,
//                let superViewFrame = superview?.frame else {
//                    return 0
//            }
//            let visibleVideoFrame = videoFrame.intersection(superViewFrame)
//            return visibleVideoFrame.size.height
//        }
//        return 0.0
//    }
//    
//    
//    
//    class func reuseIdentifier() -> String {
//        return "TweetTableViewCellIdentifier"
//    }
//    
//    class func nibName() -> String {
//        return "TweetTableViewCell"
//    }
//    
//    func configure(for tweet: Tweet) {
//        self.tweet = tweet
//        
//        nameLabel.text = tweet.user.name
//        handleLabel.text = "@" + tweet.user.screenName
//        bodyLabel.text = tweet.fullText
//        
//        // Update images:
//        let mediaContainer = tweet.extededEntities?.media?.first
//        print("URL:  \(tweet)")
//        self.profilePicImageView.imageURL = tweet.user.profileImageUrl!.absoluteString
//        self.inlineImageView.imageURL = mediaContainer?.mediaUrl.absoluteString
//        if (mediaContainer?.type == "video") {
//            print(tweet)
//            self.videoURL = mediaContainer!.videoInfo!.variants[1].url.absoluteString
//        }
//    }
//    
//    @IBAction func didTapLike(_ sender: Any) {
//        APIClient.like(tweet: self.tweet)
//    }
//    
//    @IBAction func didTapRetweet(_ sender: Any) {
//         APIClient.retweet(tweet: self.tweet)
//    }
//}
