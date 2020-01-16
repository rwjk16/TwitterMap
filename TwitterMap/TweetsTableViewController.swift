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
    
    //    var prototypeCell: TWTRTweetTableViewCell?
    
    let tweetTableCellReuseIdentifier = "cell"
    
    var isLoadingTweets = false
    
    var tweets: [TWTRTweet] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    let searchController = UISearchController(searchResultsController: nil)
    var filteredTweets: [TWTRTweet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchController()
        //        tableView.register(UINib(nibName: TweetTableViewCell.nibName(), bundle: nil), forCellReuseIdentifier: TweetTableViewCell.reuseIdentifier())
        self.tableView.register(TWTRTweetTableViewCell.self, forCellReuseIdentifier: tweetTableCellReuseIdentifier)
        self.tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataSource = self
        tableView.delegate = self
        self.tweets = APIClient.twtrTweets
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
        return searchController.isActive && (!isSearchBarEmpty)
    }
    
    func filterContentForSearchText(_ searchText: String, lang: String) {
        APIClient.search(for: searchText, lang: lang) { (result) in
            switch result {
            case .success(let response):
                APIClient.client.loadTweets(withIDs: response.tweets.map({ (tweet) -> String in
                    return String(tweet.id)
                }), completion: { (tweets, error) in
                    if let tweets = tweets {
                        self.filteredTweets = tweets
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    } else {
                        print(error!)
                    }
                })
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    
    func handleKeyboard(notification: Notification) {
        guard notification.name == UIResponder.keyboardWillChangeFrameNotification else {
            view.layoutIfNeeded()
            return
        }
        guard
            let info = notification.userInfo,
            let keyboardFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue
            else {
                return
        }
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
            return filteredTweets.count
        }
        return tweets.count
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier) as? TWTRTweetTableViewCell else { return UITableViewCell() }
        let tweet: TWTRTweet
        if isFiltering {
            tweet = filteredTweets[indexPath.row]
        } else {
            tweet = tweets[indexPath.row]
        }
        
        cell.tweetView.showActionButtons = true
        cell.prepareForReuse()
        cell.configure(with: tweet)
        
        
        return cell
    }
}

extension TweetsTableViewController: UISearchResultsUpdating, UISearchBarDelegate {
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let lang = String(searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex])
        filterContentForSearchText(searchBar.text!, lang: lang)
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let lang = String(searchBar.scopeButtonTitles![selectedScope])
        filterContentForSearchText(searchBar.text!, lang: lang)
    }
}
