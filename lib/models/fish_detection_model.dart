class FishDetection {
  final String className;
  final double confidence;
  final Map<String, int> bbox;

  FishDetection({
    required this.className,
    required this.confidence,
    required this.bbox,
  });

  factory FishDetection.fromJson(Map<String, dynamic> json) {
    return FishDetection(
      className: json['class'],
      confidence: json['confidence'].toDouble(),
      bbox: {
        'x1': json['bbox']['x1'] as int,
        'y1': json['bbox']['y1'] as int,
        'x2': json['bbox']['x2'] as int,
        'y2': json['bbox']['y2'] as int,
      },
    );
  }
}

class FishDetectionResponse {
  final List<FishDetection> detections;
  final String annotatedImageBase64;
  final int totalDetections;

  FishDetectionResponse({
    required this.detections,
    required this.annotatedImageBase64,
    required this.totalDetections,
  });

  factory FishDetectionResponse.fromJson(Map<String, dynamic> json) {
    return FishDetectionResponse(
      detections:
          (json['detections'] as List)
              .map((detection) => FishDetection.fromJson(detection))
              .toList(),
      annotatedImageBase64: json['annotated_image_base64'],
      totalDetections: json['total_detections'],
    );
  }
}
