import Foundation

//
// MARK: Greeter skill
// 

let APP_ID = "com.alexisgallagher.swiftgreeter"

// commented out code is work-in-progress:

/*
 
typealias AlexaIntentHandler = (intent:AlexaIntent,
  session:AlexaSession,
  response:AlexaResponse) -> Void

let SPEECH_OUTPUT = "Hello World!"


func helloResponseFunction(intent:AlexaIntent,session:AlexaSession,response:AlexaResponse) {
    response.tell(SPEECH_OUTPUT)
}

class GreeterService : AlexaSkill {

    // TODO: use APP_ID on initialization
    
    func onLaunch(intent:AlexaIntent,session:AlexaSession,response:AlexaResponse) {
        helloResponseFunction(intent:intent,session:session,response:response)
    }

    /// maps intent names to intent handlers
    var intentHandlers:[String:AlexaIntentHandler] {
        return ["HelloWorldIntent":helloResponseFunction]
    }
}

//
// MARK: AlexaSkills API
// 

protocol AlexaSkill {
    func onLaunch(intent:AlexaIntent,session:AlexaSession,response:AlexaResponse)
    var intentHandlers:[String:AlexaIntentHandler]
}


typealias AmazonEvent = [String:Any]
typealias AmazonContext = [String:Any]

func serviceHandler(event:AmazonEvent,context:AmazonContext) {
    let greeterService = GreeterService()
    greeterService.execute(event:event,context:context)
}

 */

/**
 Parses the top-level JSON value passed in as part of the
 Alexa JSON interface

*/
func serviceJson(jsonInput:JSONDictionary) -> JSONDictionary
{
  // parse the service request
  guard let serviceRequest = AlexaRequestEnvelope(JSON:jsonInput) else
  {
    print("ERROR: unable to parse alexa request message")
    let response:[String:Any] = ["error":"ERROR: unable to parse alexa request message"]
    return response
  }

  // parse the embedded Alexa request
  let alexaRequestUnparsed = serviceRequest.request
  guard let _ = IntentRequest(JSON: alexaRequestUnparsed) else {
    let msg:String = "ERROR: did not detect a launch request"
    print(msg)
    let response = ["error":msg]
    return response
  }

  // LATER: here we would process details in a launch request or intent request object

  // generate output speech
  let outputSpeech = AlexaOutputSpeech(text: "Hello from Swift")
  // build an AlexaResponse
  let alexaResponse = AlexaResponse(outputSpeech: outputSpeech, card: nil, reprompt: nil, directives: nil, shouldEndSession: nil)
  
  // build a service response
  let serviceResponse = AlexaResponseEnvelope(version: "1.0", sessionAttributes: nil, response: alexaResponse)
  
  return serviceResponse.asJSON
}

public class Greeter {

    public init() { }

    /**
     String->String wrapper for the JSON->JSON service above.

     */
    public func service(string s:String) -> String {
        guard let data = s.data(using: String.Encoding.utf8) else { return "error serialized string to data" }
        guard let jsonInput = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONDictionary else {
            return "error parsing JSON from string"
        }
        let outputJSON = serviceJson(jsonInput:jsonInput)
        guard let outputData = try? JSONSerialization.data(withJSONObject: outputJSON, options: JSONSerialization.WritingOptions.prettyPrinted) else {
            return "error: unable to convert json to data"
        }
        let outputString = String(data: outputData, encoding: String.Encoding.utf8) ?? "error"
        return outputString
    }
}
/*
Questions:

- does AMZ check timestamp security before passing to lambda handlers? or is that the rsponsibility of my lambda func when it processes the request? Is this checked for certification?

- AMZ published any schema of all these types? Protocol buffers schema?

- AMZ published nginx config for auth anywhere?


*/

