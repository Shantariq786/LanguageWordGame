//
//  QuestionModel.swift
//  QuizApp
//
//  Created by Hamza on 26/01/2022.
//

import Foundation
struct QuestionModel {
    let correctOption:String?
    let categoryName:String?
    let question:String?
    init(correctOption:String,categoryName:String,question:String) {
        self.correctOption = correctOption
        self.categoryName = categoryName
        self.question = question
    }
}
