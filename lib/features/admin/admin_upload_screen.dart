import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../data/services/seed_service.dart';
import '../../data/services/storage_service.dart';
import '../../core/constants/app_colors.dart';

class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

class _AdminUploadScreenState extends State<AdminUploadScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController      = TextEditingController();
  final _brandController     = TextEditingController();
  final _priceController     = TextEditingController();
  final _descController      = TextEditingController();
  final _compController      = TextEditingController();
  final _careController      = TextEditingController();
  final _colorsController    = TextEditingController();

  String? _selectedCategory;
  File?   _imageFile;
  File?   _glbFile;
  String? _glbFileName;
  double  _glbUploadProgress = 0;
  bool    _isUploading = false;
  String  _uploadStatus = '';

  final List<String> _allSizes      = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _selectedSizes = [];

  // ── Image upload (ImgBB) ──────────────────────────────────────────────────

  Future<String?> _uploadToImgBB(File image) async {
    const apiKey = 'fe047fb1f9776d956647f77f0f6b7090';
    final request = http.MultipartRequest(
        'POST', Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'));
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    final response = await request.send();
    if (response.statusCode == 200) {
      final data = jsonDecode(await response.stream.bytesToString());
      return data['data']['url'] as String?;
    }
    return null;
  }

  Future<void> _pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (img != null) setState(() => _imageFile = File(img.path));
  }

  // ── GLB file picker ───────────────────────────────────────────────────────

  Future<void> _pickGlbFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // GLB not in standard types, allow any
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final name = result.files.single.name;
      if (!name.toLowerCase().endsWith('.glb') &&
          !name.toLowerCase().endsWith('.gltf')) {
        _showMsg('Please select a .glb or .gltf file', isError: true);
        return;
      }
      setState(() {
        _glbFile = file;
        _glbFileName = name;
        _glbUploadProgress = 0;
      });
    }
  }

  // ── Publish ───────────────────────────────────────────────────────────────

  Future<void> _publishProduct() async {
    if (_selectedCategory == null) {
      _showMsg('Please select a category', isError: true); return;
    }
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      _showMsg('Please fill all fields and select an image', isError: true); return;
    }

    setState(() { _isUploading = true; _uploadStatus = 'Uploading product image...'; });

    try {
      // 1. Upload product image to ImgBB
      final imageUrl = await _uploadToImgBB(_imageFile!);
      if (imageUrl == null) { _showMsg('Image upload failed', isError: true); return; }

      // 2. Upload .glb model to Firebase Storage (if provided)
      String glbUrl = '';
      if (_glbFile != null) {
        setState(() => _uploadStatus = 'Uploading 3D model...');
        glbUrl = await StorageService().uploadGlbModel(
          _glbFile!.path,
          _nameController.text.trim(),
          onProgress: (p) => setState(() => _glbUploadProgress = p),
        ) ?? '';
      }

      // 3. Save to Firestore
      setState(() => _uploadStatus = 'Saving to database...');
      await FirebaseFirestore.instance
          .collection('products')
          .doc(_nameController.text.trim())
          .set({
        'name':            _nameController.text.trim(),
        'brand':           _brandController.text.trim(),
        'price':           double.parse(_priceController.text.trim()),
        'category':        _selectedCategory,
        'imageUrl':        imageUrl,
        'unityModelUrl':   glbUrl, // ← Real Firebase Storage URL
        'description':     _descController.text.trim(),
        'composition':     _compController.text.trim(),
        'care':            _careController.text.trim(),
        'availableSizes':  _selectedSizes,
        'availableColors': _colorsController.text.split(',').map((e) => e.trim()).toList(),
        'createdAt':       FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context);
        _showMsg('Product is now LIVE!');
      }
    } catch (e) {
      _showMsg('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      content: Text(msg),
    ));
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Add New Product'), centerTitle: true),
      body: _isUploading
          ? Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const CircularProgressIndicator(color: AppColors.primaryRed),
                const SizedBox(height: 20),
                Text(_uploadStatus, style: const TextStyle(fontSize: 16)),
                if (_glbUploadProgress > 0) ...[
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: LinearProgressIndicator(
                      value: _glbUploadProgress,
                      color: AppColors.primaryRed,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('${(_glbUploadProgress * 100).toStringAsFixed(0)}%'),
                ],
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => setState(() => _isUploading = false),
                  child: const Text('CANCEL'),
                ),
              ]),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Seed data
                    Center(
                      child: TextButton.icon(
                        onPressed: () async {
                          setState(() => _isUploading = true);
                          try {
                            await SeedService.seedProducts().timeout(const Duration(seconds: 20));
                            _showMsg('Sample products added!');
                          } catch (e) {
                            _showMsg('Failed: $e', isError: true);
                          } finally {
                            setState(() => _isUploading = false);
                          }
                        },
                        icon: const Icon(Icons.auto_fix_high),
                        label: const Text('SEED SAMPLE DATA'),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Product image
                    GestureDetector(
                      onTap: () => showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                        builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
                          ListTile(
                            leading: const Icon(Icons.camera_alt, color: AppColors.primaryRed),
                            title: const Text('Take a Photo'),
                            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
                          ),
                          ListTile(
                            leading: const Icon(Icons.image, color: AppColors.primaryRed),
                            title: const Text('Choose from Gallery'),
                            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
                          ),
                          const SizedBox(height: 10),
                        ]),
                      ),
                      child: Container(
                        height: 200, width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: _imageFile == null
                            ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: AppColors.grey))
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // GLB model picker
                    _section('3D Model (.glb)'),
                    GestureDetector(
                      onTap: _pickGlbFile,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _glbFile != null ? AppColors.primaryRed : Colors.grey.shade300,
                            width: _glbFile != null ? 2 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Icon(
                            _glbFile != null ? Icons.check_circle : Icons.upload_file,
                            color: _glbFile != null ? AppColors.primaryRed : AppColors.grey,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _glbFile != null
                                  ? '✅ $_glbFileName'
                                  : 'Tap to select .glb clothing model\n(Optional — can be added later)',
                              style: TextStyle(
                                color: _glbFile != null ? AppColors.primaryRed : AppColors.grey,
                                fontWeight: _glbFile != null ? FontWeight.bold : FontWeight.normal,
                              ),
                            ),
                          ),
                        ]),
                      ),
                    ),

                    const SizedBox(height: 20),
                    _section('Basic Information'),
                    _input(_nameController, 'Product Name'),
                    _input(_brandController, 'Brand'),
                    _input(_priceController, 'Price (₹)', isNum: true),
                    DropdownButtonFormField<String>(
                      initialValue: _selectedCategory,
                      hint: const Text('Select Category'),
                      items: ['Women', 'Men', 'Kids']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCategory = v),
                      validator: (v) => v == null ? 'Required' : null,
                    ),
                    const SizedBox(height: 24),
                    _section('Specifications'),
                    _input(_descController, 'Description', lines: 3),
                    _input(_compController, 'Composition'),
                    _input(_careController, 'Care Instructions'),
                    _section('Inventory'),
                    _input(_colorsController, 'Colors (Red, Blue)'),
                    const Text('Select Sizes:', style: TextStyle(fontWeight: FontWeight.bold)),
                    Wrap(
                      spacing: 8,
                      children: _allSizes.map((size) {
                        final isSelected = _selectedSizes.contains(size);
                        return FilterChip(
                          label: Text(size),
                          selected: isSelected,
                          selectedColor: AppColors.primaryRed,
                          onSelected: (val) => setState(
                              () => val ? _selectedSizes.add(size) : _selectedSizes.remove(size)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _publishProduct,
                        child: const Text('PUBLISH PRODUCT'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _section(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
      );

  Widget _input(TextEditingController c, String l, {bool isNum = false, int lines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c, maxLines: lines,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        validator: (v) => v!.isEmpty ? 'Required' : null,
        decoration: InputDecoration(labelText: l, filled: true, fillColor: Colors.white),
      ),
    );
  }
}
