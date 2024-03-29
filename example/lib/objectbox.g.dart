// GENERATED CODE - DO NOT MODIFY BY HAND
// This code was generated by ObjectBox. To update it run the generator again:
// With a Flutter package, run `flutter pub run build_runner build`.
// With a Dart package, run `dart run build_runner build`.
// See also https://docs.objectbox.io/getting-started#generate-objectbox-code

// ignore_for_file: camel_case_types, depend_on_referenced_packages
// coverage:ignore-file

import 'dart:typed_data';

import 'package:flat_buffers/flat_buffers.dart' as fb;
import 'package:objectbox/internal.dart'; // generated code can access "internal" functionality
import 'package:objectbox/objectbox.dart';
import 'package:objectbox_flutter_libs/objectbox_flutter_libs.dart';

import 'beacon_data.dart';

export 'package:objectbox/objectbox.dart'; // so that callers only have to import this file

final _entities = <ModelEntity>[
  ModelEntity(
      id: const IdUid(1, 7427985273005259455),
      name: 'BeaconData',
      lastPropertyId: const IdUid(7, 4852523580905527295),
      flags: 0,
      properties: <ModelProperty>[
        ModelProperty(
            id: const IdUid(1, 6624827547859806446),
            name: 'id',
            type: 6,
            flags: 1),
        ModelProperty(
            id: const IdUid(2, 3234073911127994447),
            name: 'name',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(3, 5725523020594613041),
            name: 'uuid',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(4, 4057326130865413373),
            name: 'major',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(5, 7910743605513419242),
            name: 'minor',
            type: 6,
            flags: 0),
        ModelProperty(
            id: const IdUid(6, 9049354517532863002),
            name: 'identifier',
            type: 9,
            flags: 0),
        ModelProperty(
            id: const IdUid(7, 4852523580905527295),
            name: 'txPower',
            type: 6,
            flags: 0)
      ],
      relations: <ModelRelation>[],
      backlinks: <ModelBacklink>[])
];

/// Shortcut for [Store.new] that passes [getObjectBoxModel] and for Flutter
/// apps by default a [directory] using `defaultStoreDirectory()` from the
/// ObjectBox Flutter library.
///
/// Note: for desktop apps it is recommended to specify a unique [directory].
///
/// See [Store.new] for an explanation of all parameters.
Future<Store> openStore(
        {String? directory,
        int? maxDBSizeInKB,
        int? fileMode,
        int? maxReaders,
        bool queriesCaseSensitiveDefault = true,
        String? macosApplicationGroup}) async =>
    Store(getObjectBoxModel(),
        directory: directory ?? (await defaultStoreDirectory()).path,
        maxDBSizeInKB: maxDBSizeInKB,
        fileMode: fileMode,
        maxReaders: maxReaders,
        queriesCaseSensitiveDefault: queriesCaseSensitiveDefault,
        macosApplicationGroup: macosApplicationGroup);

/// Returns the ObjectBox model definition for this project for use with
/// [Store.new].
ModelDefinition getObjectBoxModel() {
  final model = ModelInfo(
      entities: _entities,
      lastEntityId: const IdUid(1, 7427985273005259455),
      lastIndexId: const IdUid(0, 0),
      lastRelationId: const IdUid(0, 0),
      lastSequenceId: const IdUid(0, 0),
      retiredEntityUids: const [],
      retiredIndexUids: const [],
      retiredPropertyUids: const [],
      retiredRelationUids: const [],
      modelVersion: 5,
      modelVersionParserMinimum: 5,
      version: 1);

  final bindings = <Type, EntityDefinition>{
    BeaconData: EntityDefinition<BeaconData>(
        model: _entities[0],
        toOneRelations: (BeaconData object) => [],
        toManyRelations: (BeaconData object) => {},
        getId: (BeaconData object) => object.id,
        setId: (BeaconData object, int id) {
          object.id = id;
        },
        objectToFB: (BeaconData object, fb.Builder fbb) {
          final nameOffset = fbb.writeString(object.name);
          final uuidOffset = fbb.writeString(object.uuid);
          final identifierOffset = fbb.writeString(object.identifier);
          fbb.startTable(8);
          fbb.addInt64(0, object.id);
          fbb.addOffset(1, nameOffset);
          fbb.addOffset(2, uuidOffset);
          fbb.addInt64(3, object.major);
          fbb.addInt64(4, object.minor);
          fbb.addOffset(5, identifierOffset);
          fbb.addInt64(6, object.txPower);
          fbb.finish(fbb.endTable());
          return object.id;
        },
        objectFromFB: (Store store, ByteData fbData) {
          final buffer = fb.BufferContext(fbData);
          final rootOffset = buffer.derefObject(0);
          final nameParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 6, '');
          final uuidParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 8, '');
          final majorParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 10, 0);
          final minorParam =
              const fb.Int64Reader().vTableGet(buffer, rootOffset, 12, 0);
          final identifierParam = const fb.StringReader(asciiOptimization: true)
              .vTableGet(buffer, rootOffset, 14, '');
          final object = BeaconData(
              name: nameParam,
              uuid: uuidParam,
              major: majorParam,
              minor: minorParam,
              identifier: identifierParam)
            ..id = const fb.Int64Reader().vTableGet(buffer, rootOffset, 4, 0)
            ..txPower = const fb.Int64Reader()
                .vTableGetNullable(buffer, rootOffset, 16);

          return object;
        })
  };

  return ModelDefinition(model, bindings);
}

/// [BeaconData] entity fields to define ObjectBox queries.
class BeaconData_ {
  /// see [BeaconData.id]
  static final id =
      QueryIntegerProperty<BeaconData>(_entities[0].properties[0]);

  /// see [BeaconData.name]
  static final name =
      QueryStringProperty<BeaconData>(_entities[0].properties[1]);

  /// see [BeaconData.uuid]
  static final uuid =
      QueryStringProperty<BeaconData>(_entities[0].properties[2]);

  /// see [BeaconData.major]
  static final major =
      QueryIntegerProperty<BeaconData>(_entities[0].properties[3]);

  /// see [BeaconData.minor]
  static final minor =
      QueryIntegerProperty<BeaconData>(_entities[0].properties[4]);

  /// see [BeaconData.identifier]
  static final identifier =
      QueryStringProperty<BeaconData>(_entities[0].properties[5]);

  /// see [BeaconData.txPower]
  static final txPower =
      QueryIntegerProperty<BeaconData>(_entities[0].properties[6]);
}
