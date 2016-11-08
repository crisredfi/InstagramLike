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

        print("\(results)")
        return "hello world"
    } catch {
        return "NO DB connection"
    }
}

drop.post("addPost") { request in

    guard let name = request.data["name"]?.string else {
        throw Abort.badRequest
    }
    do {
        let connection = try postgreSQL.makeConnection()
        let result = try postgreSQL.execute("Insert INTO instagram_post(name) VALUES('\(name)')")
        return Response(status: .ok)
    } catch {
        throw Abort.serverError
    }

}


drop.run()
