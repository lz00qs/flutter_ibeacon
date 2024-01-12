import 'package:objectbox/objectbox.dart';

@Entity()
class BeaconData {
  @Id()
  int id = 0;

  String name;
  String uuid;
  int major;
  int minor;
  String identifier;
  int? txPower;

  BeaconData(
      {required this.name,
      required this.uuid,
      required this.major,
      required this.minor,
      required this.identifier});
}
