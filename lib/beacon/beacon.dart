//  Copyright (c) 2018 Alann Maulana.
//  Licensed under Apache License v2.0 that can be
//  found in the LICENSE file.

part of flutter_beacon;

/// Enum for defining proximity.
enum Proximity { unknown, immediate, near, far }

/// Class for managing Beacon object.
class Beacon {
  /// The proximity UUID of beacon.
  final String proximityUUID;

  /// The mac address of beacon.
  ///
  /// From iOS this value will be null
  final String macAddress;

  /// The major value of beacon.
  final int major;

  /// The minor value of beacon.
  final int minor;

  /// The rssi value of beacon.
  final int rssi;

  /// The transmission power of beacon.
  ///
  /// From iOS this value will be null
  final int txPower;

  /// The accuracy of distance of beacon in meter.
  final double accuracy;

  final List<int> rawData;

  /// The proximity of beacon.
  final Proximity _proximity;

  const Beacon(
      {this.proximityUUID,
      this.macAddress,
      this.major,
      this.minor,
      this.rssi,
      this.txPower,
      this.rawData,
      this.accuracy})
      : this._proximity = null;

  /// Create beacon object from json.
  Beacon.fromJson(dynamic json)
      : proximityUUID = json['proximityUUID'],
        macAddress = json['macAddress'],
        major = json['major'],
        minor = json['minor'],
        rssi = _parseInt(json['rssi']),
        rawData = _parseListInt(json['rawData']),
        txPower = _parseInt(json['txPower']),
        accuracy = _parseDouble(json['accuracy']),
        _proximity = _parseProximity(json['proximity']);

  /// Parsing dynamic data into double.
  static double _parseDouble(dynamic data) {
    if (data is num) {
      return data;
    } else if (data is String) {
      return double.tryParse(data) ?? 0.0;
    }

    return 0.0;
  }

  /// Parsing dynamic data into integer.
  static int _parseInt(dynamic data) {
    if (data is num) {
      return data;
    } else if (data is String) {
      return int.tryParse(data) ?? 0;
    }

    return 0;
  }

  static List<int> _parseListInt (dynamic data) {
    if (data is String) {
      if (data.contains('[') && data.contains(']')) {
        data = data.replaceAll('[', '');
        data = data.replaceAll(']', '');
        final listData = data.toString().split(',');
        var list = List<int>();
        listData.forEach((value) => {
          list.add(int.parse(value))
        });
        return list;
      } else return List<int>();
    } else return List<int>();
  }

  /// Parsing dynamic proximity into enum [Proximity].
  static dynamic _parseProximity(dynamic proximity) {
    if (proximity == 'unknown') {
      return Proximity.unknown;
    }

    if (proximity == 'immediate') {
      return Proximity.immediate;
    }

    if (proximity == 'near') {
      return Proximity.near;
    }

    if (proximity == 'far') {
      return Proximity.far;
    }

    return null;
  }

  /// Parsing array of [Map] into [List] of [Beacon].
  static List<Beacon> beaconFromArray(dynamic beacons) {
    if (beacons is List) {
      return beacons.map((json) {
        return Beacon.fromJson(json);
      }).toList();
    }

    return null;
  }

  /// Parsing [List] of [Beacon] into array of [Map].
  static dynamic beaconArrayToJson(List<Beacon> beacons) {
    return beacons.map((beacon) {
      return beacon.toJson;
    }).toList();
  }

  /// Serialize current instance object into [Map].
  dynamic get toJson {
    final map = <String, dynamic>{
      'proximityUUID': proximityUUID,
      'major': major,
      'minor': minor,
      'rawData': rawData,
      'rssi': rssi ?? -1,
      'accuracy': accuracy,
      'proximity': proximity.toString()
    };

    if (Platform.isAndroid) {
      map['txPower'] = txPower ?? -1;
      map['macAddress'] = macAddress ?? "";
    }

    return map;
  }

  /// Return [Proximity] of beacon.
  ///
  /// iOS will always set proximity by default, but Android is not
  /// so we manage it by filtering the accuracy like bellow :
  /// - `accuracy == 0.0` : [Proximity.unknown]
  /// - `accuracy > 0 && accuracy <= 0.5` : [Proximity.immediate]
  /// - `accuracy > 0.5 && accuracy < 3.0` : [Proximity.near]
  /// - `accuracy > 3.0` : [Proximity.far]
  Proximity get proximity {
    if (_proximity != null) {
      return _proximity;
    }

    if (accuracy == 0.0) {
      return Proximity.unknown;
    }

    if (accuracy <= 0.5) {
      return Proximity.immediate;
    }

    if (accuracy < 3.0) {
      return Proximity.near;
    }

    return Proximity.far;
  }
}
