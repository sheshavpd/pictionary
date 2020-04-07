//Can be used to call when the response came back from server,
//But the api failed to do what it was meant to.
class FailedRequestException implements Exception {
  final String message;

  /// The URL of the HTTP request or response that failed.
  final Uri uri;

  FailedRequestException(this.message, [this.uri]);

  String toString() => message;
}
