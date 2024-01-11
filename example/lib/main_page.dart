import 'package:flutter/material.dart';
import 'package:flutter_ibeacon/beacon_data.dart';
import 'package:flutter_ibeacon/flutter_ibeacon.dart';
import 'package:flutter_ibeacon_example/IbeaconController.dart';
import 'package:get/get.dart';

class MainPage extends StatelessWidget {
  final RxString eventTime = "".obs;
  final RxString methodTest = "".obs;
  final IbeaconController controller = Get.find();

  MainPage({super.key});

  final _beaconItems = <BeaconData>[
    BeaconData(
        name: "Default",
        uuid: "39ED98FF-2900-441A-802F-9C398FC199D2",
        major: 100,
        minor: 1,
        identifier: "top.hylcreative.beacon"),
    BeaconData(
        name: "Default2",
        uuid: "39ED98FF-2900-441A-802F-9C398FC199D2",
        major: 100,
        minor: 1,
        identifier: "top.hylcreative.beacon")
  ].obs;

  final RxInt _beaconBroadcasting = 0.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('iBeacon Broadcaster'),
        actions: [
          IconButton(
              onPressed: () async {
                // 添加 beacon item 逻辑
                final result = await Get.dialog(BeaconDialog(
                    isAdd: false,
                    item: BeaconData(
                        name: 'New Item',
                        uuid: '39ED98FF-2900-441A-802F-9C398FC199D',
                        major: 0,
                        minor: 0,
                        identifier: '')));
                if (result != null) {
                  _beaconItems.add(result);
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Obx(() => Text(eventTime.value)),
          Obx(() => Text(methodTest.value)),
          Expanded(
              child: Obx(() => ListView.builder(
                  itemCount: _beaconItems.length,
                  itemBuilder: (context, index) {
                    return Dismissible(
                        key: UniqueKey(), // 必须设置唯一的key
                        onDismissed: (direction) {
                          final item = _beaconItems[index];
                          _beaconItems.removeAt(index);
                          // 刷新UI
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 2),
                              content: const Text('Beacon deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // 撤销删除
                                  _beaconItems.insert(index, item);
                                },
                              ),
                            ),
                          );
                        },
                        background: Container(
                          color: Colors.red,
                          child: const Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: EdgeInsets.only(left: 16.0),
                              child: Icon(
                                Icons.delete,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        child: Obx(() => ListTile(
                              title: Text(_beaconItems[index].name),
                              subtitle: Text(_beaconItems[index].uuid),
                              trailing: Checkbox(
                                  value: index == _beaconBroadcasting.value,
                                  onChanged: (value) {
                                    // 开启或关闭 beacon 的逻辑
                                    _beaconBroadcasting.value = index;
                                  }),
                              onLongPress: () async {
                                final result = await Get.dialog(BeaconDialog(
                                    isAdd: false, item: _beaconItems[index]));
                                if (result != null) {
                                  _beaconItems[index] = result;
                                }
                              },
                            )));
                  }))),
          ElevatedButton(
              onPressed: () async {
                // 开启或关闭 beacon 的逻辑
                if (controller.isAdvertising.value == false) {
                  await controller.flutterIbeacon.startAdvertising(
                      _beaconItems[_beaconBroadcasting.value]);
                } else {
                  await controller.flutterIbeacon.stopAdvertising();
                }
                // methodTest.value = await methodChannel.invokeMethod('test');
              },
              child: Obx(() => Text(!controller.isAdvertising.value
                  ? 'Enable Beacon'
                  : 'Disable Beacon'))),
          const SizedBox(
            height: 50,
          )
        ],
      )),
    );
  }
}

class BeaconDialog extends StatelessWidget {
  final bool isAdd;
  final BeaconData item;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController uuidController = TextEditingController();
  final TextEditingController majorController = TextEditingController();
  final TextEditingController minorController = TextEditingController();
  final TextEditingController identifierController = TextEditingController();

  BeaconDialog({Key? key, this.isAdd = true, required this.item})
      : super(key: key) {
    if (!isAdd) {
      nameController.text = item.name;
      uuidController.text = item.uuid;
      majorController.text = item.major.toString();
      minorController.text = item.minor.toString();
      identifierController.text = item.identifier;
    }
  }

  @override
  Widget build(BuildContext context) {
    RxString uuid = RxString(uuidController.text);
    RxString identifier = RxString(identifierController.text);
    return AlertDialog(
      title: Text(isAdd ? 'Add Beacon' : 'Edit Beacon'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: nameController,
              maxLines: null,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            Obx(() => TextField(
                  controller: uuidController,
                  onChanged: (value) => uuid.value = value,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'UUID',
                      errorText: isValidBeaconUUID(uuid.value)
                          ? null
                          : 'Invalid UUID, example: 39ED98FF-2900-441A-802F-9C398FC199D2',
                      errorMaxLines: 10),
                )),
            TextField(
              controller: majorController,
              decoration: const InputDecoration(labelText: 'Major'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: minorController,
              decoration: const InputDecoration(labelText: 'Minor'),
              keyboardType: TextInputType.number,
            ),
            Obx(() => TextField(
                  controller: identifierController,
                  onChanged: (value) => identifier.value = value,
                  maxLines: null,
                  decoration: InputDecoration(
                      labelText: 'Identifier',
                      errorText: isValidBeaconIdentifier(identifier.value)
                          ? null
                          : 'Invalid Identifier, example: top.hylcreative.beacon',
                      errorMaxLines: 10),
                )),
            const SizedBox(height: 30.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                    child: const Text('Cancel')),
                const SizedBox(width: 60.0),
                Obx(() => TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: isValidBeaconUUID(uuid.value) &&
                              isValidBeaconIdentifier(identifier.value)
                          ? Colors.blue
                          : Colors.grey,
                    ),
                    onPressed: () {
                      if (isValidBeaconUUID(uuid.value) &&
                          isValidBeaconIdentifier(identifier.value)) {
                        BeaconData newItem = BeaconData(
                          name: nameController.text,
                          uuid: uuidController.text,
                          major: int.parse(majorController.text),
                          minor: int.parse(minorController.text),
                          identifier: identifierController.text,
                        );
                        Get.back(result: newItem);
                      }
                    },
                    child: const Text('Save'))),
              ],
            )
          ],
        ),
      ),
    );
  }
}
