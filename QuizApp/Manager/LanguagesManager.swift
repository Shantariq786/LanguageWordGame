
import Foundation
import FirebaseFirestore

struct LangaugeModel:Codable{
    var imageUrl:String?
    var name:String?
    init(imageUrl:String,name:String){
        self.imageUrl = imageUrl
        self.name = name
    }
}

class LanguagesManager{
    static let shared = LanguagesManager()
    
    func fetchCategories(completion:@escaping(LangaugeModel)->Void,failure:@escaping(String)->Void){
        Firestore.firestore().collection("Languages").getDocuments() { (querySnapshot, err) in
            if let err = err {
                failure(err.localizedDescription)
            } else {
                for document in querySnapshot!.documents {
                    
                    let langauge = LangaugeModel.init(
                        imageUrl: document.data()["imageUrl"] as? String ?? "",
                        name: document.data()["name"] as? String ?? "")
                    completion(langauge)
                    
                }
            }
        }
    }
}
