import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  File? _profileImage;

  final int maxFriends = 8;
  final List<String> _selectedFriends = [];

  // Mock friend data (usually fetched from backend)
  final List<Map<String, String>> mockFriends = List.generate(
    20,
    (i) => {
      "id": "$i",
      "name": "Friend $i",
      "image":
          "https://i.pravatar.cc/150?img=${(i % 70) + 1}", // Random profile images
    },
  );

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() => _profileImage = File(picked.path));
    }
  }

  void _toggleFriend(String id) {
    setState(() {
      if (_selectedFriends.contains(id)) {
        _selectedFriends.remove(id);
      } else if (_selectedFriends.length < maxFriends) {
        _selectedFriends.add(id);
      }
    });
  }

  void _submitProfile() {
    if (_nameController.text.isEmpty ||
        _bioController.text.isEmpty ||
        _profileImage == null ||
        _selectedFriends.length != maxFriends) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all fields")),
      );
      return;
    }

    // Proceed to next screen (graph screen)
    Navigator.pushNamed(context, '/graph'); // add this route later
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Create Your Profile",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Tell us who you are",
                  style: GoogleFonts.poppins(color: Colors.white70),
                ),

                const SizedBox(height: 24),
                Center(
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white10,
                      backgroundImage: _profileImage != null
                          ? FileImage(_profileImage!)
                          : null,
                      child: _profileImage == null
                          ? const Icon(
                              Icons.camera_alt,
                              size: 30,
                              color: Colors.white38,
                            )
                          : null,
                    ),
                  ),
                ),

                const SizedBox(height: 24),
                Text("Your Name", style: labelStyle()),
                TextField(
                  controller: _nameController,
                  style: textStyle(),
                  decoration: inputDecoration("Enter your name"),
                ),

                const SizedBox(height: 16),
                Text("Your Bio", style: labelStyle()),
                TextField(
                  controller: _bioController,
                  style: textStyle(),
                  maxLines: 3,
                  decoration: inputDecoration("Something about you"),
                ),

                const SizedBox(height: 24),
                Text("Choose your 8 close friends", style: labelStyle()),

                const SizedBox(height: 12),
                GridView.builder(
                  itemCount: mockFriends.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (context, index) {
                    final friend = mockFriends[index];
                    final isSelected = _selectedFriends.contains(friend["id"]);

                    return GestureDetector(
                      onTap: () => _toggleFriend(friend["id"]!),
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isSelected
                                    ? Colors.greenAccent
                                    : Colors.white24,
                                width: 2,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                friend["image"]!,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Positioned(
                              top: 4,
                              right: 4,
                              child: CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.greenAccent,
                                child: Icon(
                                  Icons.check,
                                  size: 14,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton(
                    onPressed: _submitProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      "Continue",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TextStyle labelStyle() =>
      GoogleFonts.poppins(fontSize: 16, color: Colors.white70);

  TextStyle textStyle() => const TextStyle(color: Colors.white);

  InputDecoration inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.white38),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white24),
      borderRadius: BorderRadius.circular(12),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white60),
      borderRadius: BorderRadius.circular(12),
    ),
    filled: true,
    fillColor: Colors.white10,
  );
}
