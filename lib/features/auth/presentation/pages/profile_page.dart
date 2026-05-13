import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../movies/domain/entities/movie.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/auth_event.dart';
import 'login_page.dart';
import 'edit_profile_page.dart';
import '../../../movies/presentation/bloc/movies_bloc.dart';
import '../../../movies/presentation/bloc/movies_event.dart';
import '../../../movies/presentation/bloc/movies_state.dart';
import '../../../movies/presentation/pages/movie_details_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> with TickerProviderStateMixin {
  late AnimationController _staggerController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _tabController = TabController(length: 2, vsync: this);

    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _staggerController.forward();
      
      context.read<MoviesBloc>().add(const FetchMoviesEvent(page: 1));
    });
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _onExit() {
    context.read<AuthBloc>().add(LogoutRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        bottom: false,
        child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is Unauthenticated) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, authState) {
            if (authState is Authenticated) {
              final user = authState.user;
              return NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 24),
                          
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 0,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  
                                  Column(
                                    children: [
                                      Container(
                                        width: 90,
                                        height: 90,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          image: user.avatarUrl != null
                                              ? DecorationImage(
                                                  image: AssetImage(user.avatarUrl!),
                                                  fit: BoxFit.cover,
                                                )
                                              : null,
                                        ),
                                        child: user.avatarUrl == null
                                            ? const Icon(Icons.person, size: 50, color: AppTheme.primaryYellow)
                                            : null,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        user.name ?? 'User',
                                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  
                                  
                                  Row(
                                    children: [
                                      _buildStatColumn('12', 'Wish List'),
                                      const SizedBox(width: 32),
                                      _buildStatColumn('10', 'History'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),

                          
                          _AnimatedReveal(
                            controller: _staggerController,
                            index: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _HoverScaleButton(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (_) => const EditProfilePage()),
                                        );
                                      },
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryYellow,
                                          borderRadius: BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: AppTheme.primaryYellow.withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: const Center(
                                          child: Text(
                                            'Edit Profile',
                                            style: TextStyle(color: Colors.black, fontSize: 16, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: _HoverScaleButton(
                                      onTap: _onExit,
                                      child: Container(
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFE50914), 
                                          borderRadius: BorderRadius.circular(30),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(0xFFE50914).withOpacity(0.3),
                                              blurRadius: 12,
                                              offset: const Offset(0, 4),
                                            )
                                          ],
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text(
                                              'Exit',
                                              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(width: 8),
                                            Icon(Icons.exit_to_app_rounded, color: Colors.white, size: 20),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                    
                    
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: _StickyTabBarDelegate(
                        child: Container(
                          color: AppTheme.backgroundDark.withOpacity(0.95), 
                          child: TabBar(
                            controller: _tabController,
                            indicatorColor: AppTheme.primaryYellow,
                            indicatorWeight: 3,
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.white,
                            labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            unselectedLabelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            tabs: const [
                              Tab(
                                icon: Icon(Icons.format_list_bulleted_rounded, color: AppTheme.primaryYellow),
                                text: 'Watch List',
                              ),
                              Tab(
                                icon: Icon(Icons.folder_rounded, color: AppTheme.primaryYellow),
                                text: 'History',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                
                body: TabBarView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    _buildMoviesGrid(isHistory: false), 
                    _buildMoviesGrid(isHistory: true), 
                  ],
                ),
              );
            }
            return const Center(child: Text('Please login to view profile', style: TextStyle(color: Colors.white)));
          },
        ),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String count, String label) {
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMoviesGrid({bool isHistory = false}) {
    return BlocBuilder<MoviesBloc, MoviesState>(
      builder: (context, state) {
        if (state is MoviesLoading) {
          return const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow));
        } else if (state is MoviesError) {
          return Center(child: Text(state.message, style: const TextStyle(color: AppTheme.destructiveRed)));
        } else if (state is MoviesLoaded) {
          var movies = state.movies;
          
          
          if (isHistory && movies.isNotEmpty) {
            movies = movies.reversed.toList();
          }

          if (movies.isEmpty) {
            return _buildEmptyState();
          }
          
          return GridView.builder(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 120),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.65,
              crossAxisSpacing: 12,
              mainAxisSpacing: 16,
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return _AnimatedReveal(
                controller: _staggerController,
                index: index % 6, 
                child: _CinematicProfileMovieCard(movie: movie),
              );
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/Empty 1.png',
          width: 150,
          height: 150,
        ),
        const SizedBox(height: 80), 
      ],
    );
  }
}

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  _StickyTabBarDelegate({required this.child});

  @override
  double get minExtent => 72.0;
  
  @override
  double get maxExtent => 72.0;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return false;
  }
}

class _CinematicProfileMovieCard extends StatefulWidget {
  final Movie movie;

  const _CinematicProfileMovieCard({required this.movie});

  @override
  State<_CinematicProfileMovieCard> createState() => _CinematicProfileMovieCardState();
}

class _CinematicProfileMovieCardState extends State<_CinematicProfileMovieCard> {
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
            borderRadius: BorderRadius.circular(18),
            boxShadow: _isPressed 
              ? [BoxShadow(color: AppTheme.primaryYellow.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)]
              : [BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 5))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: Stack(
              fit: StackFit.expand,
              children: [
                
                CachedNetworkImage(
                  imageUrl: widget.movie.mediumCoverImage,
                  fit: BoxFit.cover,
                  memCacheWidth: 250,
                  placeholder: (context, url) => Container(color: Colors.white.withOpacity(0.05)),
                  errorWidget: (context, url, error) => Container(color: Colors.white.withOpacity(0.05), child: const Icon(Icons.error, color: Colors.white54)),
                ),
                
                
                
                
                Positioned(
                  top: 8,
                  left: 8,
                  child: RepaintBoundary(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white.withOpacity(0.2), width: 0.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.movie.rating}', 
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 2),
                              const Icon(Icons.star_rounded, color: AppTheme.primaryYellow, size: 12),
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
    final start = (index * 0.1).clamp(0.0, 1.0);
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
            offset: Offset(0, 30 * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}
