

import Foundation
struct  userDefaultNames {
    
    struct Keys {
        static let userDataUserDefaultName = "Language"
    }
}
struct LanguageUserDefault {
    static let shared = LanguageUserDefault.init()
    let keyforLaunch = userDefaultNames.Keys.userDataUserDefaultName
    func setData(langauge:LangaugeModel){
        do {
            // Create JSON Encoder
            let encoder = JSONEncoder()

            // Encode Note
            let data = try encoder.encode(langauge)
            UserDefaults.standard.set(data, forKey: keyforLaunch)

        } catch {
            print("Unable to Encode Note (\(error))")
        }
    }
    func getData()->LangaugeModel?{
        if let data = UserDefaults.standard.data(forKey: keyforLaunch) {
            do {
                    // Create JSON Decoder
                    let decoder = JSONDecoder()

                    // Decode Note
                let langaugeData = try decoder.decode(LangaugeModel.self, from: data)
                return langaugeData

                } catch {
                    print("Unable to Decode Note (\(error))")
                    return nil
                }
        }else{
            return nil
        }
    }
}

