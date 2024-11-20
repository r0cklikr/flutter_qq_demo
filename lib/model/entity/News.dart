import 'dart:typed_data';

class News{
   String? id;
   String ctime;
   String title;
   String description;
   String source;
   String picUrl;
   String url;
   Uint8List? picData; // 保存图片二进制数据
  News({
     this.id,
    required this.ctime,
    required this.title,
    required this.description,
    required this.source,
    required this.picUrl,
    required this.url,
    this.picData,
  });

  factory News.fromJson(Map<String, dynamic> json) {
    return News(
      id: json['id'],
      ctime: json['ctime'],
      title: json['title'],
      description: json['description'],
      source: json['source'],
      picUrl: json['picUrl'],
      url: json['url'],
    );
  }
   // 从数据库中读取新闻记录
   factory News.fromMap(Map<String, dynamic> map) {
     return News(
       id: map['id'],
       title: map['title'],
       description: map['description'],
       url: map['url'],
       picUrl: map['picUrl'],
       source: map['source'],
       ctime: map['ctime'],
       picData: map['picData'], // 获取图片二进制数据
     );
   }
   Map<String, dynamic> toMap() {
     return {
       'id': id,
       'title': title,
       'description': description,
       'url': url,
       'picUrl': picUrl,
       'source': source,
       'ctime': ctime,
       'picData': picData
     };
   }
   @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is News &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          ctime == other.ctime &&
          title == other.title &&
          description == other.description &&
          source == other.source &&
          picUrl == other.picUrl &&
          url == other.url;

  @override
  int get hashCode =>
      id.hashCode ^
      ctime.hashCode ^
      title.hashCode ^
      description.hashCode ^
      source.hashCode ^
      picUrl.hashCode ^
      url.hashCode;
}