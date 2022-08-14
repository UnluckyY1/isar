import 'package:isar/isar.dart';
import 'package:test/test.dart';

import '../util/common.dart';
import '../util/sync_async_helper.dart';

part 'filter_bool_list_test.g.dart';

@Collection()
class BoolModel {
  BoolModel(this.list);

  Id? id;

  @Index(type: IndexType.value)
  List<bool?>? list;

  @override
  // ignore: hash_and_equals
  bool operator ==(Object other) {
    return other is BoolModel && other.id == id && listEquals(list, other.list);
  }
}

void main() {
  group('Bool list filter', () {
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
      await qEqual(col.filter().listElementEqualTo(true), [obj1, obj3]);
      await qEqual(col.filter().listElementEqualTo(null), [obj2]);
    });

    isarTest('.elementIsNull()', () async {
      await qEqual(col.where().filter().listElementIsNull(), [obj2]);
    });

    isarTest('.isNull()', () async {
      await qEqual(col.where().filter().listIsNull(), [objNull]);
    });
  });
}
