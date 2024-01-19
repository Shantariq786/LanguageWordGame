//
//  CategoriesManager.swift
//  QuizApp
//
//  Created by Hamza on 26/01/2022.
// captialze is spanish

import Foundation
import FirebaseFirestore
class CategoriesManager{
    static let shared = CategoriesManager()
    var answerArray = [AnswerModel]()
    
    func fetchCategories(completion:@escaping(CategoriesModel)->Void,failure:@escaping(String)->Void){
        Firestore.firestore().collection("Categories").getDocuments() { (querySnapshot, err) in
            if let err = err {
                failure(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    let category = CategoriesModel.init(
                        sortedId: document.data()["id"] as? Int ?? 0,
                        id: document.documentID,
                        name: document.data()["name"] as? String ?? "",
                        imageUrl: document.data()["imageUrl"] as? String ?? "")
                    completion(category)
                }
            }
        }
    }
    
    func fetchQuestion(catName:String,
                       languageName:String,
                       completion:@escaping([QuestionModel])->Void,
                       failure:@escaping(String)->Void){
        
        Firestore.firestore().collection("Question_\(languageName)").whereField("categoryName", isEqualTo: catName).getDocuments() { (querySnapshot, err) in
            if let err = err {
                failure(err.localizedDescription)
            } else {
                var questionArray = [QuestionModel]()
                for document in querySnapshot!.documents {
                    let question = QuestionModel.init(
                        correctOption: document.data()["correctOption"] as? String ?? "",
                        categoryName: document.data()["categoryName"] as? String ?? "",
                        question: document.data()["question"] as? String ?? "")
                    questionArray.append(question)
                }
                questionArray = questionArray.shuffled()
                completion(questionArray)
            }
        }
    }
    
    func fetchAnswers(catName:String,languageName:String,completion:@escaping()->Void,failure:@escaping(String)->Void){
        answerArray.removeAll()
        Firestore.firestore().collection("Answers_\(languageName)").whereField("categoryName", isEqualTo: catName).getDocuments() { (querySnapshot, err) in
            if let err = err {
                failure(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    let answer = AnswerModel.init(
                        id: document.documentID,
                        answer: document.data()["answer"] as? String ?? "",
                        imageUrl: document.data()["imageUrl"] as? String ?? "",
                        audioUrl: document.data()["audioUrl"] as? String ?? "")
                    
                    self.answerArray.append(answer)
                }
                completion()
            }
        }
    }
    
    
    func getAnswerArray(correctAnswer:String)->[AnswerModel]{
        var randomAnswerArray = [AnswerModel]()
        for var i in 0..<3{
            let randomAnswer = getRandomAnswers(correctAnswer: correctAnswer, randomArray: randomAnswerArray)
            randomAnswerArray.append(randomAnswer)
            i = i+1
        }
        
        // add correct answer
        if let index = answerArray.firstIndex(where: {$0.answer == correctAnswer}){
            randomAnswerArray.append(answerArray[index])
        }
        
        randomAnswerArray.shuffle()
        return randomAnswerArray
        
    }
    
    func getRandomAnswers(correctAnswer:String,randomArray:[AnswerModel])->AnswerModel{
        var randomAnswer:AnswerModel!
        while true{
            let answer = answerArray.randomElement()
            if answer?.answer != correctAnswer &&  !randomArray.contains(where: {$0.id == answer?.id}){
                randomAnswer = answer
                break
            }
        }
        return randomAnswer
    }
    
}




extension String {
    func capitalizingFirstLetter() -> String {
      return prefix(1).uppercased() + self.lowercased().dropFirst()
    }

    mutating func capitalizeFirstLetter() {
      self = self.capitalizingFirstLetter()
    }
}
