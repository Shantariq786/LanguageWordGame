

import UIKit
import GTProgressBar
import Kingfisher
import AVKit
import AVFoundation

struct ResutlModel{
    var isTrue:Bool!
    var answer:AnswerModel!
    init(isTrue:Bool,answer:AnswerModel) {
        self.isTrue = isTrue
        self.answer = answer
    }
}
enum QuestionType{
    case firstQuestion
    case notFirstQuestion
}

class QuestionCollectionViewCell:UICollectionViewCell{
    
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
    
    func setData(answer:AnswerModel){
        title.text = answer.answer
        
        //setting image
        
        guard let url = URL(string: answer.imageUrl ?? "") else {return}
        
        
        let resources = ImageResource(downloadURL: url, cacheKey: url.absoluteString)

        activityInd.startAnimating()
        imageview.kf.setImage(with: resources, placeholder: nil, options: .none) { (result) in
            self.activityInd.stopAnimating()
        }
        
    }
    
}



class QuestionViewController: UIViewController, AVAudioPlayerDelegate {

    @IBOutlet weak var collectionview:UICollectionView!
    @IBOutlet weak var progressBar: GTProgressBar!
    @IBOutlet weak var checkBtn: UIButton!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var questionCountLabel: UILabel!
    
    var category:CategoriesModel!
    var questionsArray = [QuestionModel]()
    var randomAnswerArray = [AnswerModel]()
    var resultArray = [ResutlModel]()
    var downloadAudiosData:[Data] = [Data(),Data(),Data(),Data()]
    var questionType:QuestionType!
    var currentQuestion:Int = 0
    var correctCount = 0
    var selectedOptionIndex:Int!
    
    var selectedLanguage = ""
    
    var player = AVAudioPlayer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkBtn.isUserInteractionEnabled = false
        checkBtn.backgroundColor = UIColor(named: "borderColor")!
        
        checkScreen()
        
        guard let language =  LanguageUserDefault.shared.getData() else {return}
        selectedLanguage = language.name ?? ""
        
    }
    
    func checkScreen(){
        if questionType == QuestionType.firstQuestion{
            
            progressBar.progress = 0
            fetchQuestion()
        }else{
            questionCountLabel.text = "\(currentQuestion)/\(questionsArray.count)"
            questionLabel.text = questionsArray[currentQuestion].question
            progressBar.progress = CGFloat(currentQuestion)/CGFloat(questionsArray.count)
            makeRandonAnswerArray()
            
        }
    }
    
    func fetchQuestion(){
        CategoriesManager.shared.fetchQuestion(catName: category.name ?? "",languageName:selectedLanguage) {[self] (questionArray) in
            questionsArray = questionArray
            questionLabel.text = questionsArray[currentQuestion].question
            questionCountLabel.text = "\(currentQuestion)/\(questionsArray.count)"
            fetchAnswers()
        } failure: { (error) in
            print(error)
        }
    }
    
    func fetchAnswers(){
        CategoriesManager.shared.fetchAnswers(catName: category.name ?? "",languageName:selectedLanguage){[self] in
            //show answer
            makeRandonAnswerArray()
        } failure: { (error) in
            print(error)
        }
    }
    
    func makeRandonAnswerArray(){
        randomAnswerArray = CategoriesManager.shared.getAnswerArray(
            correctAnswer: questionsArray[currentQuestion].correctOption ?? "")
        collectionview.reloadData()
        downloadAudios()
    }
    
    @IBAction func corssBtnTapped(_ sender: UIButton) {
        for controller in self.navigationController!.viewControllers as Array {
            if controller.isKind(of: CategoriesViewController.self) {
                self.navigationController!.popToViewController(controller, animated: true)
                break
            }
        }
    }
    
    @IBAction func checkBtnTapped(_ sender: Any) {
        var isCorrect = false
        if randomAnswerArray[selectedOptionIndex].answer == questionsArray[currentQuestion].correctOption{
            correctCount = correctCount+1
            isCorrect = true
        }
        
        resultArray.append(ResutlModel.init(isTrue: isCorrect, answer: randomAnswerArray[getIndex()]))
        
        // play an audio
        playCorrectOrWrongAudio(isCorrect)
        
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "BottomSheetViewController") as! BottomSheetViewController
        vc.modalPresentationStyle = .overCurrentContext
        vc.bottomShetProtocol = self
        vc.isCorrect = isCorrect
        vc.correctOptionText = questionsArray[currentQuestion].correctOption ?? ""
        self.present(vc, animated: false, completion: nil)
    }
    
    
    func playCorrectOrWrongAudio(_ isCorrect:Bool){
        var url:URL?
        if isCorrect == true{
            url = Bundle.main.url(forResource: "correct", withExtension: "wav")
        }else{
            url = Bundle.main.url(forResource: "wrong", withExtension: "wav")
        }
        
        do {
            player = try AVAudioPlayer(contentsOf: url!)
            player.play()
        } catch {
            print("error occur")
        }
        
    }
    
    func getIndex()->Int{
        var index = 0
        for i in 0..<randomAnswerArray.count{
            if randomAnswerArray[i].answer == questionsArray[currentQuestion].correctOption{
                index = i
            }
        }
        return index
    }
    
}

//MARK: -                       COLLECTIONVIEW
extension QuestionViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return randomAnswerArray.count
        
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! QuestionCollectionViewCell
        cell.setData(answer: randomAnswerArray[indexPath.row])
        if indexPath.item == selectedOptionIndex{
            cell.roundedView.backgroundColor = UIColor(named: "answerBoxSelectedColor")!
        }else{
            cell.roundedView.backgroundColor = UIColor.clear
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize{
        let screenSize = UIScreen.main.bounds
        let width = screenSize.width/2 - 30
        let height = screenSize.height/2 - 150
        return CGSize(width: width , height: height)
        
    }
   
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedOptionIndex = indexPath.item
        collectionview.reloadData()
        checkBtn.isUserInteractionEnabled = true
        checkBtn.backgroundColor = UIColor(named: "PrimaryColor")!
        
        play(data: downloadAudiosData[indexPath.row])
    }
    
}

//MARK: -                       AUDIO PLAYER
extension QuestionViewController{
    func downloadAudios(){
        for i in 0..<randomAnswerArray.count{
            guard let url = URL(string: randomAnswerArray[i].audioUrl ?? "") else {return}
            downloadFile(withUrl: url) { (data) in
                self.downloadAudiosData[i] = data
            }
        }
    }
    
    func downloadFile(withUrl url: URL,completion:@escaping(Data)->Void){
        DispatchQueue.global(qos: .background).async {
            do {
                let data = try Data.init(contentsOf: url)
                completion(data)
            } catch {
                print("an error happened while downloading or saving the file")
            }
        }
    }
    
    func play(data:Data) {
        do {
            player = try AVAudioPlayer(data: data)
            player.play()
        } catch {
            
            print("error occur")
        }
    }
    
}


//MARK: -                       CUSTOM PROTOCOL
extension QuestionViewController:BottomShetProtocol{
    func nextBtnTapped() {
        if currentQuestion == questionsArray.count - 1{
            print("move to result screen")
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "resultViewController") as! resultViewController
            vc.totalCount = questionsArray.count
            vc.obtainCount = correctCount
            vc.resultArray = resultArray
            self.navigationController?.pushViewController(vc, animated: true)
            
        }else{
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "QuestionViewController") as! QuestionViewController
            vc.questionType = QuestionType.notFirstQuestion
            vc.questionsArray = questionsArray
            vc.currentQuestion = currentQuestion+1
            vc.correctCount = correctCount
            vc.resultArray = resultArray
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    
}
