import 'dart:convert'; // Used to convert JSON data (API response)
import 'dart:io'; // Used for file handling (image + GLB files)

import 'package:flutter/material.dart'; // Flutter UI toolkit
import 'package:cloud_firestore/cloud_firestore.dart'; // Firebase database
import 'package:file_picker/file_picker.dart'; // Pick files from device
import 'package:image_picker/image_picker.dart'; // Pick images (camera/gallery)
import 'package:http/http.dart' as http; // HTTP requests (for ImgBB upload)

import '../../data/services/seed_service.dart'; // For inserting dummy products
import '../../data/services/storage_service.dart'; // For uploading GLB models
import '../../core/constants/app_colors.dart'; // App color constants

// Main screen widget
class AdminUploadScreen extends StatefulWidget {
  const AdminUploadScreen({super.key});

  @override
  State<AdminUploadScreen> createState() => _AdminUploadScreenState();
}

// State class (logic + UI)
class _AdminUploadScreenState extends State<AdminUploadScreen> {

  final _formKey = GlobalKey<FormState>(); // Used for form validation

  // Controllers to read text input
  final _nameController      = TextEditingController();
  final _brandController     = TextEditingController();
  final _priceController     = TextEditingController();
  final _descController      = TextEditingController();
  final _compController      = TextEditingController();
  final _careController      = TextEditingController();
  final _colorsController    = TextEditingController();

  String? _selectedCategory; // Selected category
  File?   _imageFile; // Selected product image
  File?   _glbFile; // Selected 3D model file
  String? _glbFileName; // Name of GLB file
  double  _glbUploadProgress = 0; // Upload progress (0–1)
  bool    _isUploading = false; // Loading flag
  String  _uploadStatus = ''; // Status message

  // Available sizes
  final List<String> _allSizes      = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> _selectedSizes = []; // Selected sizes

  // IMAGE UPLOAD FUNCTION
  Future<String?> _uploadToImgBB(File image) async {
    const apiKey = 'fe047fb1f9776d956647f77f0f6b7090'; // ImgBB API key
    
    final request = http.MultipartRequest(
        'POST', Uri.parse('https://api.imgbb.com/1/upload?key=$apiKey'));
    // Create POST request
    
    request.files.add(await http.MultipartFile.fromPath('image', image.path));
    // Attach image file
    
    final response = await request.send(); // Send request
    
    if (response.statusCode == 200) {
      final data = jsonDecode(await response.stream.bytesToString());
      // Convert response to JSON

      return data['data']['url'] as String?; // Return uploaded image URL
    }
    
    return null; // Return null if failed
  }

  // PICK IMAGE
  Future<void> _pickImage(ImageSource source) async {
    final img = await ImagePicker().pickImage(source: source, imageQuality: 80);
    // Pick image from camera/gallery

    if (img != null) setState(() => _imageFile = File(img.path));
    // Save image in state
  }

  // PICK GLB FILE (3D MODEL)
  Future<void> _pickGlbFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any, // Allow all file types
      allowMultiple: false,
    );
    
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final name = result.files.single.name;
      
      // Validate extension
      if (!name.toLowerCase().endsWith('.glb') &&
          !name.toLowerCase().endsWith('.gltf')) {
        _showMsg('Please select a .glb or .gltf file', isError: true);
        return;
      }
      
      setState(() {
        _glbFile = file; // Save file
        _glbFileName = name; // Save name
        _glbUploadProgress = 0; // Reset progress
      });
    }
  }

  // MAIN UPLOAD FUNCTION
  Future<void> _publishProduct() async 
  {
    // Check category
    if (_selectedCategory == null) {
      _showMsg('Please select a category', isError: true); return;
    }
    
    // Validate form + image
    if (!_formKey.currentState!.validate() || _imageFile == null) {
      _showMsg('Please fill all fields and select an image', isError: true); return;
    }
    
    // Start uploading
    setState(() { 
      _isUploading = true; 
      _uploadStatus = 'Uploading product image...'; 
    });

    try {
      // STEP 1: Upload image
      final imageUrl = await _uploadToImgBB(_imageFile!);

      if (imageUrl == null) { 
        _showMsg('Image upload failed', isError: true); 
        return; 
      }

      // STEP 2: Upload 3D model
      String glbUrl = '';
      if (_glbFile != null) {
        setState(() => _uploadStatus = 'Uploading 3D model...');

        glbUrl = await StorageService().uploadGlbModel(
          _glbFile!.path,
          _nameController.text.trim(),
          onProgress: (p) => setState(() => _glbUploadProgress = p),
        ) ?

      // STEP 3: Save product in Firestore
      setState(() => _uploadStatus = 'Saving to database...');

      await FirebaseFirestore.instance
          .collection('products')
          .doc(_nameController.text.trim())
          .set({
        'name': _nameController.text.trim(),
        'brand': _brandController.text.trim(),
        'price': double.parse(_priceController.text.trim()),
        'category': _selectedCategory,
        'imageUrl': imageUrl,
        'unityModelUrl': glbUrl, // Used in AR
        'description': _descController.text.trim(),
        'composition': _compController.text.trim(),
        'care': _careController.text.trim(),
        'availableSizes': _selectedSizes,
        'availableColors': _colorsController.text.split(',').map((e) => e.trim()).toList(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.pop(context); // Go back
        _showMsg('Product is now LIVE!'); // Success message
      }

    } catch (e) {
      _showMsg('Error: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  // SHOW MESSAGE (SNACKBAR)
  void _showMsg(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: isError ? Colors.red : Colors.green,
      content: Text(msg),
    ));
  }

// ───────── UI BUILD ─────────

// This function builds the UI of the screen
@override
Widget build(BuildContext context) {
  return Scaffold( // Main layout structure (like base screen)
    backgroundColor: AppColors.background, // Set background color of screen

    appBar: AppBar( // Top bar of the screen
      title: const Text('Add New Product'), // Title shown in app bar
      centerTitle: true, // Center the title text
    ),
    
    // If uploading → show loader screen
    body: _isUploading
        ? Center( // Center everything on screen
            child: Column( // Arrange items vertically
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              children: [

                const CircularProgressIndicator(color: AppColors.primaryRed), // Loading spinner

                const SizedBox(height: 20), // Space

                Text(_uploadStatus, style: const TextStyle(fontSize: 16)), // Show current upload message

                // Show GLB upload progress if model is uploading
                if (_glbUploadProgress > 0) ...[
                  const SizedBox(height: 16), // Space
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40), // Horizontal padding
                    child: LinearProgressIndicator(
                      value: _glbUploadProgress, // Progress value (0 to 1)
                      color: AppColors.primaryRed, // Progress bar color
                    ),
                  ),
                  const SizedBox(height: 8), // Space
                  Text('${(_glbUploadProgress * 100).toStringAsFixed(0)}%'), // Show percentage
              ],
              const SizedBox(height: 16), // Space
              ElevatedButton(
                onPressed: () => setState(() => _isUploading = false), // Cancel upload (stop loader)
                child: const Text('CANCEL'), // Button text
              ),
            ]),
          )

        // If NOT uploading → show form UI
        : SingleChildScrollView( // Makes screen scrollable
            padding: const EdgeInsets.all(16), // Padding around content
            child: Form( // Form to validate inputs
              key: _formKey, // Form key for validation
              child: Column( // Arrange items vertically
                crossAxisAlignment: CrossAxisAlignment.start, // Align items to left
                children: [
                  // Seed data button (add dummy products)
                  Center(
                    child: TextButton.icon(
                      onPressed: () async { // When clicked
                        setState(() => _isUploading = true); // Show loader
                        try {
                          await SeedService.seedProducts().timeout(const Duration(seconds: 20)); // Add sample data
                          _showMsg('Sample products added!'); // Success message
                        } catch (e) {
                          _showMsg('Failed: $e', isError: true); // Error message
                        } finally {
                          setState(() => _isUploading = false); // Stop loader
                        }
                      },
                      icon: const Icon(Icons.auto_fix_high), // Icon
                      label: const Text('SEED SAMPLE DATA'), // Button text
                    ),
                  ),
                  const SizedBox(height: 20), // Space

                  // Product image selection area
                  GestureDetector(
                    onTap: () => showModalBottomSheet( // Open bottom sheet when tapped
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20))), // Rounded top
                      builder: (_) => Column(mainAxisSize: MainAxisSize.min, children: [
                        ListTile(
                          leading: const Icon(Icons.camera_alt, color: AppColors.primaryRed), // Camera icon
                          title: const Text('Take a Photo'), // Option text
                          onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); }, // Open camera
                        ),
                        ListTile(
                          leading: const Icon(Icons.image, color: AppColors.primaryRed), // Gallery icon
                          title: const Text('Choose from Gallery'), // Option text
                          onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); }, // Open gallery
                        ),
                        const SizedBox(height: 10), // Space
                      ]),
                    ),
                    child: Container( // Image box UI
                      height: 200, width: double.infinity, // Size
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color
                        borderRadius: BorderRadius.circular(12), // Rounded corners
                        border: Border.all(color: Colors.grey.shade300), // Border
                      ),
                      child: _imageFile == null
                          ? const Center(child: Icon(Icons.add_a_photo, size: 40, color: AppColors.grey)) // Show icon if no image
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(12), // Rounded image
                              child: Image.file(_imageFile!, fit: BoxFit.cover), // Show selected image
                            ),
                    ),
                  ),

                  const SizedBox(height: 16), // Space

                  // GLB model section title
                  _section('3D Model (.glb)'),

                  // GLB file picker
                  GestureDetector(
                    onTap: _pickGlbFile, // Open file picker
                    child: Container(
                      padding: const EdgeInsets.all(16), // Padding
                      decoration: BoxDecoration(
                        color: Colors.white, // Background
                        borderRadius: BorderRadius.circular(12), // Rounded
                        border: Border.all(
                          color: _glbFile != null ? AppColors.primaryRed : Colors.grey.shade300, // Border color depends on selection
                          width: _glbFile != null ? 2 : 1, // Border thickness
                        ),
                      ),
                      child: Row(children: [
                        Icon(
                          _glbFile != null ? Icons.check_circle : Icons.upload_file, // Icon based on selection
                          color: _glbFile != null ? AppColors.primaryRed : AppColors.grey,
                          size: 32,
                        ),
                        const SizedBox(width: 12), // Space
                        Expanded(
                          child: Text(
                            _glbFile != null
                                ? '✅ $_glbFileName' // Show selected file name
                                : 'Tap to select .glb clothing model\n(Optional — can be added later)', // Instruction text
                            style: TextStyle(
                              color: _glbFile != null ? AppColors.primaryRed : AppColors.grey,
                              fontWeight: _glbFile != null ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),

                  const SizedBox(height: 20), // Space

                  // Basic info section
                  _section('Basic Information'),
                  _input(_nameController, 'Product Name'), // Name input
                  _input(_brandController, 'Brand'), // Brand input
                  _input(_priceController, 'Price (₹)', isNum: true), // Price input

                  // Category dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory, // Current selected value
                    hint: const Text('Select Category'), // Hint text
                    items: ['Women', 'Men', 'Kids']
                        .map((s) => DropdownMenuItem(value: s, child: Text(s))) // Create dropdown items
                        .toList(),
                    onChanged: (v) => setState(() => _selectedCategory = v), // Update selected category
                    validator: (v) => v == null ? 'Required' : null, // Validation
                  ),

                  const SizedBox(height: 24), // Space

                  // Specifications section
                  _section('Specifications'),
                  _input(_descController, 'Description', lines: 3), // Description input
                  _input(_compController, 'Composition'), // Composition input
                  _input(_careController, 'Care Instructions'), // Care input

                  // Inventory section
                  _section('Inventory'),
                  _input(_colorsController, 'Colors (Red, Blue)'), // Colors input

                  const Text('Select Sizes:', style: TextStyle(fontWeight: FontWeight.bold)), // Label

                  // Size selection chips
                  Wrap(
                    spacing: 8, // Space between chips
                    children: _allSizes.map((size) {
                      final isSelected = _selectedSizes.contains(size); // Check if selected
                      return FilterChip(
                        label: Text(size), // Size label
                        selected: isSelected, // Selected state
                        selectedColor: AppColors.primaryRed, // Selected color
                        onSelected: (val) => setState(
                            () => val ? _selectedSizes.add(size) : _selectedSizes.remove(size)), // Add/remove size
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 40), // Space

                  // Submit button
                  SizedBox(
                    width: double.infinity, // Full width button
                    child: ElevatedButton(
                      onPressed: _publishProduct, // Call publish function
                      child: const Text('PUBLISH PRODUCT'), // Button text
                    ),
                  ),

                  const SizedBox(height: 20), // Space
                ],
              ),
            ),
          ),
  );
}

// Section title widget
Widget _section(String t) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8), // Spacing
      child: Text(t, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryRed)), // Styled text
    );

// Input field widget
Widget _input(TextEditingController c, String l, {bool isNum = false, int lines = 1}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 12), // Space below field
    child: TextFormField(
      controller: c, // Controller to get input value
      maxLines: lines, // Number of lines
      keyboardType: isNum ? TextInputType.number : TextInputType.text, // Keyboard type
      validator: (v) => v!.isEmpty ? 'Required' : null, // Validation rule
      decoration: InputDecoration(
        labelText: l, // Label text
        filled: true, // Background fill
        fillColor: Colors.white, // Fill color
      ),
    ),
  );
}
