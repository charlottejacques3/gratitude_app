import 'package:hive/hive.dart';

part 'upload_task.g.dart';

@HiveType(typeId: 0)
class UploadTaskData extends HiveObject {
  @HiveField(0)
  String localPath;

  @HiveField(1)
  String fileName;

  UploadTaskData({required this.localPath, required this.fileName});
}
