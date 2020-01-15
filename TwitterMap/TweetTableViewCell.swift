//
//  TweetTableViewCell.swift
//  TwitterMap
//
//  Created by Russell Weber on 2020-01-14.
//  Copyright © 2020 Russell Weber. All rights reserved.
//

import UIKit

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profilePicImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var handleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var inlineImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    
    var tweet: Tweet!
    
    
    
    class func reuseIdentifier() -> String {
        return "TweetTableViewCellIdentifier"
    }
    
    class func nibName() -> String {
        return "TweetTableViewCell"
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //        self.retweetButton.imageView?.image = UIImage(named: "retweetOff")
        //        self.likeButton.imageView?.image = UIImage(named: "likeOff")
        // Initialization code
    }
    
    func configure(for tweet: Tweet) {
        self.tweet = tweet
        
        nameLabel.text = tweet.user.name
        handleLabel.text = "@" + tweet.user.screenName
        bodyLabel.text = tweet.text
        
        // Update images:
        self.updateImage(imageview: self.profilePicImageView, imageUrl: tweet.user.profileImageUrlHttps, mediaURL: tweet.mediaURL)
        
        // if verifyUrl(urlString: viewModel.inlinePic) { self.load_image(urlString: viewModel.inlinePic) }
    }
    
    func updateImage(imageview: UIImageView, imageUrl: String, mediaURL: String?) {
        imageview.image = nil
        inlineImageView.image = nil
        
        // If valid url
        if verifyUrl(urlString: imageUrl) {
            
            let imageURL: URL = NSURL(string: imageUrl)! as URL
            
            APIClient.downloadImage(for: imageURL) { (result) in
                switch result {
                case .success(let data):
                    let image = UIImage(data: data)
                    self.profilePicImageView.image = image
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        } else {
            if imageview == self.profilePicImageView {
                imageview.image = UIImage(named: "default_profile")
            }
        }
        
        if verifyUrl(urlString: mediaURL) {
            let imageURL = URL(string: mediaURL!)!
            
            APIClient.downloadImage(for: imageURL) { (result) in
                switch result {
                case .success(let data):
                    let image = UIImage(data: data)
                    self.inlineImageView.image = image
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    // Second method for image download + update
    func load_image(urlString:String) {
        self.inlineImageView.image = nil
        
        let imgURL = URL(string: urlString)!
        
        DispatchQueue.global(qos: .background).async {
            
            let imageData:NSData = NSData(contentsOf: imgURL)!
            // When from background thread, UI needs to be updated on main_queue
            DispatchQueue.main.async {
                let image = UIImage(data: imageData as Data)
                self.inlineImageView.image = image
            }
        }
    }
    
    
    func verifyUrl (urlString: String?) -> Bool {
        //Check for nil
        if let urlString = urlString, urlString != "" {
            // create NSURL instance
            if let url = NSURL(string: urlString) {
                // check if your application can open the NSURL instance
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }
    
    
}
