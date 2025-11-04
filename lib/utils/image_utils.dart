import 'dart:typed_data';
import 'dart:convert';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

class ImageUtils {
  static const int maxWidth = 800;
  static const int maxHeight = 800;
  static const int quality = 85;

  /// Otimiza uma imagem selecionada ou capturada
  static Future<Uint8List?> optimizeImage(XFile? imageFile) async {
    if (imageFile == null) return null;

    try {
      // Ler a imagem
      final imageBytes = await imageFile.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      
      if (originalImage == null) return null;

      // Redimensionar se necessário
      img.Image resizedImage = originalImage;
      if (originalImage.width > maxWidth || originalImage.height > maxHeight) {
        resizedImage = img.copyResize(
          originalImage,
          width: originalImage.width > originalImage.height ? maxWidth : null,
          height: originalImage.height > originalImage.width ? maxHeight : null,
          maintainAspect: true,
        );
      }

      // Converter para JPEG com qualidade otimizada
      final optimizedBytes = img.encodeJpg(resizedImage, quality: quality);
      
      return Uint8List.fromList(optimizedBytes);
    } catch (e) {
      print('Erro ao otimizar imagem: $e');
      return null;
    }
  }

  /// Converte Uint8List para base64 (para envio à API)
  static String uint8ListToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }

  /// Converte base64 para Uint8List (para exibição)
  static Uint8List? base64ToUint8List(String base64String) {
    try {
      return Uint8List.fromList(base64Decode(base64String));
    } catch (e) {
      print('Erro ao decodificar base64: $e');
      return null;
    }
  }
}

