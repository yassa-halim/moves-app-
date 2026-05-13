import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:movies/l10n/app_localizations.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_assets.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import 'movie_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late PageController _carouselController;
  int _currentCarouselIndex = 0;
  int? _pressedCarouselIndex;
  bool _isInit = false;

  
  late AnimationController _floatingController;
  late AnimationController _marqueeController;

  @override
  void initState() {
    super.initState();
    context.read<MoviesBloc>().add(const FetchMoviesEvent(page: 1));

    
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    
    _marqueeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _carouselController = PageController(viewportFraction: 0.65);
      _isInit = true;
    }
  }

  @override
  void dispose() {
    _carouselController.dispose();
    _floatingController.dispose();
    _marqueeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: BlocBuilder<MoviesBloc, MoviesState>(
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const _HomePageSkeleton();
          } else if (state is MoviesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.destructiveRed),
              ),
            );
          } else if (state is MoviesLoaded) {
            final movies = state.movies;
            if (movies.isEmpty)
              return const Center(child: Text('No movies available'));

            
            final carouselMovies = movies.take(12).toList();
            
            final categoryMovies = movies.skip(12).toList();

            final currentBgMovie = carouselMovies[_currentCarouselIndex];

            return Stack(
              children: [
                
                Positioned.fill(
                  child: AnimatedBuilder(
                    animation: _carouselController,
                    builder: (context, _) {
                      double page = _currentCarouselIndex.toDouble();
                      if (_carouselController.hasClients &&
                          _carouselController.position.haveDimensions) {
                        page = _carouselController.page!;
                      }

                      int floorIndex = page.floor();
                      int ceilIndex = page.ceil();

                      Widget buildBgLayer(int index) {
                        if (index < 0 || index >= carouselMovies.length)
                          return const SizedBox.shrink();
                        final movie = carouselMovies[index];
                        final distance = page - index;
                        final opacity = (1.0 - distance.abs()).clamp(0.0, 1.0);
                        final parallaxOffset = -distance * 100.0;

                        return Positioned.fill(
                          child: Opacity(
                            opacity: opacity,
                            child: Transform.translate(
                              offset: Offset(parallaxOffset, 0),
                              child: RepaintBoundary(
                                child: CachedNetworkImage(
                                  imageUrl: movie.backgroundImage.isNotEmpty
                                      ? movie.backgroundImage
                                      : movie.largeCoverImage,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        );
                      }

                      return Stack(
                        fit: StackFit.expand,
                        children: [
                          buildBgLayer(floorIndex),
                          if (ceilIndex != floorIndex) buildBgLayer(ceilIndex),
                          
                          Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  AppTheme.backgroundDark.withOpacity(0.5),
                                  AppTheme.backgroundDark.withOpacity(0.8),
                                  AppTheme.backgroundDark,
                                ],
                                stops: const [0.0, 0.4, 1.0],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                
                Positioned(
                  top: MediaQuery.of(context).padding.top + 5, 
                  left: 0,
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: const Offset(-1.0, 0.0),
                    ).animate(_marqueeController),
                    child: Text(
                      currentBgMovie.title.toUpperCase(),
                      maxLines: 1,
                      softWrap: false, 
                      overflow: TextOverflow.visible,
                      style: TextStyle(
                        fontSize: 220,
                        fontWeight: FontWeight.w900,
                        color: Colors.white.withOpacity(0.08),
                        letterSpacing: 10,
                      ),
                    ),
                  ),
                ),

                
                SafeArea(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      bottom: 120,
                    ), 
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 16),

                        
                        Center(
                          child: Image.asset(
                            AppAssets.availableNow,
                            height: 70,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        
                        SizedBox(
                          height: 420,
                          child: PageView.builder(
                            controller: _carouselController,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() {
                                _currentCarouselIndex = index;
                              });
                            },
                            itemCount: carouselMovies.length,
                            itemBuilder: (context, index) {
                              final movie = carouselMovies[index];
                              return AnimatedBuilder(
                                animation: Listenable.merge([
                                  _carouselController,
                                  _floatingController,
                                ]),
                                builder: (context, child) {
                                  double value = 0.0;
                                  if (_carouselController.hasClients &&
                                      _carouselController
                                          .position
                                          .haveDimensions) {
                                    value = _carouselController.page! - index;
                                  } else {
                                    value = (_currentCarouselIndex - index)
                                        .toDouble();
                                  }

                                  
                                  double scale = (1 - (value.abs() * 0.2))
                                      .clamp(0.8, 1.0);
                                  
                                  double opacity = (1 - (value.abs() * 0.5))
                                      .clamp(0.5, 1.0);

                                  
                                  final isCenter =
                                      _currentCarouselIndex == index;
                                  final floatOffset = isCenter
                                      ? (Curves.easeInOutSine.transform(
                                                  _floatingController.value,
                                                ) *
                                                15 -
                                            7.5)
                                      : 0.0;

                                  return Center(
                                    child: Transform.translate(
                                      offset: Offset(0, floatOffset),
                                      child: Opacity(
                                        opacity: opacity,
                                        child: Transform.scale(
                                          scale: Curves.easeOutBack.transform(
                                            scale,
                                          ),
                                          child: child,
                                        ),
                                      ),
                                    ),
                                  );
                                },
                                child: CinematicMovieCard(
                                  movie: movie,
                                  isHero: true,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        
                        Center(
                          child: Image.asset(
                            AppAssets.watchNow,
                            height: 140,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 48),

                        
                        _buildCategoryRow(
                          l10n.action,
                          categoryMovies,
                          l10n.seeMore,
                          context,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCategoryRow(
    String title,
    List<Movie> movies,
    String seeMoreText,
    BuildContext context,
  ) {
    if (movies.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              Row(
                children: [
                  Text(
                    seeMoreText.replaceAll(' ->', ''),
                    style: const TextStyle(
                      color: AppTheme.primaryYellow,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: AppTheme.primaryYellow,
                    size: 16,
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 230,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: CinematicMovieCard(movie: movies[index], isHero: false),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CinematicMovieCard extends StatefulWidget {
  final Movie movie;
  final bool isHero;
  final bool? isPressedExternal;

  const CinematicMovieCard({
    super.key,
    required this.movie,
    this.isHero = false,
    this.isPressedExternal,
  });

  @override
  State<CinematicMovieCard> createState() => _CinematicMovieCardState();
}

class _CinematicMovieCardState extends State<CinematicMovieCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final width = widget.isHero ? 234.0 : 140.0;
    final height = widget.isHero ? 351.0 : 210.0;
    final borderRadius = widget.isHero ? 32.0 : 28.0;
    final bool isEffectivelyPressed = widget.isPressedExternal ?? _isPressed;

    final content = AnimatedScale(
      scale: isEffectivelyPressed ? 0.95 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(_isPressed ? 0.8 : 0.5),
              blurRadius: widget.isHero ? 30 : 15,
              spreadRadius: widget.isHero ? 5 : 0,
              offset: Offset(0, widget.isHero ? 15 : 8),
            ),
            if (!widget.isHero && _isPressed)
              BoxShadow(
                color: AppTheme.primaryYellow.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 2,
              ),
          ],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            
            ClipRRect(
              borderRadius: BorderRadius.circular(borderRadius),
              child: CachedNetworkImage(
                imageUrl: widget.isHero
                    ? widget.movie.largeCoverImage
                    : widget.movie.mediumCoverImage,
                fit: BoxFit.cover,
                memCacheWidth: widget.isHero ? 480 : 280,
                placeholder: (context, url) =>
                    Container(color: Colors.white.withOpacity(0.05)),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[900],
                  child: const Icon(Icons.broken_image, color: Colors.white38),
                ),
              ),
            ),

            
            Positioned(
              top: widget.isHero ? 16 : 12,
              left: widget.isHero ? 16 : 12,
              child: RepaintBoundary(
                child: GlassmorphismBadge(rating: widget.movie.rating),
              ),
            ),
          ],
        ),
      ),
    );

    if (widget.isPressedExternal != null) {
      return content;
    }

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MovieDetailsPage(movieId: widget.movie.id),
          ),
        );
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: content,
    );
  }
}

class GlassmorphismBadge extends StatelessWidget {
  final double rating;
  const GlassmorphismBadge({super.key, required this.rating});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$rating',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.star_rounded,
                color: AppTheme.primaryYellow,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _HomePageSkeleton extends StatefulWidget {
  const _HomePageSkeleton();

  @override
  State<_HomePageSkeleton> createState() => _HomePageSkeletonState();
}

class _HomePageSkeletonState extends State<_HomePageSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                Colors.white.withOpacity(0.05),
                Colors.white.withOpacity(0.15),
                Colors.white.withOpacity(0.05),
              ],
              stops: const [0.1, 0.5, 0.9],
              begin: const Alignment(-1.0, -0.3),
              end: const Alignment(1.0, 0.3),
              transform: SlideGradientTransform(_shimmerController.value),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Container(
                width: 200,
                height: 60,
                color: Colors.white,
              ), 
              const SizedBox(height: 30),
              Container(
                width: 240,
                height: 360,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                ),
              ), 
              const SizedBox(height: 30),
              Container(
                width: 250,
                height: 80,
                color: Colors.white,
              ), 
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(width: 100, height: 24, color: Colors.white),
                    Container(width: 80, height: 20, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: 3,
                  itemBuilder: (context, index) => Container(
                    width: 140,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SlideGradientTransform extends GradientTransform {
  final double percent;
  const SlideGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0.0, 0.0);
  }
}
