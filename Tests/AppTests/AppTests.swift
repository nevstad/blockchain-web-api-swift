@testable import App
import Vapor
import BlockchainSwift
import XCTest

final class AppTests: XCTestCase {

    private static func configureAndBootApp() throws -> Application {
        var config = Config.default()
        var services = Services.default()
        var env = Environment.testing
        try App.configure(&config, &env, &services)
        let app = try Application(config: config, environment: env, services: services)
        try App.boot(app)
        return app
    }
    
    func testBlockchain() throws {
        // Configure App and boot it up
        let app = try AppTests.configureAndBootApp()
        let responder = try app.make(Responder.self)
        
        func response<T: Codable>(url: String, method: HTTPMethod) throws -> T {
            let request = HTTPRequest(method: method, url: URL(string: url)!)
            let response = try responder.respond(to: Request(http: request, using: app)).wait()
            let data = response.http.body.data
            return try JSONDecoder().decode(T.self, from: data!)
        }
        
        let blockchain: BlockchainResponse = try response(url: "/api/v1/blockchain", method: .GET)
        XCTAssertTrue(blockchain.blocks.count == 1, "Blockchain should have been initialized with a genesis block.")
        XCTAssertTrue(blockchain.mempool.isEmpty, "Mempool should be empty.")
        XCTAssertTrue(blockchain.utxos.count == 1, "UTXOs should have one spendable output generated by the block reward.")
        let wallet: BalanceResponse = try response(url: "/api/v1/wallet", method: .GET)
        XCTAssertTrue(blockchain.utxos[0].address == Data(hex: wallet.address)!, "The only avaialble spendable output should belong to the Wallet that mined the genesis block.")
    }
    
    static let allTests = [
        ("testBlockchain", testBlockchain)
    ]
}
