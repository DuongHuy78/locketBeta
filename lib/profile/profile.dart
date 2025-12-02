import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/profile/cubit/profile_cubit.dart';
import 'package:locket_beta/profile/user_settings/user_settings.dart'; 
import 'package:locket_beta/utils/local_storage.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    
    return BlocProvider(
      
      create: (context) => ProfileCubit()..fetchProfile(),
      child: Scaffold(
        backgroundColor: const Color(0xff121212), 
        
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is ProfileError) {
              return Center(child: Text(state.message));
            }
            if (state is ProfileLoaded) {
              final user = state.userProfile;

              return CustomScrollView(
                slivers: [
                  SliverAppBar(
                    backgroundColor: const Color(0xff121212),
                    pinned: true,
                    elevation: 0,
                    automaticallyImplyLeading: true, 
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.people_alt_outlined, color: Colors.white),
                        onPressed: () { /* TODO: Navigate to Friends */ },
                      ),
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white),
                        onPressed: () async {
                          final updated = await Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const SettingsScreen()),
                          );
                          if (updated == true) {
                            context.read<ProfileCubit>().fetchProfile();   // ⬅ refresh profile
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      titlePadding: const EdgeInsets.only(left: 60, bottom: 16),
                      title: Text(
                        user.username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    expandedHeight: 120, 
                  ),

                  
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(user.profileImageUrl),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '@${user.handle}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton(
                                    onPressed: () { /* TODO: Locket Gold */ },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.amber,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: const Text(
                                      'Get Locket Gold',
                                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStatColumn('Lockets', user.locketCount.toString()),
                              // _buildStatColumn('Streak', '${user.streak.toString()}d'),
                              _buildStatColumn('Friends', user.friendCount.toString()), 
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  
                   ...state.groupedLocket.entries.map((entry) {
                     return SliverToBoxAdapter(
                       child: Column(
                         crossAxisAlignment: CrossAxisAlignment.start,
                         children: [
                           Padding(
                             padding: const EdgeInsets.all(16.0),
                             child: Text(
                               entry.key, 
                               style: const TextStyle(
                                 color: Colors.white,
                                 fontSize: 18,
                                 fontWeight: FontWeight.bold,
                               ),
                             ),
                           ),
                           GridView.builder(
                             padding: const EdgeInsets.symmetric(horizontal: 16),
                             shrinkWrap: true,
                             physics: const NeverScrollableScrollPhysics(),
                             gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                               crossAxisCount: 4,
                               crossAxisSpacing: 8,
                               mainAxisSpacing: 8,
                             ),
                             itemCount: entry.value.length, 
                             itemBuilder: (context, index) {
                               final locket = entry.value[index];
                               return ClipRRect(
                                 borderRadius: BorderRadius.circular(12),
                                 child: Image.network(
                                   locket.imageUrl,
                                   fit: BoxFit.cover,
                                    
                                    errorBuilder: (context, error, stackTrace) =>
                                        Container(color: Colors.grey[800], child: Icon(Icons.broken_image, color: Colors.grey[600])),
                                 ),
                               );
                             },
                           ),
                           const SizedBox(height: 20),
                         ],
                       ),
                     );
                   }).toList(),
                ],
              );
            }
            return Container(); 
          },
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}