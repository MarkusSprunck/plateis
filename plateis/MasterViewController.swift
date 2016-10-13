/*
 * Copyright (c) 2016 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import StoreKit

class MasterViewController: UITableViewController {
    
    let showDetailSegueIdentifier = "showDetail"
    
    var products = [SKProduct]()
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == showDetailSegueIdentifier {
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return false
            }
            
            let product = products[(indexPath as NSIndexPath).row]
            
            return PlateisProducts.store.isProductPurchased(product.productIdentifier)
        }
        
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "PLATEIS"
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(MasterViewController.reload), for: .valueChanged)
        
        let restoreButton = UIBarButtonItem(title: NSLocalizedString("RESTORE", comment:"Restore"), style: .plain, target: self, action: #selector(MasterViewController.restoreTapped(_:)))
        navigationItem.rightBarButtonItem = restoreButton
        
        let backButton = UIBarButtonItem(title: NSLocalizedString("HOME", comment:"Home"), style: .plain, target: self, action: #selector(MasterViewController.backTapped(_:)))
        navigationItem.leftBarButtonItem = backButton
        
        NotificationCenter.default.addObserver(self, selector: #selector(MasterViewController.handlePurchaseNotification(_:)),
                                               name: NSNotification.Name(rawValue: IAPHelper.IAPHelperPurchaseNotification),
                                               object: nil)
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        reload()
    }
    
    func reload() {
        products = []
        
        tableView.reloadData()
        
        PlateisProducts.store.requestProducts{success, products in
            if success {
                self.products = products!
                
                self.tableView.reloadData()
            }
            
            self.refreshControl?.endRefreshing()
        }
    }
    
    func restoreTapped(_ sender: AnyObject) {
        PlateisProducts.store.restorePurchases()
    }
    
    func backTapped(_ sender: AnyObject) {
        
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        
        let secondViewController = storyboard.instantiateViewController(withIdentifier: "PlateisId") as UIViewController
        
        let window = UIApplication.shared.windows[0] as UIWindow
        UIView.transition(
            from: window.rootViewController!.view,
            to: secondViewController.view,
            duration: 0.65,
            options: .transitionCrossDissolve,
            completion: {
                finished in window.rootViewController = secondViewController
        })
        
    }
    
    func handlePurchaseNotification(_ notification: Notification) {
        print("handlePurchaseNotification")
        guard let productID = notification.object as? String else { return }
        
        for (index, product) in products.enumerated() {
            guard product.productIdentifier == productID else { continue }
            
            tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .fade)
        }
    }
}


extension MasterViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return products.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ProductCell
        
        let product = products[(indexPath as NSIndexPath).row]
        
        cell.product = product
        cell.buyButtonHandler = { product in
            PlateisProducts.store.buyProduct(product)
        }
        
        return cell
    }
}
