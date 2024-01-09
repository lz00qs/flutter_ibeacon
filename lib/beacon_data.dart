class BeaconData {
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

bool isValidBeaconUUID(String uuid) {
  RegExp uuidRegex = RegExp(
      r'^[\dA-Fa-f]{8}-[\dA-Fa-f]{4}-[\dA-Fa-f]{4}-[\dA-Fa-f]{4}-[\dA-Fa-f]{12}$');
  return uuidRegex.hasMatch(uuid);
}

bool isValidBeaconIdentifier(String input) {
  RegExp domainRegex =
      RegExp(r'^[a-zA-Z\d-]+(\.[a-zA-Z\d-]+)*(\.[a-zA-Z]{2,})$');
  return domainRegex.hasMatch(input);
}
