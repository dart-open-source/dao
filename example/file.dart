import 'dart:io';

import 'package:alm/alm.dart';
import 'package:dao/dao.dart';

void main() async {
  Alm.timer();

  Alm.gitIgnoreUpdate(File('.gitignore'), '.db');

  var id = Alm.timeId();
  var dbUrl = Alm.config['filedb'] ?? 'filedb:///.db/test';
  print('Alm.id=$id,dbUrl=$dbUrl');

  await Dao.init(dbUrl);

  var collection = Dao.db('test');

  await collection.drop();

  for (var i = 0; i < 1000; i++) {
    await collection.insert({'id': id, 'foo': Alm.randomString(32)});
  }
  var count = await collection.count();
  print('count:$count');
  var info = await collection.findOne('id', id);
  print('info:$info');

  Alm.timerDiff();
}
