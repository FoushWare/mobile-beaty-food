import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../core/services/performance_service.dart';

class OptimizedImage extends StatefulWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final bool enableFadeIn;
  final Duration fadeInDuration;
  final bool enableLazyLoading;
  final VoidCallback? onTap;
  final bool showLoadingIndicator;

  const OptimizedImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.enableFadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.enableLazyLoading = true,
    this.onTap,
    this.showLoadingIndicator = true,
  });

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  bool _isLoaded = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: widget.fadeInDuration,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    // Preload image if lazy loading is disabled
    if (!widget.enableLazyLoading) {
      _preloadImage();
    }
  }

  Future<void> _preloadImage() async {
    try {
      await performanceService.getCachedImage(widget.imageUrl);
    } catch (e) {
      // Handle preload error silently
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: widget.borderRadius != null
            ? BoxDecoration(
                borderRadius: widget.borderRadius,
              )
            : null,
        clipBehavior: widget.borderRadius != null ? Clip.antiAlias : Clip.none,
        child: _buildImageWidget(),
      ),
    );
  }

  Widget _buildImageWidget() {
    if (widget.imageUrl.isEmpty) {
      return _buildErrorWidget();
    }

    return CachedNetworkImage(
      imageUrl: widget.imageUrl,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      fadeInDuration:
          widget.enableFadeIn ? widget.fadeInDuration : Duration.zero,
      fadeOutDuration:
          widget.enableFadeIn ? widget.fadeInDuration : Duration.zero,
      placeholder: (context, url) => _buildPlaceholder(),
      errorWidget: (context, url, error) => _buildErrorWidget(),
      // imageRenderMethodForWeb: ImageRenderMethodForWeb.HtmlImage, // Removed for compatibility
      memCacheWidth: _calculateMemCacheWidth(),
      memCacheHeight: _calculateMemCacheHeight(),
      maxWidthDiskCache: _calculateMaxWidthDiskCache(),
      maxHeightDiskCache: _calculateMaxHeightDiskCache(),
      progressIndicatorBuilder: widget.showLoadingIndicator
          ? (context, url, progress) => _buildProgressIndicator(progress)
          : null,
      httpHeaders: _getHttpHeaders(),
      cacheKey: _generateCacheKey(),
      useOldImageOnUrlChange: true,
      filterQuality: FilterQuality.medium,
      imageBuilder: (context, imageProvider) {
        _isLoaded = true;
        if (widget.enableFadeIn) {
          _fadeController.forward();
        }
        return widget.borderRadius != null
            ? ClipRRect(
                borderRadius: widget.borderRadius!,
                child: Image(
                  image: imageProvider,
                  fit: widget.fit,
                ),
              )
            : Image(
                image: imageProvider,
                fit: widget.fit,
              );
      },
    );
  }

  Widget _buildPlaceholder() {
    if (widget.placeholder != null) {
      return widget.placeholder!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Center(
        child: Icon(
          Icons.image,
          size: 40,
          color: Colors.grey[400],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    _hasError = true;
    if (widget.errorWidget != null) {
      return widget.errorWidget!;
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 8),
            Text(
              'Failed to load image',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(DownloadProgress? progress) {
    if (progress == null) {
      return _buildPlaceholder();
    }

    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey[200],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: progress.progress,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
            const SizedBox(height: 8),
            Text(
              '${(progress.progress * 100).toInt()}%',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int? _calculateMemCacheWidth() {
    if (widget.width == null) return null;
    return (widget.width! * MediaQuery.of(context).devicePixelRatio).round();
  }

  int? _calculateMemCacheHeight() {
    if (widget.height == null) return null;
    return (widget.height! * MediaQuery.of(context).devicePixelRatio).round();
  }

  int? _calculateMaxWidthDiskCache() {
    if (widget.width == null) return null;
    return (widget.width! * 2).round(); // 2x for high DPI
  }

  int? _calculateMaxHeightDiskCache() {
    if (widget.height == null) return null;
    return (widget.height! * 2).round(); // 2x for high DPI
  }

  Map<String, String> _getHttpHeaders() {
    // Add any required headers for image requests
    return {
      'User-Agent': 'BeatyFood/1.0',
      'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
    };
  }

  String _generateCacheKey() {
    // Generate a unique cache key based on URL and dimensions
    final dimensions = '${widget.width}x${widget.height}';
    return '${widget.imageUrl}_$dimensions';
  }
}

// Optimized image list widget for better performance
class OptimizedImageList extends StatelessWidget {
  final List<String> imageUrls;
  final double itemWidth;
  final double itemHeight;
  final int crossAxisCount;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final BoxFit fit;
  final VoidCallback? onImageTap;
  final bool enableLazyLoading;

  const OptimizedImageList({
    super.key,
    required this.imageUrls,
    required this.itemWidth,
    required this.itemHeight,
    this.crossAxisCount = 2,
    this.crossAxisSpacing = 8.0,
    this.mainAxisSpacing = 8.0,
    this.fit = BoxFit.cover,
    this.onImageTap,
    this.enableLazyLoading = true,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: itemWidth / itemHeight,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return OptimizedImage(
          imageUrl: imageUrls[index],
          width: itemWidth,
          height: itemHeight,
          fit: fit,
          enableLazyLoading: enableLazyLoading,
          onTap: onImageTap,
        );
      },
    );
  }
}

// Optimized image carousel for better performance
class OptimizedImageCarousel extends StatefulWidget {
  final List<String> imageUrls;
  final double height;
  final double viewportFraction;
  final bool autoPlay;
  final Duration autoPlayInterval;
  final bool enableInfiniteScroll;
  final VoidCallback? onImageTap;

  const OptimizedImageCarousel({
    super.key,
    required this.imageUrls,
    required this.height,
    this.viewportFraction = 0.8,
    this.autoPlay = false,
    this.autoPlayInterval = const Duration(seconds: 3),
    this.enableInfiniteScroll = true,
    this.onImageTap,
  });

  @override
  State<OptimizedImageCarousel> createState() => _OptimizedImageCarouselState();
}

class _OptimizedImageCarouselState extends State<OptimizedImageCarousel> {
  late PageController _pageController;
  int _currentIndex = 0;
  Timer? _autoPlayTimer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: widget.viewportFraction,
    );

    if (widget.autoPlay) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _autoPlayTimer = Timer.periodic(widget.autoPlayInterval, (timer) {
      if (mounted && widget.imageUrls.isNotEmpty) {
        final nextIndex = (_currentIndex + 1) % widget.imageUrls.length;
        _pageController.animateToPage(
          nextIndex,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _autoPlayTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return SizedBox(
        height: widget.height,
        child: Center(
          child: Text(
            'No images available',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: widget.height,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: widget.imageUrls.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: OptimizedImage(
                  imageUrl: widget.imageUrls[index],
                  height: widget.height,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(8.0),
                  onTap: widget.onImageTap,
                ),
              );
            },
          ),
        ),
        if (widget.imageUrls.length > 1) ...[
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              widget.imageUrls.length,
              (index) => Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color:
                      _currentIndex == index ? Colors.blue : Colors.grey[300],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
