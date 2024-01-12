import 'package:flutter/material.dart';

import 'package:flutter_ibeacon/flutter_ibeacon.dart';
import 'package:flutter_ibeacon_example/ibeacon_controller.dart';
import 'package:get/get.dart';

import 'beacon_data.dart';

class MainPage extends StatelessWidget {
  final RxString eventTime = "".obs;
  final RxString methodTest = "".obs;
  final IbeaconController controller = Get.find();

  MainPage({super.key});

  final _beaconItems = <BeaconData>[].obs;

  // final RxInt _beaconBroadcasting = 0.obs;

  @override
  Widget build(BuildContext context) {
    _beaconItems.bindStream(controller.objectBox.getBeacons());
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
                        uuid: '39ED98FF-2900-441A-802F-9C398FC199D2',
                        major: 0,
                        minor: 0,
                        identifier: 'top.hylcreative.beacon')));
                if (result != null) {
                  // _beaconItems.add(result);
                  controller.objectBox.addBeacon(result);
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
                          var isChosen = false;
                          // _beaconItems.removeAt(index);
                          controller.objectBox.removeBeacon(item.id);
                          if (controller.beaconIndex.value == index) {
                            isChosen = true;
                            controller.updateIndex(0);
                          }
                          // 刷新UI
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 2),
                              content: const Text('Beacon deleted'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () {
                                  // 撤销删除
                                  // _beaconItems.insert(index, item);
                                  if (isChosen) {
                                    controller.updateIndex(index);
                                  }
                                  controller.objectBox.addBeacon(item);
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
                                  value: index == controller.beaconIndex.value,
                                  onChanged: (value) {
                                    // 开启或关闭 beacon 的逻辑
                                    // controller.beaconIndex.value = index;
                                    controller.updateIndex(index);
                                  }),
                              onLongPress: () async {
                                final result = await Get.dialog(BeaconDialog(
                                    isAdd: false, item: _beaconItems[index]));
                                if (result != null) {
                                  // _beaconItems[index] = result;
                                  result.id = _beaconItems[index].id;
                                  controller.objectBox.addBeacon(result);
                                }
                              },
                            )));
                  }))),
          ElevatedButton(
              onPressed: () async {
                // 开启或关闭 beacon 的逻辑
                if (controller.isAdvertising.value == false) {
                  await controller.flutterIbeacon.startAdvertising(
                      uuid: _beaconItems[controller.beaconIndex.value].uuid,
                      major: _beaconItems[controller.beaconIndex.value].major,
                      minor: _beaconItems[controller.beaconIndex.value].minor,
                      identifier: _beaconItems[controller.beaconIndex.value]
                          .identifier);
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
          ],
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel')),
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
    );
  }
}
