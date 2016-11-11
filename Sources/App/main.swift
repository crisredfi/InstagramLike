import Vapor
import PostgreSQL
import HTTP
//import Foundation

enum gasStations: String {
    case GNC
    case GPR
    case G98
    case GOA
    case NGO
    case GOB
    case GOC
    case BIO
    case G95
    case BIE
    case GLP
    static let allValues = [GNC, GPR, G98, GOA, NGO, GOB, GOC, BIO, G95, BIE, GLP]
//    static let allValues = [GNC]

}

let drop = Droplet()
let postgreSQL =  PostgreSQL.Database(
    dbname: "GasStations",
    user: "crisredfi",
    password: ""
)

//drop.get("version") { request in
//    downloadGNCData()
//    do {
//
//        //let version = try postgreSQL.execute("SELECT version()")
//        //return  version
//        let session = URLSession.shared
//        for gas in gasStations.allValues {
//            let request = NSMutableURLRequest(url: URL(string:"http://gas.saliou.name/json/latest/\(gas.rawValue).json")!)
//            let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
//                guard let jsonWithObjectRoot = try? JSONSerialization.jsonObject(with: data!, options: []) else {
//                    return
//                }
//                do {
//                    let connection = try postgreSQL.makeConnection()
//                    let _ = try postgreSQL.execute("DELETE FROM gas_station type='\(gas.rawValue)'")
//                } catch {
//
//                }
//                for dict in jsonWithObjectRoot as! [[String: AnyObject]] {
//                    let lat = dict["lng"] as! Float
//                    let long = dict["lat"] as! Float // lat long are wrong in the py server
//                    let name = dict["name"] as! String
//                    let price = dict["price"] as! Float
//
//                    do {
//                        let connection = try postgreSQL.makeConnection()
//
//                        let _ = try postgreSQL.execute("Insert INTO gas_station(name, price, lattitude, longitude, type) VALUES('"+name+"', '\(price)', '\(lat)', '\(long)', '\(gas.rawValue)')")
//                    } catch {
//                        print("error executing")
//                        
//                    }
//                    
//                }
//            }
//            
//            task.resume()
//        }
//
//        return "hello world"
//    } catch {
//        return "NO DB connection"
//    }
//}

drop.post("addPost") { request in
    guard let name = request.data["name"]?.string ,
    let userOwnwer = request.data["userOwner"]?.string else {
        throw Abort.badRequest
    }

    do {
        let connection = try postgreSQL.makeConnection()
        let result = try postgreSQL.execute("Insert INTO instagram_post(post_description, user_owner) VALUES('\(name)', '\(userOwnwer)')")
        return Response(status: .ok)
    } catch {
        throw Abort.serverError
    }
}


drop.get("getPrices", String.self) { request, gasType in
     do {
            let connection = try postgreSQL.makeConnection()
            let result = try postgreSQL.execute("Select * From gas_station where type = 'GNC'")

        var newArray = [JSON]()

        for (i, resultRow) in result.enumerated() {
            let newRow = try JSON(node: resultRow)
            newArray.append(newRow)
        }


        return try JSON(node: try JSON( node: newArray))
     } catch {
            throw Abort.serverError
        }
}

drop.post("creteNewUser") { request in

    return Response(status: .ok)

}

drop.run()
