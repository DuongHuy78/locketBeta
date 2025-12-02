import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:locket_beta/friends/cubit/friend_cubit.dart';
import 'package:locket_beta/friends/cubit/friendRequest_cubit.dart';
import 'package:locket_beta/friends/cubit/recommendation_cubit.dart';
import 'package:locket_beta/friends/cubit/friend_state.dart';
import 'package:locket_beta/friends/cubit/friendRequest_state.dart';
import 'package:locket_beta/friends/cubit/recommendation_state.dart';
import 'package:locket_beta/model/friend_model.dart';
import 'package:locket_beta/model/friend_request_model.dart';
import 'package:locket_beta/utils/local_storage.dart';
import 'package:locket_beta/messenger/message/view/message.dart';
import 'package:locket_beta/model/chat_model.dart';

class FriendsScreen extends StatelessWidget {
  const FriendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => FriendCubit()..loadFriends(),
        ),
        BlocProvider(
          create: (_) => FriendRequestCubit()..loadFriendRequests(),
        ),
        BlocProvider(
          create: (_) => RecommendationCubit()..loadRecommendations(),
        ),
      ],
      child: const FriendsView(),
    );
  }
}

class FriendsView extends StatefulWidget {
  const FriendsView({super.key});

  @override
  State<FriendsView> createState() => _FriendsViewState();
}

class _FriendsViewState extends State<FriendsView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, bool> _pendingStatus = {}; // track pending state per friend

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151415),
      appBar: AppBar(
        backgroundColor: const Color(0xff151415),
        foregroundColor: Colors.white,
        title: const Text('Friends'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'Your Friends'),
            Tab(text: 'Requests'),
            Tab(text: 'Recommendations'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Find Friend from other App',
                  style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _socialItem(
                        imageUrl: "assets/images/mess_icon.jpg",
                        label: 'Messenger'),
                    _socialItem(
                        imageUrl: "assets/images/zalo_icon.jpg", label: 'Zalo'),
                    _socialItem(
                        imageUrl: "assets/images/ig_icon.jpg",
                        label: 'Instagram'),
                    _socialItem(
                        imageUrl: "assets/images/defaultUser.png",
                        label: 'Others'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Your Friends
                BlocBuilder<FriendCubit, FriendState>(
                  builder: (context, state) {
                    final cubit = context.read<FriendCubit>();
                    if (state is FriendLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FriendLoaded) {
                      return _friendList(state.friends, cubit);
                    } else if (state is FriendError) {
                      return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.white)));
                    }
                    return const Center(
                        child: Text('No Friends',
                            style: TextStyle(color: Colors.white)));
                  },
                ),

                // Friend Requests
                BlocBuilder<FriendRequestCubit, FriendRequestState>(
                  builder: (context, state) {
                    final cubit = context.read<FriendRequestCubit>();
                    if (state is FriendRequestLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is FriendRequestLoaded) {
                      return _friendRequestList(state.requests, cubit);
                    } else if (state is FriendRequestError) {
                      return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.white)));
                    }
                    return const Center(
                        child: Text('No Requests',
                            style: TextStyle(color: Colors.white)));
                  },
                ),

                // Recommendations
                BlocBuilder<RecommendationCubit, RecommendationState>(
                  builder: (context, state) {
                    if (state is RecommendationLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is RecommendationLoaded) {
                      final requestCubit = context.read<FriendRequestCubit>();
                      return _friendList(state.recommendations, requestCubit,
                          isRecommendation: true);
                    } else if (state is RecommendationError) {
                      return Center(
                          child: Text(state.message,
                              style: const TextStyle(color: Colors.white)));
                    }
                    return const Center(
                        child: Text('No Recommendations',
                            style: TextStyle(color: Colors.white)));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _friendList(List<Friend> friends, dynamic cubit,
      {bool isRecommendation = false}) {
    if (friends.isEmpty) {
      return const Center(
          child: Text('No friends',
              style: TextStyle(color: Colors.white, fontSize: 16)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: friends.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final friend = friends[index];
        final isPending = _pendingStatus[friend.id] ?? false;

        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xff2a2a2a),
            backgroundImage: friend.profileImage != null ? NetworkImage(friend.profileImage!) : null,
            child: friend.profileImage == null
                ? Text(friend.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white))
                : null,
          ),
          title: Text(friend.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: Text(
              friend.isActive
                  ? 'Online'
                  : 'Last seen: ${_formatLastSeen(friend.lastSeen)}',
              style: TextStyle(
                  color: friend.isActive ? Colors.green : Colors.grey)),
          trailing: isRecommendation
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isPending ? Colors.grey : Color(0xFFFFC700),
                  ),
                  onPressed: () async {
                    final requestCubit = cubit as FriendRequestCubit;
                    if (!isPending) {
                      final senderId = await LocalStorage.getUserId();
                      if (senderId != null) {
                        try {
                          await requestCubit.sendFriendRequest(
                              senderId, friend.id);
                          setState(() {
                            _pendingStatus[friend.id] = true;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Friend request sent')),
                          );
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text('Failed to send request: $e')),
                          );
                        }
                      }
                    } else {
                      // Confirm unsend
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Confirm'),
                          content: const Text('Unsend your request?'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel')),
                            TextButton(
                                onPressed: () async {
                                  final senderId =
                                      await LocalStorage.getUserId();
                                  if (senderId != null) {
                                    await cubit.cancelFriendRequest(friend.id);
                                    setState(() {
                                      _pendingStatus[friend.id] = false;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                                child: const Text('Ok')),
                          ],
                        ),
                      );
                    }
                  },
                  child: Text(
                    isPending ? 'Pending' : 'Add',
                    style: const TextStyle(color: Colors.black),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat, color: Color(0xFFFFC700)),
                      onPressed: () async {
                        final currentUserId = await LocalStorage.getUserId();
                        if (currentUserId == null) return;

                        final userShort = UserShort(
                          id: friend.id,
                          username: friend.name,
                          avatar: friend.profileImage,
                        );

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => MessagePage(
                              currentFriend: userShort,
                              chatId: friend.id,
                              currentUserId: currentUserId,
                            ),
                          ),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirm'),
                            content:
                                const Text('You want to delete this friend?'),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel')),
                              TextButton(
                                  onPressed: () {
                                    cubit.removeFriend(friend.id);
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Ok')),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
        );
      },
    );
  }

  Widget _friendRequestList(
      List<FriendRequest> requests, FriendRequestCubit cubit) {
    if (requests.isEmpty) {
      return const Center(
          child: Text('No requests',
              style: TextStyle(color: Colors.white, fontSize: 16)));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: requests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final req = requests[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: const Color(0xff2a2a2a),
            backgroundImage: req.profileImage != null ? NetworkImage(req.profileImage!) : null,
            child: req.profileImage == null
                ? Text(req.name[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white))
                : null,
          ),
          title: Text(req.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w600)),
          subtitle: const Text('Sent you a friend request',
              style: TextStyle(color: Colors.grey, fontSize: 13)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () => cubit.acceptFriendRequest(req.id)),
              IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () => cubit.rejectFriendRequest(req.id)),
            ],
          ),
        );
      },
    );
  }

  Widget _socialItem({required String imageUrl, required String label}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: const BoxDecoration(shape: BoxShape.circle),
          child: ClipOval(
            child: Image.asset(
              imageUrl,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 9),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      ],
    );
  }

  String _formatLastSeen(DateTime lastSeen) {
    final now = DateTime.now();
    final diff = now.difference(lastSeen);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${lastSeen.day}/${lastSeen.month}/${lastSeen.year}';
  }
}
