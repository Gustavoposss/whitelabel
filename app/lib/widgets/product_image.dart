import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const ProductImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null || imageUrl!.isEmpty || !_isValidUrl(imageUrl!)) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(
              Icons.image_not_supported,
              size: (height ?? 100) * 0.3,
              color: Colors.grey[400],
            ),
          );
    }

    try {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: width,
        height: height,
        fit: fit,
        httpHeaders: {
          'Accept': 'image/*',
        },
        placeholder: (context, url) => placeholder ??
            Container(
              width: width,
              height: height,
              color: Colors.grey[200],
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        errorWidget: (context, url, error) {
          return errorWidget ??
              Container(
                width: width,
                height: height,
                color: Colors.grey[200],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image,
                      size: (height ?? 100) * 0.3,
                      color: Colors.grey[400],
                    ),
                    if (height != null && height! > 100)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Imagem não disponível',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              );
        },
      );
    } catch (e) {
      return errorWidget ??
          Container(
            width: width,
            height: height,
            color: Colors.grey[200],
            child: Icon(
              Icons.broken_image,
              size: (height ?? 100) * 0.3,
              color: Colors.grey[400],
            ),
          );
    }
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}
