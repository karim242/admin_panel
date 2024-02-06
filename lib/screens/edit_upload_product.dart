import 'dart:io';

import 'package:admin_app/consts/app_constants.dart';
import 'package:admin_app/consts/my_validators.dart';
import 'package:admin_app/models/product_model.dart';
import 'package:admin_app/screens/loading_manager.dart';
import 'package:admin_app/services/my_app_method.dart';
import 'package:admin_app/widgets/custom_button.dart';
import 'package:admin_app/widgets/custom_text_form_field.dart';
import 'package:admin_app/widgets/subtitle_text.dart';
import 'package:admin_app/widgets/title_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class EditUploadProduct extends StatefulWidget {
  const EditUploadProduct({super.key, this.productModel});
  static const routeName = '/EditUploadProduct';
  final ProductModel? productModel;
  @override
  State<EditUploadProduct> createState() => _EditUploadProductState();
}

class _EditUploadProductState extends State<EditUploadProduct> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  bool isEditing = false;
  XFile? _pickedImage;
  String? _selectedCategory;
  String? productNetworkImage;
  bool _isLoading = false;
  String? productImageUrl;

  late TextEditingController _nameCtrlr,
      _descriptionCtrlr,
      _priceCtrlr,
      _qtyCtrlr;

  @override
  void initState() {
    if (widget.productModel != null) {
      isEditing = true;
      productNetworkImage = widget.productModel?.productImage;
      _selectedCategory = widget.productModel?.productCategory;
    }
    _nameCtrlr = TextEditingController(text: widget.productModel?.productTitle);
    _descriptionCtrlr =
        TextEditingController(text: widget.productModel?.productDescription);
    _priceCtrlr =
        TextEditingController(text: widget.productModel?.productPrice);
    _qtyCtrlr =
        TextEditingController(text: widget.productModel?.productQuantity);
    super.initState();
  }

  @override
  void dispose() {
    _nameCtrlr.dispose();
    _descriptionCtrlr.dispose();
    _priceCtrlr.dispose();
    _qtyCtrlr.dispose();
    super.dispose();
  }

  void clearForm() {
    _nameCtrlr.clear();
    _descriptionCtrlr.clear();
    _priceCtrlr.clear();
    _qtyCtrlr.clear();
    _selectedCategory = null;
    removeImage();
  }

  void removeImage() {
    setState(() {
      _pickedImage = null;
      productNetworkImage = null;
    });
  }

  Future<void> uploadProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Make sure to pick up an image",
        fct: () {},
      );
      return;
    }
    if (_selectedCategory == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Category is empty",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        final productID = const Uuid().v4();
        setState(() {
          _isLoading = true;
        });
        final ref = FirebaseStorage.instance
            .ref()
            .child("productsImages")
            .child('$productID.jpg');
        await ref.putFile(File(_pickedImage!.path));
        productImageUrl = await ref.getDownloadURL();

        await FirebaseFirestore.instance
            .collection("products")
            .doc(productID)
            .set({
          'productId': productID,
          'productTitle': _nameCtrlr.text,
          'productPrice': _priceCtrlr.text,
          'productImage': productImageUrl,
          'productCategory': _selectedCategory,
          'productDescription': _descriptionCtrlr.text,
          'productQuantity': _qtyCtrlr.text,
          'createdAt': Timestamp.now(),
        });
        Fluttertoast.showToast(
          msg: "Product has been added",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "An error has been occured ${error.message}",
            fct: () {},
          );
        });
      } catch (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "An error has been occured $error",
            fct: () {},
          );
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> editProduct() async {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (_pickedImage == null && productNetworkImage == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Please pick up an image",
        fct: () {},
      );

      return;
    }
    if (_selectedCategory == null) {
      MyAppMethods.showErrorORWarningDialog(
        context: context,
        subtitle: "Category is empty",
        fct: () {},
      );

      return;
    }
    if (isValid) {
      _formKey.currentState!.save();
      try {
        final productID = widget.productModel!.productId;
        setState(() {
          _isLoading = true;
        });
        if (_pickedImage != null) {
          final ref = FirebaseStorage.instance
              .ref()
              .child("productsImages")
              .child('$productID.jpg');
          await ref.putFile(File(_pickedImage!.path));
          productImageUrl = await ref.getDownloadURL();
        }

        await FirebaseFirestore.instance
            .collection("products")
            .doc(productID)
            .update({
          'productId': productID,
          'productTitle': _nameCtrlr.text,
          'productPrice': _priceCtrlr.text,
          'productImage': productImageUrl ?? productNetworkImage,
          'productCategory': _selectedCategory,
          'productDescription': _descriptionCtrlr.text,
          'productQuantity': _qtyCtrlr.text,
          'createdAt': widget.productModel!.createdAt,
        });
        Fluttertoast.showToast(
          msg: "Product has been added",
          toastLength: Toast.LENGTH_SHORT,
          textColor: Colors.white,
        );
        if (!mounted) return;
        await MyAppMethods.showErrorORWarningDialog(
          isError: false,
          context: context,
          subtitle: "Clear form?",
          fct: () {
            clearForm();
          },
        );
      } on FirebaseException catch (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "An error has been occured ${error.message}",
            fct: () {},
          );
        });
      } catch (error) {
        WidgetsBinding.instance.addPostFrameCallback((_) async {
          await MyAppMethods.showErrorORWarningDialog(
            context: context,
            subtitle: "An error has been occured $error",
            fct: () {},
          );
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future pickImage() async {
    final ImagePicker picker = ImagePicker();
    await MyAppMethods.imagePickerDialog(
        context: context,
        cameraFCT: () async {
          _pickedImage = await picker.pickImage(source: ImageSource.camera);
          setState(() {
            productNetworkImage = null;
          });
        },
        galleryFCT: () async {
          _pickedImage = await picker.pickImage(source: ImageSource.gallery);
          setState(() {
            productNetworkImage = null;
          });
        },
        removeFCT: () {
          removeImage();
          setState(() {});
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return LoadingManager(
      isLoading: _isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            centerTitle: true,
            title: const TitlesTextWidget(label: "Upload a new product"),
          ),
          bottomSheet: SizedBox(
              height: kBottomNavigationBarHeight + 10,
              child: Material(
                color: Theme.of(context).scaffoldBackgroundColor,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomButton(
                      label: "Clear",
                      color: Colors.white,
                      icon: Icons.clear,
                      function: () {
                        clearForm();
                      },
                    ),
                    const Gap(32),
                    CustomButton(
                      label: isEditing ? "Edit Product" : "Upload Product",
                      color: Colors.white,
                      icon: Icons.upload_file,
                      backgroundColor: Colors.blue,
                      function: () {
                        isEditing ? editProduct() : uploadProduct();
                      },
                    ),
                  ],
                ),
              )),
          body: SafeArea(
              child: SingleChildScrollView(
            child: Column(
              children: [
                const Gap(10),
                if (isEditing && productNetworkImage != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      productNetworkImage!,
                      height: size.width * 0.5,
                      alignment: Alignment.center,
                    ),
                  )
                ] else if (_pickedImage == null) ...[
                  SizedBox(
                    width: size.width * 0.4 + 10,
                    height: size.width * 0.4,
                    child: DottedBorder(
                        color: Colors.blue,
                        radius: const Radius.circular(12),
                        child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  size: 80,
                                  color: Colors.blue,
                                ),
                                TextButton(
                                  onPressed: () {
                                    pickImage();
                                  },
                                  child: const Text("Pick Product Image"),
                                )
                              ]),
                        )),
                  ),
                ] else ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(_pickedImage!.path),
                      height: size.width * 0.5,
                      alignment: Alignment.center,
                    ),
                  )
                ],
                if (_pickedImage != null || productNetworkImage != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: () {
                          pickImage();
                        },
                        child: const Text("Pick another image"),
                      ),
                      TextButton(
                        onPressed: () {
                          removeImage();
                        },
                        child: const Text(
                          "Remove image",
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  )
                ],
                const Gap(25),
                DropdownButton(
                    hint: const Text("Select  Category"),
                    value: _selectedCategory,
                    items: AppConstants.categoriesMenuItems,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    }),
                const Gap(25),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  child: Form(
                    key: _formKey,
                    child: Column(children: [
                      CustomTextFormField(
                        key: const ValueKey('Title'),
                        controller: _nameCtrlr,
                        hintText: "Product Title",
                        maxLength: 80,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        validator: (value) {
                          return MyValidators.uploadProdTexts(
                            value: value,
                            toBeReturnedString: "Please enter a valid title",
                          );
                        },
                      ),
                      const Gap(15),
                      Row(
                        children: [
                          Flexible(
                            child: CustomTextFormField(
                              key: const ValueKey('\$ Price '),
                              controller: _priceCtrlr,
                              hintText: "price",
                              prefix: const SubtitleTextWidget(
                                label: "\$ ",
                                color: Colors.blue,
                                fontSize: 16,
                              ),
                              validator: (value) {
                                return MyValidators.uploadProdTexts(
                                    value: value,
                                    toBeReturnedString: "Price is missing");
                              },
                              keyboardType: TextInputType.number,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^(\d+)?\.?\d{0,2}'),
                                ),
                              ],
                            ),
                          ),
                          const Gap(15),
                          Flexible(
                            child: CustomTextFormField(
                              key: const ValueKey('Quantity'),
                              controller: _qtyCtrlr,
                              hintText: "Qty :",
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                return MyValidators.uploadProdTexts(
                                  value: value,
                                  toBeReturnedString: "Quantity is missed",
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      const Gap(15),
                      CustomTextFormField(
                        key: const ValueKey('Description'),
                        controller: _descriptionCtrlr,
                        hintText: "Product description",
                        maxLength: 1000,
                        padding: 20,
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        validator: (value) {
                          return MyValidators.uploadProdTexts(
                            value: value,
                            toBeReturnedString: "Description is missed",
                          );
                        },
                      ),
                    ]),
                  ),
                ),
                SizedBox(
                  // ignore: deprecated_member_use
                  height: WidgetsBinding.instance.window.viewInsets.bottom > 0.0
                      ? 10
                      : kBottomNavigationBarHeight + 10,
                ),
              ],
            ),
          )),
        ),
      ),
    );
  }
}
