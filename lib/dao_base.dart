import 'dart:convert';
import 'dart:io';

import 'package:alm/alm.dart';
import 'package:convert/convert.dart';
import 'package:mongo_dart/mongo_dart.dart';

final Dao = _Dao();

class _Dao {
  DaoData _db;

  DaoDb db(String name) => DaoDb(_db, name);

  Future init(String config) async => _db = DaoData(config);

  Future connect() async => await _db.open();

  Future close() async => await _db.close();
}

class DaoData {
  Db _db;
  FileDb _file;

  Uri uri;

  bool get isOpen => isMongo ? (_db.state == State.OPEN || _db.state == State.OPENING) : _file.isOpen;

  bool get isMongo => uri.scheme.toLowerCase() == 'mongodb';

  bool get isFile => uri.scheme.toLowerCase() == 'filedb';

  DbCollection mongoCol(name) => _db.collection(name);

  FileCol fileCol(name) => _file.collection(name);

  DaoData(String config) {
    if (!Alm.isString(config)) throw Exception('config is null');
    uri = Uri.parse(config);
    if (isMongo) _db = Db(config);
    if (isFile) _file = FileDb(config);
  }

  Future open() async {
    if (isMongo&&!isOpen) await _db.open();
  }

  Future close() async {
    if (isMongo&&isOpen) await _db.close();
  }

  Future drop() async {
    if (isMongo) await _db.drop();
  }
}

class DaoDb {
  DaoData db;
  DbCollection mongo;
  FileCol file;
  String name;

  DaoDb(this.db, this.name) {
    if (db.isMongo) mongo = db.mongoCol(name);
    if (db.isFile) file = db.fileCol(name);
  }

  Future<void> drop() async {
    if (db.isMongo) return await mongo.drop();
    if (db.isFile) return await file.drop();
  }

  Future<int> count() async {
    if (db.isMongo) return await mongo.count();
    if (db.isFile) return await file.count();
    return 0;
  }

  Future<dynamic> insert(Map map) async {
    if (db.isMongo) return await mongo.insert(Map.from(map));
    if (db.isFile) return await file.insert(Map.from(map));
    return 0;
  }

  Future<dynamic> findOne(String field, String val) async {
    if (db.isMongo) return await mongo.findOne(where.eq(field, val));
    if (db.isFile) return await file.findOne(field, val);
    return null;
  }
  Future<dynamic> find(String field, String val) async {
    if (db.isMongo) return await mongo.find(where.eq(field, val)).toList();
    if (db.isFile) return await file.find(field, val);
    return null;
  }
}

class FileDb {
  File _file;

  FileDb(String config) {
    _file = Alm.file(Uri.parse(config).path.substring(1), autoDir: true);
  }

  bool get isOpen => false;

  FileCol collection(name) {
    return FileCol(Alm.file(_file.path + '-$name.db', autoDir: true));
  }
}

class FileCol {
  File file;

  FileCol(this.file);

  bool get has => file.existsSync();

  Future drop() async {
    if (has) file.deleteSync();
  }

  Future<int> count() async {
    if (has) return file.readAsLinesSync().length;
    return 0;
  }

  Future<dynamic> insert(Map map) async {
    var _map = {};
    _map['_id'] = ObjectId();
    map.forEach((key, value) {
      _map[key] = value;
    });
    file.writeAsStringSync(hex.encode(jsonEncode(_map).codeUnits) + '\n', mode: FileMode.append);
    return null;
  }

  Future<dynamic> findOne(String field, String val) async {
    var res=await find(field, val,length: 1);
    if(Alm.isList(res,gte:1)) return Alm.list(res).first;
    return null;
  }

  Future<dynamic> find(String field, String val,{int length}) async {
    var res=[];
    for (var item in file.readAsLinesSync()) {
      var map = jsonDecode(utf8.decode(hex.decode(item)));
      if (Alm.isMap(map, field, val)) {
        res.add(map);
        if(Alm.isInt(length,res.length)) break;
      }
    }
    return res;
  }
}