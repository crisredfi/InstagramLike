import Vapor
import PostgreSQL
import HTTP

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
  //  static let allValues = [GNC, GPR, G98, GOA, NGO, GOB, GOC, BIO, G95, BIE, GLP]
    static let allValues = [GNC]

}

let drop = Droplet()
let postgreSQL =  PostgreSQL.Database(
    host:"ec2-54-75-230-123.eu-west-1.compute.amazonaws.com",
    port: "5432",
    dbname: "d39vv65oksulss",
    user: "odvzwudlovwalc",
    password: "jYubKAYyMzhxU4fg_WgFLvp3UE"
)


drop.get("version") { request in

    do {

        //let version = try postgreSQL.execute("SELECT version()")
        //return  version
        for gas in gasStations.allValues {
            let spotifyResponse = try drop.client.get("http://gas.saliou.name/json/latest/GNC.json")
           // let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
           //     guard let jsonWithObjectRoot = try? JSONSerialization.jsonObject(with: data!, options: []) else {
           //         return
           //     }
                do {
                    let connection = try postgreSQL.makeConnection()
                    let _ = try postgreSQL.execute("DELETE FROM gas_station type='\(gas.rawValue)'")
                } catch {

                }
            let json = try JSON(bytes: spotifyResponse.body.bytes!)
            print(json)
                for dict in (json.node.array! as [Polymorphic]) {

                    let lat = dict.object?["lng"]?.float
                    let long = dict.object?["lat"]?.float // lat long are wrong in the py server
                    let name = dict.object?["name"]?.string
                    let price = dict.object?["price"]?.float

                    do {
                     //   let connection = try postgreSQL.makeConnection()

                        let _ = try postgreSQL.execute("Insert INTO gas_station(name, price, lattitude, longitude, type) VALUES('\(name!)', '\(price!)', '\(lat!)', '\(long!)', '\(gas.rawValue)')")
                    } catch {
                        print("error executing")

                    }

                }
            }
            
       //     task.resume()
    //
        return "hello world"

    } catch {
        return "NO DB connection"
    }

}

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
