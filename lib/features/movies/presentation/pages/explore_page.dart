import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/movie.dart';
import '../bloc/movies_bloc.dart';
import '../bloc/movies_event.dart';
import '../bloc/movies_state.dart';
import 'movie_details_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> with TickerProviderStateMixin {
  final List<String> _genres = ['Action', 'Adventure', 'Animation', 'Biography', 'Comedy', 'Crime', 'Documentary', 'Drama', 'Family', 'Fantasy', 'History', 'Horror', 'Music', 'Mystery', 'Romance', 'Sci-Fi', 'Sport', 'Thriller', 'War', 'Western'];
  String _selectedGenre = 'Action'; 
  
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fetchMoviesForGenre();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _fetchMoviesForGenre() {
    _staggerController.reset();
    context.read<MoviesBloc>().add(
      FetchMoviesEvent(
        page: 1,
        genre: _selectedGenre,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            Container(
              height: 50,
              margin: const EdgeInsets.only(top: 16, bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _genres.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final genre = _genres[index];
                  final isSelected = genre == _selectedGenre;
                  return _HoverScaleButton(
                    onTap: () {
                      if (!isSelected) {
                        setState(() => _selectedGenre = genre);
                        _fetchMoviesForGenre();
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryYellow : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? Colors.transparent : AppTheme.primaryYellow.withOpacity(0.8),
                          width: 1.5,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))]
                            : [],
                      ),
                      child: Text(
                        genre,
                        style: TextStyle(
                          color: isSelected ? AppTheme.backgroundDark : AppTheme.primaryYellow,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            
            Expanded(
              child: BlocConsumer<MoviesBloc, MoviesState>(
                listener: (context, state) {
                  if (state is MoviesLoaded) {
                    _staggerController.forward(from: 0.0);
                  }
                },
                builder: (context, state) {
                  if (state is MoviesLoading) {
                    return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
                  } else if (state is MoviesError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: AppTheme.destructiveRed)));
                  } else if (state is MoviesLoaded) {
                    final movies = state.movies;
                    if (movies.isEmpty) {
                      return const Center(
                        child: Text('No movies found for this genre', style: TextStyle(color: Colors.white70, fontSize: 18)),
                      );
                    }
                    
                    return GridView.builder(
                      padding: const EdgeInsets.only(left: 20, right: 20, top: 16, bottom: 120),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.65,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 20,
                      ),
                      itemCount: movies.length,
                      itemBuilder: (context, index) {
                        final movie = movies[index];
                        return _AnimatedGridItem(
                          controller: _staggerController,
                          index: index,
                          child: _CinematicMovieCard(movie: movie),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CinematicMovieCard extends StatefulWidget {
  final Movie movie;

  const _CinematicMovieCard({required this.movie});

  @override
  State<_CinematicMovieCard> createState() => _CinematicMovieCardState();
}

class _CinematicMovieCardState extends State<_CinematicMovieCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        Navigator.push(context, MaterialPageRoute(builder: (_) => MovieDetailsPage(movieId: widget.movie.id)));
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 1.05 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: _isPressed 
              ? [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)]
              : [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                
                CachedNetworkImage(
                  imageUrl: widget.movie.mediumCoverImage,
                  fit: BoxFit.cover,
                  memCacheWidth: 300,
                  placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.05)),
                  errorWidget: (context, url, error) => Container(color: Colors.white.withOpacity(0.05), child: const Icon(Icons.error, color: Colors.white54)),
                ),
                
                
                
                
                Positioned(
                  top: 12,
                  left: 12,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withOpacity(0.15), width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.movie.rating}', 
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.star_rounded, color: AppTheme.primaryYellow, size: 14),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AnimatedGridItem extends StatelessWidget {
  final AnimationController controller;
  final Widget child;
  final int index;

  const _AnimatedGridItem({
    required this.controller,
    required this.child,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedIndex = index < 10 ? index : index % 10;
    final start = (normalizedIndex * 0.05).clamp(0.0, 1.0);
    final end = (start + 0.5).clamp(0.0, 1.0);
    
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
            offset: Offset(0, 50 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
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
