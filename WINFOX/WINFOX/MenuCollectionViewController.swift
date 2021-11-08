//
//  MenuCollectionViewController.swift
//  WINFOX
//
//  Created by  Admin on 07.11.2021.
//

import UIKit

private let reuseIdentifier = "Cell"

class MenuCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    var place: [PlacesStruct] = []
    var menu: [MenuStruct] = []
    let activityIndicator = UIActivityIndicatorView()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView!.register(UINib(nibName: "MenuCollectionViewCell", bundle: nil) , forCellWithReuseIdentifier: reuseIdentifier)
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            print(111)
            layout.scrollDirection = .vertical
        }
        collectionView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        collectionView.backgroundColor = .clear
        activityIndicator.frame = CGRect(x: view.frame.width / 2 - 10, y: view.frame.height / 2 - 10, width: 20, height: 20)
        activityIndicator.color = UIColor(red: 45 / 255, green: 205 / 255, blue: 214 / 255, alpha: 1)
        view.addSubview(activityIndicator)
        
        getMenu()
    }
    
    private func getMenu() {
        guard let id = place.first?.id else { return }
        showLoading()
        RequestManager.shared.getMenu(id: id) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let menu):
                    self?.menu = menu
                    print(self?.menu)
                    self?.collectionView.reloadData()
                    self?.showData()
                case .failure:
                    print("ERROR")
                    self?.menu = []
                    self?.showError()
                }
            }
        }
    }
    
    private func showLoading() {
           activityIndicator.isHidden = false
           activityIndicator.startAnimating()
       }
       
       private func showData() {
           activityIndicator.stopAnimating()
           activityIndicator.isHidden = true
       }
       
       private func showError() {
           activityIndicator.stopAnimating()
           activityIndicator.isHidden = true
           let alert = UIAlertController(title: "Error", message: "Something went wrong. Try again later.", preferredStyle: .alert)
           let action = UIAlertAction(title: "OK", style: .default, handler: nil)
           alert.addAction(action)
           present(alert, animated: true, completion: nil)
       }

    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return menu.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? MenuCollectionViewCell else { return UICollectionViewCell() }
        
        if menu.count != 0 {
            cell.countLabel.text = "\(menu[indexPath.item].weight) гр."
            cell.priceLabel.text = "\(menu[indexPath.item].price) руб."
            cell.nameLabel.text = menu[indexPath.item].name
            cell.descLabel.text = menu[indexPath.item].desc
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            RequestManager.shared.getImage(image: menu[indexPath.item].image) { image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell.image.image = image
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()
                }
            }
        } else {
            return UICollectionViewCell()
        }
        return cell
    }

    // MARK: UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 300, height: 200 )
    }

        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
   
    
    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
