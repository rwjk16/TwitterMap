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
    
    var prototypeCell: TWTRTweetTableViewCell?
    
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
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func filterContentForSearchText(_ searchText: String, lang: String) {
        DispatchQueue.global(qos: .background).async {
            APIClient.search(for: searchText, lang: lang) { (result) in
                switch result {
                case .success(let response):
                    APIClient.client.loadTweets(withIDs: response.tweets.map({ (tweet) -> String in
                        return String(tweet.id)
                    }), completion: { (tweets, error) in
                        if let tweets = tweets {
                            self.filteredTweets = tweets
                        } else {
                            print(error!)
                        }
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    
    func handleKeyboard(notification: Notification) {
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
           guard let cell = tableView.dequeueReusableCell(withIdentifier: tweetTableCellReuseIdentifier) as? TWTRTweetTableViewCell else { return UITableViewCell() }
             let tweet: TWTRTweet
             if isFiltering {
                 tweet = filteredTweets[indexPath.row]
             } else {
                 tweet = tweets[indexPath.row]
             }

             cell.tweetView.showActionButtons = true

             cell.configure(with: tweet)

             return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let tweet = self.tweets[indexPath.row]
        self.prototypeCell?.configure(with: tweet)
        
        return TWTRTweetTableViewCell.height(for: tweet, style: TWTRTweetViewStyle.compact, width: self.view.bounds.width , showingActions:true)
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
