import 'app_exception.dart';
import 'failure.dart';

class ErrorHandler {
  static Failure handle(dynamic error) {
    if (error is AppException) {
      return Failure(error.message);
    }

    if (error.toString().contains("network")) {
      return Failure("No internet connection");
    }

    return Failure("Something went wrong");
  }
}
