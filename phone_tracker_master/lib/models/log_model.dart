class LogModel {
  final double latitude, longitude;
  final String timestamp;

  LogModel({
    this.latitude,
    this.longitude,
    this.timestamp,
  });

  factory LogModel.fromJson(Map<String, dynamic> json){
    return LogModel(
      latitude: json['latitude'],
      longitude: json['longitude'],
      timestamp: json['timestamp'],
    );
  }
}
