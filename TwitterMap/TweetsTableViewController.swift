////
////  TweetsTableViewController.swift
////  TwitterMap
////
////  Created by Russell Weber on 2020-01-13.
////  Copyright © 2020 Russell Weber. All rights reserved.
////
//

import UIKit
import TwitterKit

class TweetsTableViewController: UIViewController {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchFooter: SearchFooter!
    @IBOutlet var searchFooterBottomConstraint: NSLayoutConstraint!
    
    var tweets: [Tweet] = []
    let searchController = UISearchController(searchResultsController: nil)
    var filteredTweets: [Tweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tweets = APIClient.fetchedTweets
        setupSearchController()
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib(nibName: TweetTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: TweetTableViewCell.reuseIdentifier())
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, lang: Tweet.Language) {
        APIClient.search(for: searchText, lang: lang.rawValue) { (result) in
            switch result {
            case .success(let response):
                self.filteredTweets = response.tweets
                self.tableView.reloadData()
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func handleKeyboard(notification: Notification) {
        // 1
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            searchFooterBottomConstraint.constant = 0
            view.layoutIfNeeded()
            return
        }
        
        guard
            let info = notification.userInfo,
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else {
                return
        }
        
        // 2
        let keyboardHeight = keyboardFrame.cgRectValue.size.height
        UIView.animate(withDuration: 0.1, animations: { () -> Void in
            self.searchFooterBottomConstraint.constant = keyboardHeight
            self.view.layoutIfNeeded()
        })
    }
    
    func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Tweets"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        searchController.searchBar.scopeButtonTitles = ["en", "fr"]
        searchController.searchBar.delegate = self
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
        notificationCenter.addObserver(forName: UIResponder.keyboardWillHideNotification,
                                       object: nil, queue: .main) { (notification) in
                                        self.handleKeyboard(notification: notification) }
    }
}

extension TweetsTableViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            searchFooter.setIsFilteringToShow(filteredItemCount:
                filteredTweets.count, of: tweets.count)
            return filteredTweets.count
        }
        
        searchFooter.setNotFiltering()
        return tweets.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: TweetTableViewCell.reuseIdentifier()) as? TweetTableViewCell else { return UITableViewCell() }
        let tweet: Tweet
        if isFiltering {
            tweet = filteredTweets[indexPath.row]
        } else {
            tweet = tweets[indexPath.row]
        }
        
        cell.configure(for: tweet)
        
        return cell
    }
}

extension TweetsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        if let lang = Tweet.Language(rawValue:
            searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]) {
            filterContentForSearchText(searchBar.text!, lang: lang)
        }
    }
}

extension TweetsTableViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        if let lang = Tweet.Language(rawValue:
            searchBar.scopeButtonTitles![selectedScope]) {
            filterContentForSearchText(searchBar.text!, lang: lang)
        }
    }
}

class SearchFooter: UIView {
    let label = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        configureView()
    }
    
    override func draw(_ rect: CGRect) {
        label.frame = bounds
    }
    
    func setNotFiltering() {
        label.text = ""
        hideFooter()
    }
    
    func setIsFilteringToShow(filteredItemCount: Int, of totalItemCount: Int) {
        if (filteredItemCount == totalItemCount) {
            setNotFiltering()
        } else if (filteredItemCount == 0) {
            label.text = "No items match your query"
            showFooter()
        } else {
            label.text = "Filtering \(filteredItemCount) of \(totalItemCount)"
            showFooter()
        }
    }
    
    func hideFooter() {
        UIView.animate(withDuration: 0.7) {
            self.alpha = 0.0
        }
    }
    
    func showFooter() {
        UIView.animate(withDuration: 0.7) {
            self.alpha = 1.0
        }
    }
    
    func configureView() {
        backgroundColor = UIColor.blue
        alpha = 0.0
        
        label.textAlignment = .center
        label.textColor = UIColor.white
        addSubview(label)
    }
}






/*
 import UIKit
 import TwitterKit
 
 class TweetsTableViewController : UITableViewController {
 
 // setup a 'container' for Tweets
 var tweets: [TWTRTweet] = [] {
 didSet {
 tableView.reloadData()
 }
 }
 
 var prototypeCell: TWTRTweetTableViewCell?
 
 let tweetTableCellReuseIdentifier = "cell"
 
 var isLoadingTweets = false
 
 @IBOutlet weak var searchBar: UISearchBar!
 
 override func viewDidLoad() {
 super.viewDidLoad()
 login()
 if let user = TWTRTwitter.sharedInstance().sessionStore.session()?.userID {
 TWTRTwitter.sharedInstance().sessionStore.logOutUserID(user)
 }
 
 self.tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
 
 // Create a single prototype cell for height calculations.
 self.prototypeCell = TWTRTweetTableViewCell(style: .default, reuseIdentifier: tweetTableCellReuseIdentifier)
 
 // Register the identifier for TWTRTweetTableViewCell.
 self.tableView.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableCellReuseIdentifier)
 
 // Setup table data
 loadTweets()
 }
 
 func loadTweets() {
 // Do not trigger another request if one is already in progress.
 if self.isLoadingTweets {
 return
 }
 self.isLoadingTweets = true
 
 // set tweetIds to find
 let tweetIDs = APIClient.fetchedTweets.map { (tweet) -> String in
 return String(tweet.id)
 };
 
 // Find the tweets with the tweetIDs
 let client = TWTRAPIClient()
 client.loadTweets(withIDs: tweetIDs) { (twttrs, error) -> Void in
 
 // If there are tweets do something magical
 if ((twttrs) != nil) {
 
 // Loop through tweets and do something
 for i in twttrs! {
 // Append the Tweet to the Tweets to display in the table view.
 self.tweets.append(i as TWTRTweet)
 }
 } else {
 print(error as Any)
 }
 }
 }
 
 }
 
 // MARK
 // MARK: UITableViewDataSource UITableViewDelegate
 
 extension TweetsTableViewController {
 
 override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 // Return the number of Tweets.
 return tweets.count
 }
 
 override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 // Retrieve the Tweet cell.
 let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier, for: indexPath) as! TWTRTweetTableViewCell
 
 // Assign the delegate to control events on Tweets.
 cell.tweetView.delegate = self
 cell.tweetView.showActionButtons = true
 
 // Retrieve the Tweet model from loaded Tweets.
 let tweet = tweets[indexPath.row]
 
 // Configure the cell with the Tweet.
 cell.configure(with: tweet)
 
 // Return the Tweet cell.
 return cell
 }
 
 override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
 let tweet = self.tweets[indexPath.row]
 self.prototypeCell?.configure(with: tweet)
 
 return TWTRTweetTableViewCell.height(for: tweet, style: TWTRTweetViewStyle.compact, width: self.view.bounds.width , showingActions:true)
 }
 
 func login() {
 TWTRTwitter.sharedInstance().logIn(with: self) { (session, error) in
 if (session != nil) {
 print("signed in as \(String(describing: session?.userName))");
 
 self.dismiss(animated: true) {
 print("Logged in ")
 }
 let client = TWTRAPIClient.withCurrentUser()
 
 client.requestEmail { email, error in
 var emailStr = ""
 if (email != nil) {
 emailStr = email!
 } else {
 print("error: \(error!.localizedDescription)");
 }
 
 
 if let userName = session?.userName {
 let client = TWTRAPIClient(userID: session!.userID)
 client.loadUser(withID: session!.userID) { (unwrappedTwtrUser, error) in
 guard let twtrUser = unwrappedTwtrUser, error == nil else {
 print("Twitter : TwTRUser is nil, or error has occured: ")
 print("Twitter error: \(error!.localizedDescription)")
 return
 }
 let name = twtrUser.name
 let imageUrl = twtrUser.profileImageMiniURL
 let token = session!.authToken
 }
 
 
 }
 
 }
 } else {
 print("error: \(error?.localizedDescription ?? "")");
 }
 }
 }
 }
 
 extension TweetsTableViewController : TWTRTweetViewDelegate  {
 //Handle Following Events As Per Your Needs
 func tweetView(_ tweetView: TWTRTweetView, didTap url: URL) {
 
 }
 
 func tweetView(_ tweetView: TWTRTweetView, didTapVideoWith videoURL: URL) {
 
 }
 
 func tweetView(_ tweetView: TWTRTweetView, didTap image: UIImage, with imageURL: URL) {
 
 }
 
 func tweetView(_ tweetView: TWTRTweetView, didTap tweet: TWTRTweet) {
 
 }
 
 func tweetView(_ tweetView: TWTRTweetView, didTapProfileImageFor user: TWTRUser) {
 
 }
 
 func tweetView(_ tweetView: TWTRTweetView, didChange newState: TWTRVideoPlaybackState) {
 
 }
 
 }
 
 
 // MARK: Core data func
 
 //    func saveTweetsIntoCoreData(){
 //
 //        let appDelegate =
 //            UIApplication.shared.delegate as! AppDelegate
 //
 //        // Grab app context
 //        let managedContext = managedObjectContext
 //
 //        for (key, value) in selectedTweetData {
 //            // Loop through local data array and save tweet data into entity type on data stack
 //            let text = value["text"] as! String
 //
 //            let user = value["user"] as! NSDictionary
 //            let url = user["profile_image_url"] as! String
 //
 //            // Load defined core data type
 //            let entity =  NSEntityDescription.entityForName("Tweet",
 //                inManagedObjectContext:
 //                managedContext)
 //            let tweet = NSManagedObject(entity: entity!,
 //                insertIntoManagedObjectContext:managedContext)
 //
 //            // Input data
 //            tweet.setValue(text, forKey: "text")
 //            tweet.setValue(url, forKey: "imageURL")
 //
 //            // Complete save and handle potential erro
 //            var error: NSError?
 //            if !managedContext.save(&error) {
 //                println("Could not save \(error), \(error?.userInfo)")
 //            }
 //
 //
 //
 //        }
 //
 //    }
 
 //}
 
 
 //import UIKit
 //
 //class TweetsTableViewController: UITableViewController {
 //
 //    override func viewDidLoad() {
 //        super.viewDidLoad()
 //
 //        // Uncomment the following line to preserve selection between presentations
 //
 //        // self.clearsSelectionOnViewWillAppear = false
 //
 ////        self.tableView.register(TweetTableViewCell.self, forCellReuseIdentifier: "cell")
 //
 //
 //        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
 //        // self.navigationItem.rightBarButtonItem = self.editButtonItem
 //    }
 //
 //    override func viewWillAppear(_ animated: Bool) {
 //        self.tableView.reloadData()
 //    }
 //
 //    // MARK: - Table view data source
 //
 //    override func numberOfSections(in tableView: UITableView) -> Int {
 //        // #warning Incomplete implementation, return the number of sections
 //        return 1
 //    }
 //
 //    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
 //        // #warning Incomplete implementation, return the number of rows
 //        return APIClient.fetchedTweets.count
 //    }
 //
 //    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
 //        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? TweetTableViewCell else { return UITableViewCell()}
 //        let tweet = APIClient.fetchedTweets[indexPath.row]
 //        print("ADDING TWEET TO TABLE: \(tweet)")
 //        cell.titleLabel.text = "@" + tweet.user.screenName
 //        cell.subtitleLabel.text = tweet.text
 //        cell.subtitleLabel.numberOfLines = 0
 //
 //
 //        // Configure the cell...
 //
 //        return cell
 //    }
 //
 //    /*
 //    // Override to support conditional editing of the table view.
 //    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
 //        // Return false if you do not want the specified item to be editable.
 //        return true
 //    }
 //    */
 //
 //    /*
 //    // Override to support editing the table view.
 //    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
 //        if editingStyle == .delete {
 //            // Delete the row from the data source
 //            tableView.deleteRows(at: [indexPath], with: .fade)
 //        } else if editingStyle == .insert {
 //            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 //        }
 //    }
 //    */
 //
 //    /*
 //    // Override to support rearranging the table view.
 //    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
 //
 //    }
 //    */
 //
 //    /*
 //    // Override to support conditional rearranging of the table view.
 //    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
 //        // Return false if you do not want the item to be re-orderable.
 //        return true
 //    }
 //    */
 //
 //    /*
 //    // MARK: - Navigation
 //
 //    // In a storyboard-based application, you will often want to do a little preparation before navigation
 //    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 //        // Get the new view controller using segue.destination.
 //        // Pass the selected object to the new view controller.
 //    }
 //    */
 //
 //}
 */
