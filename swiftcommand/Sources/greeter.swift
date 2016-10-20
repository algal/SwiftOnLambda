import Foundation
//import SwiftyJSON

typealias ActiveJSONSerialization = Foundation.JSONSerialization
//typealias ActiveJSONSerialization = SwiftyJSON.LclJSONSerialization

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
func serviceJson(jsonInput:JSONDictionary) -> AlexaResponseEnvelope?
{
  // parse the service request
  guard let serviceRequest = AlexaRequestEnvelope(JSON:jsonInput) else
  {
    print("ERROR: unable to parse alexa request message")

    return nil
  }
  
  // parse the embedded Alexa request
  let alexaRequestUnparsed = serviceRequest.request
  
  if let _ = LaunchRequest(JSON: alexaRequestUnparsed) {
//    print("found launch request")
  }
  else if let _ = IntentRequest(JSON:alexaRequestUnparsed) {
//    print("found intentRequest")
  }
  else {
    print("did not find launch request or intent request")
    let msg:String = "ERROR: did not detect a launch request"
    print(msg)
    return nil
  }
  
  // LATER: here we would process details in a launch request or intent request object
  
  // generate output speech
  let outputSpeech = AlexaOutputSpeech(text: "Hello from Swift")
  // build an AlexaResponse
  let alexaResponse:AlexaResponse = AlexaResponse(outputSpeech: outputSpeech, card: nil, reprompt: nil, directives: nil, shouldEndSession: true)
  
  // build a service response
  let serviceResponse:AlexaResponseEnvelope = AlexaResponseEnvelope(version: "1.0", sessionAttributes: nil, response: alexaResponse)
  
  return serviceResponse
}

public class Greeter
{
  public init() { }
  
  /**
   String->String wrapper for the JSON->JSON service above.
   
   */
  public func service(string s:String) -> String {
    guard let data = s.data(using: String.Encoding.utf8) else { return "error serialized string to data" }
    guard let jsonInput = (try? JSONSerialization.jsonObject(with: data, options: [])) as? JSONDictionary else {
      return "error parsing JSON from string"
    }
    
    guard let response:AlexaResponseEnvelope =   serviceJson(jsonInput:jsonInput)
      else {
        let msg = "did not generate response object"
        print(msg)
        return msg
    }
    
//    print(" will try to encode outputJSON=\(response.asJSON)")
    let JSONString = response.asJSONString
//    print(" self-encoded to JSON=\(JSONString)")
    return JSONString
  }
}
/*
 Questions:
 
 - does AMZ check timestamp security before passing to lambda handlers? or is that the rsponsibility of my lambda func when it processes the request? Is this checked for certification?
 
 - AMZ published any schema of all these types? Protocol buffers schema?
 
 - AMZ published nginx config for auth anywhere?
 
 
 */

