import 'facility_blueprint.dart';

abstract class BlueprintRepository {
  /// Saves the current layout to the local database and attempts to sync to the cloud
  Future<void> saveBlueprint(Blueprint blueprint);

  /// Loads a specific saved layout from the database
  Future<Blueprint> getBlueprint(String id);

  /// Converts the layout into a raw JSON string for external system integration
  Future<String> exportToJson(String blueprintId);

  /// Listens for real-time updates to all blueprints in a specific facility
  Stream<List<Blueprint>> watchBlueprintsForFacility(String facilityId);
}