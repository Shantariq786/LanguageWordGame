//
//  ViewCont roller.swift
//  QuizApp
//
//  Created by Hamza on 26/01/2022.
//

import UIKit
import Kingfisher

//MARK: -           cell

class CategoriesCollectionViewCell:UICollectionViewCell{
    @IBOutlet weak var imageview:UIImageView!
    @IBOutlet weak var title:UILabel!
    @IBOutlet weak var roundedView:UIView!
    
    let activityInd = UIActivityIndicatorView()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedView.layer.cornerRadius = 10
        roundedView.layer.borderColor = UIColor(named: "borderColor")!.cgColor
        roundedView.layer.borderWidth = 1
        
        activityInd.center = CGPoint(x: self.frame.size.width  / 2,
                                     y: self.frame.size.height / 2)
        activityInd.color = UIColor(named: "PrimaryColor")!
        self.addSubview(activityInd)
    }
    
    func setData(category:CategoriesModel){
        title.text = category.name
        
        
        guard let url = URL(string: category.imageUrl ?? "") else {return}
        let resources = ImageResource(downloadURL: url, cacheKey: url.absoluteString)

        self.activityInd.startAnimating()
        imageview.kf.setImage(with: resources, placeholder: nil, options: .none) { (result) in
            self.activityInd.stopAnimating()
        }
        
        
    }
    
    func setDataForResult(result:ResutlModel){
        if result.isTrue == true{
            roundedView.layer.borderColor = UIColor(named: "PrimaryColor")!.cgColor
        }else{
            roundedView.layer.borderColor = UIColor.red.cgColor
        }
        
        
        title.text = result.answer.answer
        
        
        
        //setting image
        
        guard let url = URL(string: result.answer.imageUrl ?? "") else {return}
        let resources = ImageResource(downloadURL: url, cacheKey: url.absoluteString)

        self.activityInd.startAnimating()
        imageview.kf.setImage(with: resources, placeholder: nil, options: .none) { (result) in
            self.activityInd.stopAnimating()
        }
          
    }
    
    func setLanguageData(langauge:LangaugeModel){
        
        title.text = langauge.name
        
        guard let url = URL(string: langauge.imageUrl ?? "") else {return}
        let resources = ImageResource(downloadURL: url, cacheKey: url.absoluteString)

        self.activityInd.startAnimating()
        imageview.kf.setImage(with: resources, placeholder: nil, options: .none) { (result) in
            self.activityInd.stopAnimating()
        }
        
    }
}


//MARK: -           class

class CategoriesViewController: UIViewController {

    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionview:UICollectionView!
    @IBOutlet weak var flagButton: UIButton!
    
    
    
    var categoriesArray = [CategoriesModel]()
    var selectedLanguage = ""
    var screenType:ScreenType!
    
    var isFromLangaugeSelection = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionview.delegate = self
        collectionview.dataSource = self
        
        fetchCategories()
        
        guard let language =  LanguageUserDefault.shared.getData() else {return}
        selectedLanguage = language.name ?? ""
        setDesign()
    }
    
    func setDesign(){
//        if screenType == ScreenType.FirstScreen{
//            backButton.isHidden = true
//        }
        
        guard let language =  LanguageUserDefault.shared.getData() else {return}
        guard let url = URL(string: language.imageUrl ?? "")  else {return}
        
        let modifier = AnyImageModifier { return $0.withRenderingMode(.alwaysOriginal) }
        flagButton.kf.setImage(with: url, for: .normal, placeholder: nil, options: [.imageModifier(modifier)], progressBlock: nil, completionHandler: nil)
    }
    
    func fetchCategories(){
        CategoriesManager.shared.fetchCategories {[self] (category) in
            categoriesArray.append(category)
            categoriesArray.sort{$0.sortedId ?? 0 < $1.sortedId ?? 0 }
            collectionview.reloadData()
        } failure: { (error) in
            print("error in fetching cat \(error)")
        }
    }
    
    @IBAction func goBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func flagBtnTapped(_ sender: UIButton) {
        if isFromLangaugeSelection == true{
            self.navigationController?.popViewController(animated: true)
        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "LanguageSelectionViewController") as! LanguageSelectionViewController
            vc.screenType = ScreenType.NotFirstScreen
            vc.languageSelectionProtocol = self
            self.navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
}

extension CategoriesViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoriesArray.count
        
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CategoriesCollectionViewCell
        cell.setData(category: categoriesArray[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let screenSize = UIScreen.main.bounds
        let size = screenSize.width/2 - 30
        return CGSize(width: size , height: size)
        
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
        vc.questionType = QuestionType.firstQuestion
        vc.category = categoriesArray[indexPath.row]
        vc.selectedLanguage = selectedLanguage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}


extension CategoriesViewController:LanguageSelectionProtocol{
    func langaugeSelectionTapped() {
        
        guard let language =  LanguageUserDefault.shared.getData() else {return}
        selectedLanguage = language.name ?? ""
        
        guard let url = URL(string: language.imageUrl ?? "")  else {return}
        
        let modifier = AnyImageModifier { return $0.withRenderingMode(.alwaysOriginal) }
        flagButton.kf.setImage(with: url, for: .normal, placeholder: nil, options: [.imageModifier(modifier)], progressBlock: nil, completionHandler: nil)
        
    }
    
    
}
