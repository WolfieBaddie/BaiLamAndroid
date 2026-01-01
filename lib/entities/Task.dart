class Task {
  int? id;
  String? title;
  String? status;
  String? description;
  String? createdAt;
  String? updatedAt;
  String? publishedAt;
  String? locale;
  String? code;
  int? reward;
  int? repeat;
  String? type;

  Task({
    this.id,
    this.title,
    this.status,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.locale,
    this.code,
    this.reward,
    this.repeat,
    this.type,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['attributes']['title'],
      status: json['attributes']['status'],
      description: json['attributes']['description'],
      createdAt: json['attributes']['createdAt'],
      updatedAt: json['attributes']['updatedAt'],
      publishedAt: json['attributes']['publishedAt'],
      locale: json['attributes']['locale'],
      code: json['attributes']['code'],
      reward: json['attributes']['reward'],
      repeat: json['attributes']['repeat'],
      type: json['attributes']['type'],
    );
  }
}
