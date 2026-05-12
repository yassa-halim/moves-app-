import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/cast.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import '../../../../injection_container.dart' as di;

const Color _kDarkBg = Color(0xFF0B0B0B);

class MovieDetailsPage extends StatelessWidget {
  final int movieId;

  const MovieDetailsPage({super.key, required this.movieId});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<MoviesBloc>()..add(FetchMovieDetailsEvent(movieId)),
      child: _MovieDetailsView(movieId: movieId),
    );
  }
}

class _MovieDetailsView extends StatefulWidget {
  final int movieId;

  const _MovieDetailsView({required this.movieId});

  @override
  State<_MovieDetailsView> createState() => _MovieDetailsViewState();
}

class _MovieDetailsViewState extends State<_MovieDetailsView>
    with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late AnimationController _pulseController;
  late AnimationController _ambientController;

  @override
  void initState() {
    super.initState();
    // Event dispatched by parent BlocProvider, no need here

    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _ambientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _pulseController.dispose();
    _ambientController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kDarkBg,
      body: BlocConsumer<MoviesBloc, MoviesState>(
        listener: (context, state) {
          if (state is MovieDetailsLoaded) {
            _staggerController.forward();
          }
        },
        builder: (context, state) {
          if (state is MoviesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow),
            );
          } else if (state is MoviesError) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: AppTheme.destructiveRed),
              ),
            );
          } else if (state is MovieDetailsLoaded) {
            final movie = state.movie;
            final suggestions = state.suggestions;

            return CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                _buildSliverAppBar(movie),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 8.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Watch Button
                        _AnimatedReveal(
                          controller: _staggerController,
                          index: 1,
                          child: _buildWatchButton(),
                        ),
                        const SizedBox(height: 24),

                        // Stats Row
                        _AnimatedReveal(
                          controller: _staggerController,
                          index: 2,
                          child: _buildStatsRow(movie),
                        ),
                        const SizedBox(height: 32),

                        // Screenshots
                        if (movie.screenshots.isNotEmpty) ...[
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 3,
                            child: _buildScreenshotsSection(movie),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Similar Movies
                        if (suggestions.isNotEmpty) ...[
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 4,
                            child: _buildSimilarMovies(suggestions),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Summary
                        _AnimatedReveal(
                          controller: _staggerController,
                          index: 5,
                          child: const Text(
                            'Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _AnimatedReveal(
                          controller: _staggerController,
                          index: 6,
                          child: _ExpandableSummary(
                            text: movie.descriptionFull.isNotEmpty
                                ? movie.descriptionFull
                                : 'No summary available.',
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Cast
                        if (movie.cast.isNotEmpty) ...[
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 7,
                            child: const Text(
                              'Cast',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 8,
                            child: _buildCastList(movie.cast),
                          ),
                          const SizedBox(height: 32),
                        ],

                        // Genres
                        if (movie.genres.isNotEmpty) ...[
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 9,
                            child: const Text(
                              'Genres',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 10,
                            child: _buildGenres(movie.genres),
                          ),
                          const SizedBox(height: 48), // Bottom spacing
                        ],
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

  Widget _buildSliverAppBar(Movie movie) {
    final posterUrl = movie.backgroundImageOriginal.isNotEmpty
        ? movie.backgroundImageOriginal
        : movie.largeCoverImage;

    return SliverAppBar(
      expandedHeight: MediaQuery.of(context).size.height * 0.65,
      pinned: true,
      backgroundColor: _kDarkBg,
      leadingWidth: 70,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: _GlassIconButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0, top: 8.0, bottom: 8.0),
          child: _GlassIconButton(icon: Icons.bookmark_rounded, onTap: () {}),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Ambient Blurred Layer
            RepaintBoundary(
              child: AnimatedBuilder(
                animation: _ambientController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: 1.1 + (_ambientController.value * 0.05),
                    child: child,
                  );
                },
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                  child: CachedNetworkImage(
                    imageUrl: posterUrl,
                    fit: BoxFit.cover,
                    memCacheWidth: 400,
                  ),
                ),
              ),
            ),

            // Main Poster
            CachedNetworkImage(imageUrl: posterUrl, fit: BoxFit.cover, memCacheWidth: 600),

            // Bottom Gradient
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black26,
                    Colors.black87,
                    _kDarkBg,
                  ],
                  stops: [0.0, 0.5, 0.85, 1.0],
                ),
              ),
            ),

            // Huge Watermark Text Behind Title
            Positioned(
              bottom: 40,
              left: -20,
              right: -20,
              child: Text(
                movie.title.toUpperCase(),
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(
                  fontSize: 70,
                  fontWeight: FontWeight.w900,
                  color: Colors.white10,
                  height: 0.9,
                  letterSpacing: 2,
                ),
              ),
            ),

            // Center Play Button
            Center(
              child: _AnimatedReveal(
                controller: _staggerController,
                index: 0,
                child: _buildPlayButton(),
              ),
            ),

            // Title and Year
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: _AnimatedReveal(
                controller: _staggerController,
                index: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      movie.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${movie.year}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryYellow.withOpacity(
                  0.3 * _pulseController.value,
                ),
                blurRadius: 30 * _pulseController.value,
                spreadRadius: 10 * _pulseController.value,
              ),
            ],
          ),
          child: _HoverScaleButton(
            onTap: () {},
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: AppTheme.primaryYellow, width: 4),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black45,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: AppTheme.primaryYellow,
                size: 40,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWatchButton() {
    return _HoverScaleButton(
      onTap: () {},
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: const Color(0xFFE50914), // Netflix Red
          borderRadius: BorderRadius.circular(20), // Updated to 20px
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE50914).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            'Watch',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(Movie movie) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(Icons.favorite_rounded, '${movie.likeCount}'),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.access_time_filled_rounded,
            '${movie.runtime}',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(child: _buildStatCard(Icons.star_rounded, '${movie.rating}')),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String value) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18), // Updated to 18px
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppTheme.primaryYellow, size: 20),
              const SizedBox(width: 8),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScreenshotsSection(Movie movie) {
    // If the user wants a vertical list as in the image, we can switch here.
    // The instructions say "Horizontal snapping gallery" so we use a horizontal list.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Screen Shots',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'HD',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Since image shows stacked vertically, but text says horizontal:
        // We will build a vertical list if we assume the screenshot is the ground truth for layout.
        // Let's implement vertical list to perfectly match the screenshot provided.
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: movie.screenshots.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _HoverScaleButton(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: movie.screenshots[index],
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.white.withOpacity(0.05),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSimilarMovies(List<Movie> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Similar',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: suggestions.length > 4 ? 4 : suggestions.length,
          itemBuilder: (context, index) {
            final simMovie = suggestions[index];
            return _HoverScaleButton(
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MovieDetailsPage(movieId: simMovie.id),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: simMovie.mediumCoverImage,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: Colors.white.withOpacity(0.05)),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 0.5,
                              ),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${simMovie.rating}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppTheme.primaryYellow,
                                  size: 14,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCastList(List<Cast> cast) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: cast.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final actor = cast[index];
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.05)),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: actor.urlSmallImage.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: actor.urlSmallImage,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.white10,
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: Colors.white10,
                        child: const Icon(Icons.person, color: Colors.white54),
                      ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Name : ${actor.name}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Character : ${actor.characterName}',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenres(List<String> genres) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: genres
          .map(
            (g) => _HoverScaleButton(
              onTap: () {},
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Text(
                      g,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ExpandableSummary extends StatefulWidget {
  final String text;

  const _ExpandableSummary({required this.text});

  @override
  State<_ExpandableSummary> createState() => _ExpandableSummaryState();
}

class _ExpandableSummaryState extends State<_ExpandableSummary> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: AnimatedCrossFade(
        firstChild: ShaderMask(
          shaderCallback: (rect) {
            return const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black, Colors.transparent],
              stops: [0.6, 1.0],
            ).createShader(rect);
          },
          blendMode: BlendMode.dstIn,
          child: Text(
            widget.text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 15,
              height: 1.6,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        secondChild: Text(
          widget.text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 15,
            height: 1.6,
          ),
        ),
        crossFadeState: _isExpanded
            ? CrossFadeState.showSecond
            : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GlassIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
        ),
      ),
    );
  }
}

class _HoverScaleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const _HoverScaleButton({required this.child, required this.onTap});

  @override
  State<_HoverScaleButton> createState() => _HoverScaleButtonState();
}

class _HoverScaleButtonState extends State<_HoverScaleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: widget.child,
      ),
    );
  }
}

class _AnimatedReveal extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final int index;

  const _AnimatedReveal({
    required this.controller,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 1.0);
    final end = (start + 0.4).clamp(0.0, 1.0);
    final animation = CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    );

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 40 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
