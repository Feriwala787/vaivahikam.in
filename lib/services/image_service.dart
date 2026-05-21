import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class ImageService {
  final _storage = Supabase.instance.client.storage.from('profile-photos');

  Future<Uint8List?> compressImage(XFile file) async {
    final bytes = await file.readAsBytes();
    return FlutterImageCompress.compressWithList(
      bytes,
      minWidth: 800,
      minHeight: 800,
      quality: 70,
      format: CompressFormat.webp,
    );
  }

  Future<String> uploadPhoto(String scoutId, XFile file) async {
    final compressed = await compressImage(file);
    if (compressed == null) throw Exception('Compression failed');

    final fileName = '${const Uuid().v4()}.webp';
    final path = '$scoutId/$fileName';

    await _storage.uploadBinary(path, compressed, fileOptions: const FileOptions(contentType: 'image/webp'));
    return _storage.getPublicUrl(path);
  }

  Future<List<String>> uploadMultiple(String scoutId, List<XFile> files) async {
    final urls = <String>[];
    for (final file in files) {
      final url = await uploadPhoto(scoutId, file);
      urls.add(url);
    }
    return urls;
  }
}
