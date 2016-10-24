struct Context {
  /**
    getRemainingTimeInMillis returns the approximate remaining execution time (before timeout occurs) of the Lambda function 
    that is currently executing. 
    The timeout is one of the Lambda function configuration. When the timeout reaches, AWS Lambda terminates your Lambda function.

    You can use this method to check the remaining time during your function execution and take appropriate corrective action 
    at run time.
  */
  var getRemainingTimeInMillis:Int {
    get {

    }
  }
  
  /**
    Name of the Lambda function that is executing.
  */
  var functionName:String

  /**
    The Lambda function version that is executing. If an alias is used to invoke the function, then function_version will be the version the alias points to.
  */
  var functionVersion:String

  /**
    The ARN used to invoke this function. It can be a function ARN or an alias ARN. An unqualified ARN executes the $LATEST version and aliases execute the function version it is pointing to.
  */
  var invokedFunctionArn:String

  /**
    Memory limit, in MB, you configured for the Lambda function. You set the memory limit at the time you create a Lambda function and you can change it later.
  */
  var memoryLimitInMB:Int

  /**
    AWS request ID associated with the request. This is the ID returned to the client that called the invoke method.

  Note
  If AWS Lambda retries the invocation (for example, in a situation where the Lambda function that is processing Amazon Kinesis records throws an exception), the request ID remains the same.
  */
  var awsRequestId:String

  /**
    The name of the CloudWatch log group where you can find logs written by your Lambda function.
  */
  var logGroupName:String

  /**
    The name of the CloudWatch log group where you can find logs written by your Lambda function. The log stream may or may not change for each invocation of the Lambda function.

    The value is null if your Lambda function is unable to create a log stream, which can happen if the execution role that grants necessary permissions to the Lambda function does not include permissions for the CloudWatch actions.
  */
  var logStreamName:String
}
