import 'dart:async';
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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with TickerProviderStateMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;
  String _query = '';
  
  late AnimationController _staggerController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _searchFocusNode.addListener(() {
      setState(() {}); // Trigger rebuild to update search bar glow
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _staggerController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _query = query.trim();
      });
      if (_query.isNotEmpty) {
        _staggerController.reset();
        context.read<MoviesBloc>().add(FetchMoviesEvent(page: 1, query: _query));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // Search Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: _buildSearchBar(),
            ),
            
            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _query.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    final isFocused = _searchFocusNode.hasFocus;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutBack,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: isFocused ? AppTheme.primaryYellow.withOpacity(0.5) : Colors.white.withOpacity(0.1),
          width: isFocused ? 1.5 : 1.0,
        ),
        boxShadow: [
          if (isFocused)
            BoxShadow(
              color: AppTheme.primaryYellow.withOpacity(0.15),
              blurRadius: 20,
              spreadRadius: 2,
            )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Row(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 20, right: 12),
                child: Icon(Icons.search_rounded, color: Colors.white, size: 26),
              ),
              Expanded(
                child: TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: _onSearchChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
                  cursorColor: AppTheme.primaryYellow,
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 18),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
              if (_searchController.text.isNotEmpty)
                GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Icon(Icons.close_rounded, color: Colors.white.withOpacity(0.6), size: 24),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      key: const ValueKey('empty_state'),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/Empty 1.png',
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 24),
          const Text(
            'Discover Cinematic Masterpieces',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Type a movie name to start searching...',
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocConsumer<MoviesBloc, MoviesState>(
      listener: (context, state) {
        if (state is MoviesLoaded) {
          _staggerController.forward(from: 0.0);
        }
      },
      builder: (context, state) {
        if (state is MoviesLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
        } else if (state is MoviesError) {
          return Center(
            child: Text(state.message, style: const TextStyle(color: AppTheme.destructiveRed)),
          );
        } else if (state is MoviesLoaded) {
          final movies = state.movies;
          
          if (movies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.search_off_rounded, size: 80, color: Colors.white30),
                  const SizedBox(height: 16),
                  Text('No results found for "$_query"', style: const TextStyle(color: Colors.white70, fontSize: 18)),
                ],
              ),
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
                child: _CinematicSearchCard(movie: movie),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}

class _CinematicSearchCard extends StatefulWidget {
  final Movie movie;

  const _CinematicSearchCard({required this.movie});

  @override
  State<_CinematicSearchCard> createState() => _CinematicSearchCardState();
}

class _CinematicSearchCardState extends State<_CinematicSearchCard> {
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
        scale: _isPressed ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            boxShadow: _isPressed 
              ? [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)]
              : [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Poster
                CachedNetworkImage(
                  imageUrl: widget.movie.mediumCoverImage,
                  fit: BoxFit.cover,
                  memCacheWidth: 300,
                  placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.05)),
                  errorWidget: (context, url, error) => Container(color: Colors.white.withOpacity(0.05), child: const Icon(Icons.error, color: Colors.white54)),
                ),
                
                // Rating Badge
                Positioned(
                  top: 12,
                  left: 12,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
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
    // Calculate a staggered delay based on the index
    // We cap it so items far down don't take forever if loaded at once
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
