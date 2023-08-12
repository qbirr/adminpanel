import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:useradmin/consts/constant.dart';
import 'package:useradmin/controllers/menuscontrollers.dart';
import 'package:useradmin/services/utils.dart';
import 'package:useradmin/widgets/button.dart';
import 'package:useradmin/widgets/header.dart';
import 'package:useradmin/widgets/text_widgets.dart';

class DiscountComponent extends StatelessWidget {
  DiscountComponent({super.key});

  Future<void> _deleteCoupon(String id, BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Anda yakin menghapus diskon ini?'),
          content: Row(
            children: [
              const Spacer(),
              ButtonsWidget(
                icon: Icons.close,
                onPressed: () {
                  Navigator.pop(context);
                },
                text: 'Tidak',
                backgroundColor: Colors.red,
              ),
              const SizedBox(
                width: 10,
              ),
              ButtonsWidget(
                icon: Icons.check,
                onPressed: () async {
                  Navigator.pop(context);
                  await FirebaseFirestore.instance
                      .collection('coupons')
                      .doc(id)
                      .delete();
                },
                text: 'Ya',
                backgroundColor: Colors.green,
              ),
              const Spacer(),
            ],
          ),
        );
      },
    );
  }

  Future<void> changeActive(String id, bool active) async {
    EasyLoading.show(status: 'Loading...', maskType: EasyLoadingMaskType.black);
    await FirebaseFirestore.instance
        .collection('coupons')
        .doc(id)
        .update({'active': active}).then((_) {
      EasyLoading.dismiss();
      EasyLoading.showSuccess(
          'Kupon ${active ? 'diaktifkan' : 'dinonaktifkan'}');
    });
  }

  final TextEditingController _minimumController = TextEditingController();
  final TextEditingController _valueController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = Utils(context).getScreenSize;
    Color color = Utils(context).color;
    return SafeArea(
      child: SingleChildScrollView(
        controller: ScrollController(),
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          children: [
            Header(
              fct: () {
                context.read<MenuController1>().controlDiscountMenu();
              },
              title: 'Discount',
            ),
            const SizedBox(
              height: 15,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  const Spacer(),
                  ButtonsWidget(
                      onPressed: () {
                        final formKey = GlobalKey<FormState>();
                        Get.dialog(AlertDialog(
                          title: const Text('Tambah Diskon'),
                          content: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Form(
                              key: formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Mohon isi semua field';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Isi dengan angka!';
                                      }
                                      if (int.parse(value) < 0) {
                                        return 'Nilai tidak boleh kurang dari 0';
                                      }
                                      return null;
                                    },
                                    controller: _minimumController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Minimum Belanja',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                  TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Mohon isi semua field';
                                      }
                                      if (int.tryParse(value) == null) {
                                        return 'Isi dengan angka!';
                                      }
                                      if (int.parse(value) < 0) {
                                        return 'Nilai tidak boleh kurang dari 0';
                                      }
                                      return null;
                                    },
                                    controller: _valueController,
                                    keyboardType: TextInputType.number,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: 'Nominal Potongan (%)',
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 16.0,
                                  ),
                                  ElevatedButton(
                                    onPressed: () async {
                                      if (formKey.currentState!.validate()) {
                                        EasyLoading.show(
                                            status: 'Loading...',
                                            maskType:
                                                EasyLoadingMaskType.black);
                                        await FirebaseFirestore.instance
                                            .collection('coupons')
                                            .add({
                                          'minimum': int.parse(
                                              _minimumController.text),
                                          'value':
                                              int.parse(_valueController.text),
                                          'active': true,
                                        }).then((_) {
                                          Navigator.pop(context);
                                          EasyLoading.dismiss();
                                          EasyLoading.showSuccess(
                                              'Diskon berhasil ditambahkan');
                                        });
                                      }
                                    },
                                    child: const Text('Tambah'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ));
                      },
                      text: 'Add Discount',
                      icon: Icons.add,
                      backgroundColor: Colors.blue),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('coupons')
                  .orderBy('minimum')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No data'),
                  );
                } else {
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      String id = snapshot.data!.docs[index].id;
                      Map<String, dynamic> discount =
                          snapshot.data!.docs[index].data();
                      bool isActive = discount['active'];
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Card(
                          elevation: 5,
                          child: SizedBox(
                            width: size.width,
                            child: ListTile(
                              title: TextWidget(
                                text: "Nominal Diskon : ${discount['value']}%",
                                color: color,
                              ),
                              subtitle: TextWidget(
                                text:
                                    "Minimum Belanja : ${NumberFormat.currency(locale: 'id', symbol: 'Rp ', decimalDigits: 0).format(discount['minimum'])}",
                                color: color,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 150,
                                    ),
                                    child: SwitchListTile(
                                      activeColor: Colors.blue,
                                      title: Text(
                                        isActive ? 'Aktif' : 'Tidak Aktif',
                                        textAlign: TextAlign.center,
                                      ),
                                      value: isActive,
                                      onChanged: (value) {
                                        changeActive(id, value);
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    splashRadius: 24,
                                    onPressed: () {
                                      _minimumController.text =
                                          discount['minimum'].toString();
                                      _valueController.text =
                                          discount['value'].toString();
                                      final formKey = GlobalKey<FormState>();
                                      Get.dialog(AlertDialog(
                                        title: const Text('Edit Diskon'),
                                        content: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Form(
                                            key: formKey,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Mohon isi semua field';
                                                    }
                                                    if (int.tryParse(value) ==
                                                        null) {
                                                      return 'Isi dengan angka!';
                                                    }
                                                    if (int.parse(value) < 0) {
                                                      return 'Nilai tidak boleh kurang dari 0';
                                                    }
                                                    return null;
                                                  },
                                                  controller:
                                                      _minimumController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Minimum Belanja',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16.0,
                                                ),
                                                TextFormField(
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Mohon isi semua field';
                                                    }
                                                    if (int.tryParse(value) ==
                                                        null) {
                                                      return 'Isi dengan angka!';
                                                    }
                                                    if (int.parse(value) < 0) {
                                                      return 'Nilai tidak boleh kurang dari 0';
                                                    }
                                                    return null;
                                                  },
                                                  controller: _valueController,
                                                  keyboardType:
                                                      TextInputType.number,
                                                  decoration:
                                                      const InputDecoration(
                                                    border:
                                                        OutlineInputBorder(),
                                                    labelText:
                                                        'Nominal Potongan (%)',
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 16.0,
                                                ),
                                                ElevatedButton(
                                                  onPressed: () async {
                                                    if (formKey.currentState!
                                                        .validate()) {
                                                      EasyLoading.show(
                                                          status: 'Loading...',
                                                          maskType:
                                                              EasyLoadingMaskType
                                                                  .black);
                                                      await FirebaseFirestore
                                                          .instance
                                                          .collection('coupons')
                                                          .doc(id)
                                                          .update({
                                                        'minimum': int.parse(
                                                            _minimumController
                                                                .text),
                                                        'value': int.parse(
                                                            _valueController
                                                                .text),
                                                      }).then((_) {
                                                        Navigator.pop(context);
                                                        EasyLoading.dismiss();
                                                        EasyLoading.showSuccess(
                                                            'Diskon berhasil diubah');
                                                      });
                                                    }
                                                  },
                                                  child: const Text('Ubah'),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ));
                                    },
                                    icon: const Icon(
                                      Icons.edit,
                                      size: 24.0,
                                    ),
                                  ),
                                  IconButton(
                                    splashRadius: 24,
                                    onPressed: () {
                                      _deleteCoupon(id, context);
                                    },
                                    icon: const Icon(
                                      Icons.delete,
                                      size: 24.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
