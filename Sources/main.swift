import Foundation
import Kitura
import HeliumLogger
import LoggerAPI

Log.logger = HeliumLogger()

/*// Handle HTTP GET requests to /
router.get("/hello") { request, response, next in
    response.send("Hello, OSCON!")
    next()
}
// Handle HTTP GET requests with a parameter /params?name=XXXX
router.get("/params") { request, response, next in
    let param = request.queryParameters["name"] ?? ""
    try response.send("Hello, \(param)!").end()
}*/

let controller = TodoContoller()

// let port = Int(ProcessInfo.processInfo.environment["PORT"] ?? "1") ?? 2

Kitura.addHTTPServer(onPort: 8080, with: controller.router)

Kitura.run()
