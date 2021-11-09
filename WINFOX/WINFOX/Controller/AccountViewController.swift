//
//  AccountViewController.swift
//  WINFOX
//
//  Created by  Svetlana Frolova on 05.11.2021.
//

import UIKit

class AccountViewController: UIViewController {
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    let itemPerRow: CGFloat = 4
    let sectionInserts = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
    var places: [PlacesStruct] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundSetting()
        getPlaces()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }
    
    private func backgroundSetting() {
        logoutButton.layer.cornerRadius = 6
    }
    
    private func getPlaces() {
        showLoading()
        RequestManager.shared.getPlace { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let places):
                    self?.places = places
                    self?.collectionView.reloadData()
                    self?.showData()
                case .failure:
                    self?.places = []
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
    
    @IBAction func tapLogout(_ sender: UIButton) {
        AuthManager.shared.logout()
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let vc = storyboard.instantiateViewController(withIdentifier: "LoginController") as! LoginController
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension AccountViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return places.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? PlaceCollectionViewCell else { return UICollectionViewCell() }
        
        cell.layer.shadowRadius = 3
        if places.count != 0 {
            cell.activityIndicator.isHidden = false
            cell.activityIndicator.startAnimating()
            cell.nameLabel.text = places[indexPath.item].name
            RequestManager.shared.getImage(image: places[indexPath.item].image) { image in
                guard let image = image else { return }
                DispatchQueue.main.async {
                    cell.imageView.image = image
                    cell.activityIndicator.isHidden = true
                    cell.activityIndicator.stopAnimating()
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let paddingWidth = sectionInserts.left * (itemPerRow + 1)
        let availableWidth =  collectionView.frame.width - paddingWidth
        let widthPerItem = availableWidth / itemPerRow
        return CGSize(width: widthPerItem, height: widthPerItem )
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return sectionInserts
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInserts.left
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return sectionInserts.left
    }
}
