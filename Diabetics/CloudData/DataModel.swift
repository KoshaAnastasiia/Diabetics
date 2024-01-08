import Foundation

class DataModel: Codable {
    struct Measurement: Codable, Hashable{
        let date: Date
        let value: Double
        
        init(date: Date, value: Double) {
            self.date = date
            self.value = value
        }
        enum CodingKeys: CodingKey {
            case date
            case value
        }
        
        init(from decoder: Decoder) throws {
            let container: KeyedDecodingContainer<DataModel.Measurement.CodingKeys> = try decoder.container(keyedBy: DataModel.Measurement.CodingKeys.self)
            self.date = try container.decode(Date.self, forKey: DataModel.Measurement.CodingKeys.date)
            self.value = try container.decode(Double.self, forKey: DataModel.Measurement.CodingKeys.value)
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: DataModel.Measurement.CodingKeys.self)
            try container.encode(self.date, forKey: DataModel.Measurement.CodingKeys.date)
            try container.encode(self.value, forKey: DataModel.Measurement.CodingKeys.value)
        }
    }

    struct FoodInfo: Codable, Hashable {
        let date: Date
        let description: String
        let photo: String
        
        init(date: Date, description: String, photo: String) {
            self.date = date
            self.description = description
            self.photo = photo
        }
        
        enum CodingKeys: CodingKey {
            case date
            case description
            case photo
        }
    }
    
    let birthday: String?
    let firstName: String?
    let lastName: String?
    var mesurement: [Measurement]?
    var foodInfo: [FoodInfo]?
    
    init(
        birthday: String?,
        firstName: String?,
        lastName: String?,
        mesurement: [Measurement]?,
        foodInfo: [FoodInfo]?
    ) {
        self.birthday = birthday
        self.firstName = firstName
        self.lastName = lastName
        self.mesurement = mesurement
        self.foodInfo = foodInfo
    }
}

extension Decodable {
    init(from: Any) throws {
        let data = try JSONSerialization.data(withJSONObject: from)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        self = try decoder.decode(Self.self, from: data)
    }
}

extension Encodable {
    func asDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(self)
        let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
        return (dictionary as? [String: Any]) ?? [:]
    }
}

