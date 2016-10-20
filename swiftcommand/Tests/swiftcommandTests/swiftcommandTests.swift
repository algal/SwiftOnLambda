import Foundation

import XCTest
@testable import swiftcommand

class greeterTests: XCTestCase
{
    func testExample()
    {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let g = Greeter()
      
          /*
          {
            "session": {
              "sessionId": "SessionId.0acdeb7e-1d2e-41a9-91a0-abd690624c94",
              "application": {
                "applicationId": "amzn1.ask.skill.221dba25-e4b4-40bc-952c-5b25ec81bd4d"
              },
              "attributes": {},
              "user": {
                "userId": "amzn1.ask.account.AECQY5WZK7XRIQQEEBOAWBPVDR7663OASF5BYYCXLLMZHSNDYHPJJZWVFVS7U5CGSCPOFANKW73MGG2ORDVCN37IUMYKBH4I4US4ZBGL7KK3PNCQEZYAAJHWSVW3E44ZQT4OLODNBVJ24QMS3G5GANPUDFVHCAM4WLOAS5UXZQIVZ4FZE5Q43PHMVR3QWWNTQTHOC6E76WZCSTY"
              },
              "new": true
            },
            "request": {
              "type": "IntentRequest",
              "requestId": "EdwRequestId.fad8cbfd-a9f2-4645-97dc-58986a127813",
              "locale": "en-US",
              "timestamp": "2016-10-19T00:40:06Z",
              "intent": {
                "name": "HelloWorldIntent",
                "slots": {}
              }
            },
            "version": "1.0"
      }
       */

      let intentRequest:String = "{\n  \"session\": {\n    \"sessionId\": \"SessionId.0acdeb7e-1d2e-41a9-91a0-abd690624c94\",\n    \"application\": {\n      \"applicationId\": \"amzn1.ask.skill.221dba25-e4b4-40bc-952c-5b25ec81bd4d\"\n    },\n    \"attributes\": {},\n    \"user\": {\n      \"userId\": \"amzn1.ask.account.AECQY5WZK7XRIQQEEBOAWBPVDR7663OASF5BYYCXLLMZHSNDYHPJJZWVFVS7U5CGSCPOFANKW73MGG2ORDVCN37IUMYKBH4I4US4ZBGL7KK3PNCQEZYAAJHWSVW3E44ZQT4OLODNBVJ24QMS3G5GANPUDFVHCAM4WLOAS5UXZQIVZ4FZE5Q43PHMVR3QWWNTQTHOC6E76WZCSTY\"\n    },\n    \"new\": true\n  },\n  \"request\": {\n    \"type\": \"IntentRequest\",\n    \"requestId\": \"EdwRequestId.fad8cbfd-a9f2-4645-97dc-58986a127813\",\n    \"locale\": \"en-US\",\n    \"timestamp\": \"2016-10-19T00:40:06Z\",\n    \"intent\": {\n      \"name\": \"HelloWorldIntent\",\n      \"slots\": {}\n    }\n  },\n  \"version\": \"1.0\"\n}\n"
      

      // check result is at least JSON
      let resultString = g.service(string: intentRequest)
      let resultJSON = try? JSONSerialization.jsonObject(with: resultString.data(using: String.Encoding.utf8)!,
                                                         options: [])
      XCTAssert(resultJSON != nil)

    }


    static var allTests : [(String, (greeterTests) -> () throws -> Void)] {
        return [
            ("testExample", testExample),
        ]
    }
}
