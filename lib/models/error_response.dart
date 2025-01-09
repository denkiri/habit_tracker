class ErrorResponse {
  final String status;
  final String message;

  ErrorResponse({required this.status, required this.message});

  // Factory constructor to create an ErrorResponse from a JSON map
  factory ErrorResponse.fromJson(Map<String, dynamic> json) {
    return ErrorResponse(
      status: json['status'] as String,
      message: json['message'] as String,
    );
  }
}
