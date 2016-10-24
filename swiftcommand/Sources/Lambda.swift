
/**
  Lambda is the main entry point for SwiftOnLambda

  Example:
  ```
    let myHandler = MyHandler()
    let lambda = Lambda(handler: myHandler) 

    var (resp, err) = lambda.call("{context}", "{"Request":{ "a": "b" }}")
  ```

*/
class Lambda {
  let handler:Handler
  
  /**
    init intializes a new Lambda

    @param handler class which implements the Handler protocol
  */
  init(handler: Handler) {
    self.handler = handler 
  }
  
  /**
    call is executed when a new request is received

    @param context JSON string representing AWS context object
    @param request request body passed to the lambda, may not be JSON

    @return tuple containing a string representing a response to be sent back to the client and an error
  */
  func call(context:String, request:String) (response:String?, error:Error?) {

  }  
}
