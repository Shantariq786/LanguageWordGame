//
//  AnswerModel.swift
//  QuizApp
//
//  Created by Hamza on 27/01/2022.
//

import Foundation
struct AnswerModel{
    var id:String?
    var answer:String?
    var imageUrl:String?
    var audioUrl:String?
    init(id:String,answer:String,imageUrl:String,audioUrl:String) {
        self.id = id
        self.answer = answer
        self.imageUrl = imageUrl
        self.audioUrl = audioUrl
    }
}
