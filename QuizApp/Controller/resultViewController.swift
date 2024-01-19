//
//  resultViewController.swift
//  QuizApp
//
//  Created by Hamza on 27/01/2022.
//

import UIKit

class resultViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var resultLabel: UILabel!
    
    var totalCount = 0
    var obtainCount = 0
    var userAnswerArray = [Bool]()
    var resultArray = [ResutlModel]()
    override func viewDidLoad() {
        super.viewDidLoad()

        resultLabel.text = "\(obtainCount)/\(totalCount)"
        
    }
    
    @IBAction func goHome(_ sender: Any) {
        
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: CategoriesViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }

}

extension resultViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    // Headers
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        let correctArray = resultArray.filter({$0.isTrue == true})
        let wrongArray = resultArray.filter({$0.isTrue == false})
        if section == 0 && correctArray.count == 0{
            return CGSize(width: 0, height: 0)
        }else if section == 1 && wrongArray.count == 0{
            return CGSize(width: 0, height: 0)
        }else{
            return CGSize(width: collectionView.bounds.width, height: 44)
        }
        
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "HomeCollectionReusableView", for: indexPath) as! HomeCollectionReusableView
        if indexPath.section == 0{
            header.title.text = "Correct Answers"
            header.title.textColor = UIColor(named: "PrimaryColor")
        }else{
            header.title.text = "Wrong Answers"
            header.title.textColor = UIColor.red
        }
        return header
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 0{
            let correctArray = resultArray.filter({$0.isTrue == true})
            return correctArray.count
        }else{
            let wrongArray = resultArray.filter({$0.isTrue == false})
            return wrongArray.count
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.section == 0{
            //show right
            let correctArray = resultArray.filter({$0.isTrue == true})
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesCollectionViewCell
            cell.setDataForResult(result: correctArray[indexPath.row])
            return cell
        }else{
            //show wrong
            let correctArray = resultArray.filter({$0.isTrue == false})
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesCollectionViewCell
            cell.setDataForResult(result: correctArray[indexPath.row])
            return cell
        }
        
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let screenSize = UIScreen.main.bounds
        let size = screenSize.width/2 - 30
        return CGSize(width: size , height: size)
        
    }
    
}
