import 'package:isar/isar.dart';
import 'package:test/test.dart';

import '../util/common.dart';
import '../util/sync_async_helper.dart';

part 'where_bool_list_test.g.dart';

@Collection()
class BoolModel {
  BoolModel(this.list) : hashList = list;

  Id? id;

  @Index(type: IndexType.value)
  List<bool?>? list;

  @Index(type: IndexType.hash)
  List<bool?>? hashList;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is BoolModel &&
        other.id == id &&
        listEquals(list, other.list) &&
        listEquals(hashList, other.hashList);
  }
}

void main() {
  group('Where bool list', () {
    late Isar isar;
    late IsarCollection<BoolModel> col;

    late BoolModel objEmpty;
    late BoolModel obj1;
    late BoolModel obj2;
    late BoolModel obj3;
    late BoolModel objNull;

    setUp(() async {
      isar = await openTempIsar([BoolModelSchema]);
      col = isar.boolModels;

      objEmpty = BoolModel([]);
      obj1 = BoolModel([true]);
      obj2 = BoolModel([null, false]);
      obj3 = BoolModel([true, false, true]);
      objNull = BoolModel(null);

      await isar.writeTxn(() async {
        await col.putAll([objEmpty, obj1, obj2, obj3, objNull]);
      });
    });

    isarTest('.elementEqualTo()', () async {
      await qEqual(
        col.where().listElementEqualTo(true),
        [obj1, obj3],
      );
      await qEqual(col.where().listElementEqualTo(null), [obj2]);
    });

    isarTest('.elementNotEqualTo()', () async {
      await qEqual(
        col.where().listElementNotEqualTo(true),
        [obj2, obj3],
      );
      await qEqual(
        col.where().listElementNotEqualTo(null),
        [obj1, obj2, obj3],
      );
    });

    isarTest('.elementIsNull()', () async {
      await qEqual(col.where().listElementIsNull(), [obj2]);
    });

    isarTest('.elementIsNotNull()', () async {
      await qEqual(
        col.where().listElementIsNotNull(),
        [obj1, obj2, obj3],
      );
    });

    isarTest('.equalTo()', () async {
      await qEqual(col.where().hashListEqualTo(null), [objNull]);
      await qEqual(col.where().hashListEqualTo([]), [objEmpty]);
      await qEqual(
        col.where().hashListEqualTo([null, false]),
        [obj2],
      );
    });

    isarTest('.notEqualTo()', () async {
      await qEqual(
        col.where().hashListNotEqualTo([]),
        [objNull, obj1, obj2, obj3],
      );
      await qEqual(
        col.where().hashListNotEqualTo([true, false, true]),
        [objEmpty, obj1, obj2, objNull],
      );
    });

    isarTest('.isNull()', () async {
      await qEqual(col.where().hashListIsNull(), [objNull]);
    });

    isarTest('.isNotNull()', () async {
      await qEqual(
        col.where().hashListIsNotNull(),
        [objEmpty, obj1, obj2, obj3],
      );
    });
  });
}
