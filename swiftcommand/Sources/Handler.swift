/**
  The handler protocol should be implemented by a class which will receive messages from the Lambda
  command.
*/
protocol Handler {
  /**
    handle is called by the Lambda upon receiving a new request.

    @param context structure corresponding to the parent Lambda's context.
    @param request dictionary containing serialized JSON that was sent to the lambda.

    @return tuple containing a dictionary which will be serialized to JSON and an error object.
  */
  func handle(context: Context, request: NSDictionary?) -> (NSDictionary?, Error?)
}
