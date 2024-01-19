//
//  CategoriesModel.swift
//  QuizApp
//
//  Created by Hamza on 26/01/2022.
//

import Foundation
struct CategoriesModel{
    var sortedId:Int?
    var id:String?
    var name:String?
    var imageUrl:String?
    init(sortedId:Int,id:String,name:String,imageUrl:String) {
        self.sortedId = sortedId
        self.id = id
        self.name = name
        self.imageUrl = imageUrl
    }
}
