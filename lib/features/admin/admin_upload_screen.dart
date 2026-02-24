import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../core/constants/app_colors.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for Manual Input
  final _nameController = TextEditingController();
  final _brandController = TextEditingController();
  final _priceController = TextEditingController();
  final _descController = TextEditingController();
  final _compController = TextEditingController();
  final _careController = TextEditingController();
  final _colorsController = TextEditingController();

  String? _selectedCategory;
  File? _imageFile;
  bool _isUploading = false;

  final List<String> _allSizes = ["XS", "S", "M", "L", "XL", "XXL"];
  final List<String> _selectedSizes = [];

  // LOGIC 1: Upload to ImgBB (Generates the link automatically)
  Future<String?> _uploadToImgBB(File image) async {
    const apiKey = "fe047fb1f9776d956647f77f0f6b7090"; // Replace with your key from api.imgbb.com
    var request = http.MultipartRequest('POST', Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    var response = await request.send();
    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      var jsonData = jsonDecode(responseData);
      return jsonData['data']['url']; // Direct high-quality link
    }
    return null;
  }

  // LOGIC 2: Pick Image from Gallery/Camera
  Future<void> _showImageSourceOptions() async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt, color: AppColors.primaryRed),
            title: const Text("Take a Photo"),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
          ),
          ListTile(
            leading: const Icon(Icons.image, color: AppColors.primaryRed),
            title: const Text("Choose from Gallery"),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (img != null) setState(() => _imageFile = File(img.path));
  }

  // LOGIC 3: Full Automation Publish
  Future<void> _publishProduct() async {
    if (_selectedCategory == null) {
      _showMsg("Please select a category", isError: true);
      return;
    }

    if (!_formKey.currentState!.validate() || _imageFile == null) {
      _showMsg("Please fill all fields and select an image", isError: true);
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Get the automatic link from ImgBB
      String? generatedUrl = await _uploadToImgBB(_imageFile!);

      if (generatedUrl != null) {
        // 2. Generate Unique Unity ID
        String modelID = "${_nameController.text.trim()}_model".replaceAll(" ", "_").toLowerCase();

        // 3. Save to Firestore
        await FirebaseFirestore.instance.collection('products').doc(_nameController.text.trim()).set({
          'name': _nameController.text.trim(),
          'brand': _brandController.text.trim(),
          'price': double.parse(_priceController.text.trim()),
          'category': _selectedCategory,
          'imageUrl': generatedUrl,
          'unityModelUrl': "https://...", // Placeholder for your cloud asset
          'unityModelName': modelID,
          'description': _descController.text.trim(),
          'composition': _compController.text.trim(),
          'care': _careController.text.trim(),
          'availableSizes': _selectedSizes,
          'availableColors': _colorsController.text.split(',').map((e) => e.trim()).toList(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          Navigator.pop(context);
          _showMsg("Product is now LIVE!");
        }
      } else {
        _showMsg("Image upload failed. Check API Key.", isError: true);
      }
    } catch (e) {
      _showMsg("Error: $e", isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(backgroundColor: isError ? Colors.red : Colors.green, content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Add New Product"), centerTitle: true),
      body: _isUploading
          ? const Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [CircularProgressIndicator(), SizedBox(height: 20), Text("Uploading & Generating Links...")]))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _showImageSourceOptions,
                child: Container(
                  height: 200, width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
                  child: _imageFile == null
                      ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: AppColors.grey))
                      : ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(_imageFile!, fit: BoxFit.cover)),
                ),
              ),
              const SizedBox(height: 20),
              _section("Basic Information"),
              _input(_nameController, "Product Name"),
              _input(_brandController, "Brand"),
              _input(_priceController, "Price (Number)", isNum: true),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                hint: const Text("Select Category"),
                items: ["Women", "Men", "Kids"].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (v) => setState(() => _selectedCategory = v),
                validator: (v) => v == null ? "Required" : null,
              ),
              const SizedBox(height: 24),
              _section("Specifications"),
              _input(_descController, "Description", lines: 3),
              _input(_compController, "Composition"),
              _input(_careController, "Care Instructions"),
              _section("Inventory"),
              _input(_colorsController, "Colors (Red, Blue)"),
              const Text("Select Sizes:", style: TextStyle(fontWeight: FontWeight.bold)),
              Wrap(
                spacing: 8,
                children: _allSizes.map((size) {
                  final isSelected = _selectedSizes.contains(size);
                  return FilterChip(
                    label: Text(size), selected: isSelected, selectedColor: AppColors.primaryRed,
                    onSelected: (val) => setState(() => val ? _selectedSizes.add(size) : _selectedSizes.remove(size)),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
              SizedBox(width: double.infinity, child: ElevatedButton(onPressed: _publishProduct, child: const Text("PUBLISH PRODUCT"))),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String t) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryRed)));
  Widget _input(TextEditingController c, String l, {bool isNum = false, int lines = 1}) {
    return Padding(padding: const EdgeInsets.only(bottom: 12), child: TextFormField(controller: c, maxLines: lines, keyboardType: isNum ? TextInputType.number : TextInputType.text, validator: (v) => v!.isEmpty ? "Required" : null, decoration: InputDecoration(labelText: l, filled: true, fillColor: Colors.white)));
  }
}
