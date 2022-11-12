enum Status { INITIAL, LOADING, COMPLETED, ERROR }

/// This Response class holds the methods to create mesages that can be passed down by
/// the providers, data is only passed down when the request is successful, in other cases
/// it only contains a message.
class Response<T> {
  Status status;
  T? data;
  String? message;

  Response.initial(this.message) : status = Status.INITIAL, data = null;

  Response.loading(this.message) : status = Status.LOADING, data = null;

  Response.completed(this.data) : status = Status.COMPLETED;

  Response.error(this.message) : status = Status.ERROR;

  @override
  String toString() {
    return "Status : $status \n Message : $message \n Data : $data";
  }

  bool isComplete() {
    return status == Status.COMPLETED;
  }
}
