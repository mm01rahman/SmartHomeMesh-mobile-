import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../services/local_http_service.dart';

final localHttpProvider = Provider((ref) => LocalHttpService());
