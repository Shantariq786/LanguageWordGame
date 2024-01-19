//
//  LanguageSelectionViewController.swift
//  QuizApp
//
//  Created by Hamza on 03/03/2022.
//

import UIKit
import Kingfisher

enum ScreenType{
    case FirstScreen
    case NotFirstScreen
}

protocol LanguageSelectionProtocol{
    func langaugeSelectionTapped()
}


class LanguageSelectionViewController: UIViewController {

    @IBOutlet weak var BackButton: UIButton!
    @IBOutlet weak var collectionview:UICollectionView!
    
    var languagesArray = [LangaugeModel]()
    var screenType:ScreenType!
    var languageSelectionProtocol:LanguageSelectionProtocol!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionview.delegate = self
        collectionview.dataSource = self
        setDesign()
        fetchLanguages()
    }
    
    func fetchLanguages(){
        LanguagesManager.shared.fetchCategories { (langauge) in
            self.languagesArray.append(langauge)
            self.languagesArray = self.languagesArray.sorted { $0.name?.lowercased() ?? "" < $1.name?.lowercased() ?? "" }
            self.collectionview.reloadData()
        } failure: { (error) in
            print("error")
        }

    }
    
    func setDesign(){
        if screenType == ScreenType.FirstScreen{
            //BackButton.isHidden = true
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension LanguageSelectionViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languagesArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesCollectionViewCell
        cell.setLanguageData(langauge: languagesArray[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let screenSize = UIScreen.main.bounds
        let size = screenSize.width/2 - 30
        return CGSize(width: size , height: size)
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        LanguageUserDefault.shared.setData(langauge: languagesArray[indexPath.row])
        
        if screenType == ScreenType.FirstScreen{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "CategoriesViewController") as! CategoriesViewController
            vc.isFromLangaugeSelection = true
            self.navigationController?.pushViewController(vc, animated: true)
        }else{
            languageSelectionProtocol.langaugeSelectionTapped()
            self.navigationController?.popViewController(animated: true)
        }
        
        
    }
    
}

