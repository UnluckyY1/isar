import 'dart:async';

import 'package:isar/isar.dart';
import 'package:test/test.dart';

import 'user_model.dart';
import 'util/common.dart';
import 'util/listener.dart';

void main() {
  group('open / close isar listener', () {
    isarTest('Open listener', () async {
      final streamController = StreamController<Isar>();
      void openListener(Isar isar) => streamController.add(isar);
      Isar.addOpenListener(openListener);
      final listener = Listener(streamController.stream);

      final isar1 = await openTempIsar([UserModelSchema], autoClose: false);
      final listenedIsar1 = await listener.next;
      expect(isar1, listenedIsar1);
      await isar1.close();

      final isar2 = await openTempIsar([UserModelSchema], autoClose: false);
      final listenerIsar2 = await listener.next;
      expect(isar2, listenerIsar2);
      await isar2.close();

      Isar.removeOpenListener(openListener);
      await listener.done();
      await streamController.close();
    });

    isarTest('Close listener', () async {
      final streamController = StreamController<String>();
      void closeListener(String name) => streamController.add(name);
      Isar.addCloseListener(closeListener);
      final listener = Listener(streamController.stream);

      final isar1 = await openTempIsar([UserModelSchema], autoClose: false);
      await isar1.close();
      final listenedName1 = await listener.next;
      expect(isar1.name, listenedName1);

      final isar2 = await openTempIsar([UserModelSchema], autoClose: false);
      await isar2.close();
      final listenedName2 = await listener.next;
      expect(isar2.name, listenedName2);

      Isar.removeCloseListener(closeListener);
      await listener.done();
      await streamController.close();
    });
  });
}
