import Vapor
import PostgreSQL
import HTTP

let drop = Droplet()
let postgreSQL =  PostgreSQL.Database(
    dbname: "Instagram",
    user: "crisredfi",
    password: ""
)
//drop.get { req in
//    return try drop.view.make("welcome", [
//    	"message": drop.localization[req.lang, "welcome", "title"]
//    ])
//}
//
//drop.resource("posts", PostController())
drop.get("version") { request in
    do {
        //let version = try postgreSQL.execute("SELECT version()")
        //return  version
        let connection = try postgreSQL.makeConnection()
        let results = try postgreSQL.execute("SELECT * FROM instagram_post")
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


drop.get("getPosts", Int.self) { request, userID in
     do {
            let connection = try postgreSQL.makeConnection()
            let result = try postgreSQL.execute("Select * From instagram_post where user_owner = \(userID)")

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




drop.run()
