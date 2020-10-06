A Database library for Dart developers.

- tested only linux and macos;
- setup main.dart file:

## FileDb Use

- file.dart

```dart
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
```
result:
```shell
Alm.id=20201006-163857-6TSEZBAH7P,dbUrl=filedb:///.db/test
count:1000
info:{_id: 5f7c2d21b654101b0d1de100, id: 20201006-163857-6TSEZBAH7P, foo: HQYMM7u6MBAopdWI9RB2zm663Y6s22CR}
0:00:00.251000
```

## MongoDb Use

-  mongo.dart;

```dart

import 'dart:io';

import 'package:alm/alm.dart';
import 'package:dao/dao.dart';

void main() async {
  Alm.timer();

  var id = Alm.timeId();
  var dbUrl = Alm.config['mongodb'] ?? 'mongodb://0.0.0.0:27017/testdb';
  print('Alm.id=$id,dbUrl=$dbUrl');

  await Dao.init(dbUrl);
  await Dao.connect();
  var collection = Dao.db('test');

  await collection.drop();

  for (var i = 0; i < 1000; i++) {
    await collection.insert({'id': id, 'foo': Alm.randomString(32)});
  }
  var count = await collection.count();
  print('count:$count');
  var info = await collection.findOne('id', id);
  print('info:$info');

  await Dao.close();

  Alm.timerDiff();
}
```
result:
```shell
Alm.id=20201006-164133-C24ANTTGSC,dbUrl=mongodb://0.0.0.0:27017/testdb
count:1000
info:{_id: ObjectId("5f7c2dbd36f013501ba700f3"), id: 20201006-164133-C24ANTTGSC, foo: QOb6rvsN0QfowAgpbrJtG9ybQiKYZVQT}
0:00:00.728000
```
....