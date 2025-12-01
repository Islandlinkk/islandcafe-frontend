import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:islandlink_frontend/core/route/route_name.dart';
import 'package:islandlink_frontend/feature/home/presentation/screen/home_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref){
  return GoRouter(
    initialLocation: homeRoute,
    routes:[
      GoRoute(
        path:'/home',
        name: homeRoute,
        builder: (context,state) => const HomeScreen(),
      )
    ]
  );
});