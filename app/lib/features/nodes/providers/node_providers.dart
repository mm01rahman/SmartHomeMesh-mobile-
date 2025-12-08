import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/node_repository.dart';
import '../../../models/node.dart';

final nodesStreamProvider = StreamProvider<List<Node>>((ref) => ref.read(nodeRepositoryProvider).watchNodes());
