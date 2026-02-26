import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/offline_first_blueprint_repo.dart';
import '../../domain/facility_blueprint.dart';

final blueprintRepositoryProvider = Provider<OfflineFirstBlueprintRepository>((ref) {
  return OfflineFirstBlueprintRepository();
});

final blueprintStreamProvider = StreamProvider.family<Blueprint?, String>((ref, id) {
  final repo = ref.watch(blueprintRepositoryProvider);

  return repo.watchBlueprintChanges(id).map((list) {
    if (list.isEmpty) return null;
    return Blueprint.fromMap(list.first);
  });
});