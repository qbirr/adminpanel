import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iconly/iconly.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:useradmin/screen/loading_manager.dart';
import 'package:uuid/uuid.dart';
// import 'package:firebase/firebase.dart' as fb;

import '../controllers/menuscontrollers.dart';
import '../responsive.dart';
import '../services/global_method.dart';
import '../services/utils.dart';
import '../widgets/button.dart';
import '../widgets/header.dart';
import '../widgets/side_menu.dart';
import '../widgets/text_widgets.dart';

class UploadProductForm extends StatefulWidget {
  static const routeName = '/UploadProductForm';

  const UploadProductForm({Key? key}) : super(key: key);

  @override
  _UploadProductFormState createState() => _UploadProductFormState();
}

class _UploadProductFormState extends State<UploadProductForm> {
  final _formKey = GlobalKey<FormState>();
  String _catValue = "Sayuran";
  late final TextEditingController _titleController, _priceController;
  int _groupValue = 1;
  bool isPiece = false;
  File? _pickedImage;
  Uint8List webImage = Uint8List(8);
  @override
  void initState() {
    _priceController = TextEditingController();
    _titleController = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _priceController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  void _uploadForm() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    String? imageUrl;
    if (isValid) {
      _formKey.currentState!.save();
      if (_pickedImage == null) {
        GlobalMethods.errorDialog(
            subtitle: 'Please pick up an image', context: context);
        return;
      }
      final uuid = const Uuid().v4();

      try {
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child('userImages')
            .child('$uuid.jpg');
        if (kIsWeb) {
          await ref.putData(webImage);
        } else {
          await ref.putFile(_pickedImage!);
        }
        imageUrl = await ref.getDownloadURL();

        ///fb.StorageReference storageRef = fb.storage().ref().child("productImages").child(_uuid + 'jpg');
        ///final fb.UploadTaskSnapshot uploadTaskSnapshot = await storageRef.put(kIsWeb ? webImage : _pickedImage).future;
        ///Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('products').doc(uuid).set({
          'id': uuid,
          'title': _titleController.text,
          'price': _priceController.text,
          'salePrice': 0.1,
          'imageUrl': imageUrl,
          'productCategoryName': _catValue,
          'isOnSale': false,
          'isPiece': isPiece,
          'createdAt': Timestamp.now(),
        });
        clearForm();
        Fluttertoast.showToast(
            msg: "Produk Berhasil Ditambahkan",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1);
        print('Succefully registered');
      } on FirebaseException catch (error) {
        GlobalMethods.errorDialog(
            subtitle: '${error.message}', context: context);
        setState(() {
          _isLoading = false;
        });
      } catch (error) {
        GlobalMethods.errorDialog(subtitle: '$error', context: context);
        setState(() {
          _isLoading = false;
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void clearForm() {
    isPiece = false;
    _groupValue = 1;
    _priceController.clear();
    _titleController.clear();
    setState(() {
      _pickedImage = null;
      webImage = Uint8List(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Utils(context).getTheme;
    final color = Utils(context).color;
    final scaffoldColor = Theme.of(context).scaffoldBackgroundColor;
    Size size = Utils(context).getScreenSize;

    var inputDecoration = InputDecoration(
      filled: true,
      fillColor: scaffoldColor,
      border: InputBorder.none,
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1.0,
        ),
      ),
    );
    return Scaffold(
        key: context.read<MenuController1>().getAddProductscaffoldKey,
        drawer: const SideMenu(),
        body: LoadingManager(
          isLoading: _isLoading,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (Responsive.isDesktop(context))
                const Expanded(
                  child: SideMenu(),
                ),
              Expanded(
                flex: 5,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Header(
                            fct: () {
                              context
                                  .read<MenuController1>()
                                  .controlAddProductsMenu();
                            },
                            title: "Tambahkan Produk",
                            showTextField: false),
                      ),
                      const SizedBox(
                        height: 25,
                      ),
                      Container(
                        width: size.width > 650 ? 650 : size.width,
                        color: Theme.of(context).cardColor,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.all(16),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              TextWidget(
                                text: 'Nama Produk*',
                                color: color,
                                isTitle: true,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              TextFormField(
                                controller: _titleController,
                                key: const ValueKey('Title'),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter a Title';
                                  }
                                  return null;
                                },
                                decoration: inputDecoration,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: FittedBox(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          TextWidget(
                                            text: 'Harga Rp*',
                                            color: color,
                                            isTitle: true,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: TextFormField(
                                              controller: _priceController,
                                              key: const ValueKey('Price \$'),
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) {
                                                if (value!.isEmpty) {
                                                  return 'Price is missed';
                                                }
                                                return null;
                                              },
                                              inputFormatters: <TextInputFormatter>[
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(r'[0-9.]')),
                                              ],
                                              decoration: inputDecoration,
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          TextWidget(
                                            text: 'Kategori Produk*',
                                            color: color,
                                            isTitle: true,
                                          ),
                                          const SizedBox(height: 10),
                                          // Drop down menu code here,
                                          Container(
                                              color: scaffoldColor,
                                              child: _categoryDropDown()),
                                          const SizedBox(
                                            height: 20,
                                          ),
                                          TextWidget(
                                            text: 'Satuan Ukur*',
                                            color: color,
                                            isTitle: true,
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            children: [
                                              TextWidget(
                                                text: 'kg',
                                                color: color,
                                              ),
                                              Radio(
                                                value: 1,
                                                groupValue: _groupValue,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _groupValue = 1;
                                                    isPiece = false;
                                                  });
                                                },
                                                activeColor: Colors.green,
                                              ),
                                              TextWidget(
                                                text: 'harga',
                                                color: color,
                                              ),
                                              Radio(
                                                value: 2,
                                                groupValue: _groupValue,
                                                onChanged: (value) {
                                                  setState(() {
                                                    _groupValue = 2;
                                                    isPiece = true;
                                                  });
                                                },
                                                activeColor: Colors.green,
                                              )
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Image to be picked code is here
                                  Expanded(
                                      flex: 4,
                                      child: Container(
                                          height: size.width > 650
                                              ? 350
                                              : size.width * 0.45,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(12.0),
                                            color: Theme.of(context)
                                                .scaffoldBackgroundColor,
                                          ),
                                          child: _pickedImage == null
                                              ? dottedBorder(color: color)
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  child: kIsWeb
                                                      ? Image.memory(
                                                          webImage,
                                                          fit: BoxFit.fill,
                                                        )
                                                      : Image.file(
                                                          _pickedImage!,
                                                          fit: BoxFit.fill,
                                                        ),
                                                ))),
                                  Expanded(
                                      flex: 1,
                                      child: FittedBox(
                                        child: Column(
                                          children: [
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  _pickedImage = null;
                                                  webImage = Uint8List(8);
                                                });
                                              },
                                              child: TextWidget(
                                                text: 'Clear',
                                                color: Colors.red,
                                              ),
                                            ),
                                            TextButton(
                                              onPressed: () {},
                                              child: TextWidget(
                                                text: 'Update image',
                                                color: Colors.blue,
                                              ),
                                            ),
                                          ],
                                        ),
                                      )),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    ButtonsWidget(
                                      onPressed: () {
                                        clearForm();
                                      },
                                      text: 'Clear form',
                                      icon: IconlyBold.danger,
                                      backgroundColor: Colors.red.shade300,
                                    ),
                                    ButtonsWidget(
                                      onPressed: () {
                                        _uploadForm();
                                      },
                                      text: 'Upload',
                                      icon: IconlyBold.upload,
                                      backgroundColor: Colors.blue,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }

  Future<void> _pickImage() async {
    if (!kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var selected = File(image.path);
        setState(() {
          _pickedImage = selected;
        });
      } else {
        print('No image has been picked');
      }
    } else if (kIsWeb) {
      final ImagePicker picker = ImagePicker();
      XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        var f = await image.readAsBytes();
        setState(() {
          webImage = f;
          _pickedImage = File('a');
        });
      } else {
        print('No image has been picked');
      }
    } else {
      print('Something went wrong');
    }
  }

  Widget dottedBorder({
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: DottedBorder(
          dashPattern: const [6.7],
          borderType: BorderType.RRect,
          color: color,
          radius: const Radius.circular(12),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_outlined,
                  color: color,
                  size: 50,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextButton(
                    onPressed: (() {
                      _pickImage();
                    }),
                    child: TextWidget(
                      text: 'Pilih Gambar',
                      color: Colors.blue,
                    ))
              ],
            ),
          )),
    );
  }

  Widget _categoryDropDown() {
    return DropdownButtonHideUnderline(
        child: DropdownButton<String>(
      value: _catValue,
      onChanged: (value) {
        setState(() {
          _catValue = value!;
        });
        print(_catValue);
      },
      hint: const Text("Pilih Kategori Produk"),
      items: const [
        DropdownMenuItem(
          value: "Sayuran",
          child: Text("Sayuran"),
        ),
        DropdownMenuItem(
          value: "Buah-buahan",
          child: Text("Buah-buahan"),
        ),
        DropdownMenuItem(
          value: "Biji-bijian",
          child: Text("Biji-bijian"),
        ),
        DropdownMenuItem(
          value: "Kacangan",
          child: Text("Kacang-kacangan"),
        ),
        DropdownMenuItem(
          value: "Herbal",
          child: Text("Herbal"),
        ),
        DropdownMenuItem(
          value: "Rempah-rempah",
          child: Text("Rempah-rempah"),
        )
      ],
    ));
  }
}
