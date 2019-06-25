//
//  MasterViewController.swift
//  NyTimes
//
//  Created by Maseeh Ahmed on 5/15/19.
//  Copyright © 2019 talat. All rights reserved.
//

import UIKit

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var articles = [MArticle]()     //It will contain all articles
    @IBOutlet var tblArticles: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
      
        
        configureView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

    }
    
    func configureView() {
        // Update the user interface for the detail item.
        ArticleRequest() { (result:Bool) -> (Void) in           // A request to pull article is initiated
            if(result){
                
                self.tblArticles.reloadData()
            }else{
                self.ShowAlert(message: AppStrings.kLoadingFailed)
                
            }
        }
    }
    
    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == AppStrings.kSegueIdentifier {
            if let indexPath = tableView.indexPathForSelectedRow {
                let article = articles[indexPath.row]
                let controller = segue.destination as! DetailViewController
                
                controller.article = article
                controller.navigationItem.leftItemsSupplementBackButton = true
            }
        }
    }

    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = "ArticleCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ArticleCell  else {
            fatalError("The dequeued cell is not an instance of RecentTableViewCell.")
        }

        let article = articles[indexPath.row]
        cell.lblTitle.text = article.articleTitle
        cell.lblPublishedBy.text = article.publishedBy
        cell.lblPublishedDate.text = article.publishDate

        cell.imgThumbnail.downloadImageFrom(link: article.thumbnailUrl ?? "", contentMode: UIView.ContentMode.scaleAspectFit)
        cell.imgThumbnail.layer.cornerRadius = cell.imgThumbnail.frame.size.width / 2
        cell.imgThumbnail.clipsToBounds = true
        return cell
    }


    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        
        self.performSegue(withIdentifier: AppStrings.kSegueIdentifier, sender: self)
        tableView.deselectRow(at: indexPath, animated: false)
        }
    
    
    func ArticleRequest(withCompletionHandlerHomeData: @escaping (_ result:Bool)->(Void) ) {
        
       
            WebManager.GetArticleInfoFromApi() { (responseObject) -> (Void) in  // WebManager will deal all the requests to webservices.

                if responseObject != nil {
                    if let response = responseObject {
                        
                        let status = response["status"] as! String              // The status is a response status from the api.
                        if (status.lowercased() == "ok"){
                        
                            let articles = response["articles"] as! [AnyObject]     // All the news articles will be extracted from the response
                            
                            for article in articles {                               // assigning the articles to Model
                               
                                let article = MArticle(articleTitle: article["title"] as? String ?? "", publishDate: article["publishedAt"] as? String ?? "", publishedBy: article["author"] as? String ?? "", articleUrl: article["url"] as? String ?? "", thumbnailUrl: article["urlToImage"] as? String ?? "")
                                
                                self.articles.append(article)           // these articles will be loaded in table view
                                
                            }
                        withCompletionHandlerHomeData(true)
                    }
                        else{
                            print("failed 1");
                            withCompletionHandlerHomeData(false)
                        }
                    }
                    
                }
                
            }
    }
    
    
     func ShowAlert(message: String) {
        
        // Alert controller will display messages related to app.
        let alertController = UIAlertController(title: AppStrings.ApplicationName, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) {
            UIAlertAction in
        }
    
        
        alertController.addAction(okAction)
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    
}

// An extension to UIImage view is created so that images keep loading in background thread without affecting UIscrolling and ui thread.
extension UIImageView {
    func downloadImageFrom(link:String, contentMode: UIView.ContentMode) {
        URLSession.shared.dataTask(with: NSURL(string:link)! as URL, completionHandler: {
            (data, response, error) -> Void in
            DispatchQueue.main.async {
                self.contentMode =  contentMode
                if let data = data { self.image = UIImage(data: data) }
            }
        }).resume()
    }
}

