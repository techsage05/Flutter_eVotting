import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/storage_service.dart';
import 'admin_dashboard.dart';
import 'voter_dashboard.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isSignIn = true; // true = Sign In, false = Register
  bool showOtpScreen = false;
  String generatedOtp = '';
  int secondsRemaining = 30;
  Timer? resendTimer;

  // Controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController aadharController = TextEditingController();
  final TextEditingController voterIdController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  
  String selectedCity = "Vadodara";
  String selectedRole = "voter";

  final List<String> cities = ["Vadodara", "Ahmedabad", "Surat"];

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    aadharController.dispose();
    voterIdController.dispose();
    otpController.dispose();
    resendTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    secondsRemaining = 30;
    resendTimer?.cancel();
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (secondsRemaining > 0) {
          secondsRemaining--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  // Trigger Simulated OTP
  void triggerOtp(String mobileNumber) {
    // Generate a 6 digit random-like code
    generatedOtp = "123456"; // Standard OTP for easy testing
    startTimer();
    
    setState(() {
      showOtpScreen = true;
    });

    // Display standard overlay with simulated SMS to User
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.sms, color: Colors.amber),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "[SMS Simulation] Code for eVotting is: $generatedOtp",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A2980),
          duration: const Duration(seconds: 8),
          action: SnackBarAction(
            label: "AUTO-FILL",
            textColor: Colors.tealAccent,
            onPressed: () {
              otpController.text = generatedOtp;
            },
          ),
        ),
      );
    });
  }

  // ── AUTH ACTIONS ───────────────────────────────────────────────────────────
  void handleSendOtp() async {
    final mobile = mobileController.text.trim();
    
    if (mobile.length != 10 || double.tryParse(mobile) == null) {
      showSnackBar("Please enter a valid 10-digit mobile number", Colors.redAccent);
      return;
    }

    if (isSignIn) {
      // Sign In Flow: verify if user already exists
      final user = await StorageService.getUserByMobile(mobile);
      if (user == null) {
        showSnackBar("Mobile number is not registered. Please Register first.", Colors.orangeAccent);
        return;
      }
      triggerOtp(mobile);
    } else {
      // Registration Flow: validate fields
      final name = nameController.text.trim();
      final aadhar = aadharController.text.trim();
      final voterId = voterIdController.text.trim();

      if (name.isEmpty) {
        showSnackBar("Please enter your name", Colors.redAccent);
        return;
      }
      if (aadhar.length != 12 || double.tryParse(aadhar) == null) {
        showSnackBar("Please enter a valid 12-digit Aadhar Number", Colors.redAccent);
        return;
      }
      if (voterId.isEmpty || voterId.length < 5) {
        showSnackBar("Please enter a valid Voter ID number", Colors.redAccent);
        return;
      }

      // Check if user already exists
      final existingUser = await StorageService.getUserByMobile(mobile);
      if (existingUser != null) {
        showSnackBar("Mobile number already registered. Please Sign In.", Colors.orangeAccent);
        return;
      }

      triggerOtp(mobile);
    }
  }

  void handleVerifyOtp() async {
    final enteredOtp = otpController.text.trim();
    if (enteredOtp != generatedOtp) {
      showSnackBar("Invalid OTP. Please enter the simulated code '123456'.", Colors.redAccent);
      return;
    }

    resendTimer?.cancel();
    final mobile = mobileController.text.trim();

    if (isSignIn) {
      // Sign In Verification
      final user = await StorageService.getUserByMobile(mobile);
      if (user != null) {
        await StorageService.setCurrentUser(user);
        showSnackBar("Logged in successfully as ${user.name}!", Colors.green);
        navigateToDashboard(user);
      }
    } else {
      // Registration Verification
      final newUser = UserModel(
        name: nameController.text.trim(),
        mobile: mobile,
        voterId: voterIdController.text.trim().toUpperCase(),
        aadharNumber: aadharController.text.trim(),
        city: selectedCity,
        role: selectedRole,
      );

      final success = await StorageService.registerUser(newUser);
      if (success) {
        await StorageService.setCurrentUser(newUser);
        showSnackBar("Registration complete & verified!", Colors.green);
        navigateToDashboard(newUser);
      } else {
        showSnackBar("Registration failed. Account might already exist.", Colors.redAccent);
      }
    }
  }

  void navigateToDashboard(UserModel user) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => user.role == 'admin'
            ? const AdminDashboard()
            : const VoterDashboard(),
      ),
    );
  }

  void showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── BUILD METHODS ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Circular Logo from Splash Theme
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Image(
                      image: NetworkImage('https://i.ibb.co/5Wnqy4dH/logo.png'),
                      height: 80,
                      width: 80,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  const Text(
                    'E-Voting.org',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Secure & Transparent Democratic Platform',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Main UI Form Card
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: showOtpScreen ? buildOtpCard() : buildFormCard(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // OTP Verification view
  Widget buildOtpCard() {
    return Card(
      key: const ValueKey("otp_card"),
      elevation: 12,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          children: [
            const Icon(Icons.security, size: 48, color: Color(0xFF1A2980)),
            const SizedBox(height: 16),
            const Text(
              "Simulated OTP Verification",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1A2980)),
            ),
            const SizedBox(height: 8),
            Text(
              "An OTP has been dispatched to ${mobileController.text}. Look at the yellow-highlighted notification overlay at the bottom.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
            ),
            const SizedBox(height: 20),
            
            TextField(
              controller: otpController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 8),
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                counterText: "",
                hintText: "000000",
                hintStyle: TextStyle(color: Colors.grey.shade300, letterSpacing: 8),
                focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF1A2980), width: 2)),
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: handleVerifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2980),
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              child: const Text("VERIFY & LOGIN", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Didn't receive code?", style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: secondsRemaining == 0
                      ? () => triggerOtp(mobileController.text)
                      : null,
                  child: Text(
                    secondsRemaining == 0 ? "Resend Code" : "Resend in ${secondsRemaining}s",
                    style: TextStyle(
                      color: secondsRemaining == 0 ? const Color(0xFF26D0CE) : Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            
            TextButton(
              onPressed: () {
                setState(() {
                  showOtpScreen = false;
                  otpController.clear();
                });
              },
              child: const Text("Go Back", style: TextStyle(color: Color(0xFF1A2980))),
            ),
          ],
        ),
      ),
    );
  }

  // Form Card (Sign In / Register)
  Widget buildFormCard() {
    return Card(
      key: ValueKey(isSignIn ? "signin_card" : "register_card"),
      elevation: 12,
      shadowColor: Colors.black45,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Row Toggle
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSignIn = true;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          "Sign In",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSignIn ? const Color(0xFF1A2980) : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: isSignIn ? const Color(0xFF1A2980) : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isSignIn = false;
                      });
                    },
                    child: Column(
                      children: [
                        Text(
                          "Register",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: !isSignIn ? const Color(0xFF1A2980) : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 3,
                          color: !isSignIn ? const Color(0xFF1A2980) : Colors.transparent,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Form Fields
            if (!isSignIn) ...[
              // Name Field
              buildTextField(
                controller: nameController,
                label: "Full Name (as in Aadhar)",
                icon: Icons.person_outline,
                keyboardType: TextInputType.name,
              ),
              const SizedBox(height: 16),
            ],

            // Mobile Field (Shared)
            buildTextField(
              controller: mobileController,
              label: "Mobile Number",
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
              maxLength: 10,
            ),
            const SizedBox(height: 16),

            if (!isSignIn) ...[
              // Aadhar Field
              buildTextField(
                controller: aadharController,
                label: "Aadhar Card Number",
                icon: Icons.credit_card_outlined,
                keyboardType: TextInputType.number,
                maxLength: 12,
              ),
              const SizedBox(height: 16),

              // Voter ID Field
              buildTextField(
                controller: voterIdController,
                label: "Voter ID Number",
                icon: Icons.how_to_reg_outlined,
                keyboardType: TextInputType.text,
              ),
              const SizedBox(height: 16),

              // City dropdown selection
              Row(
                children: [
                  const Icon(Icons.location_city, color: Color(0xFF1A2980)),
                  const SizedBox(width: 12),
                  const Text("City: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: selectedCity,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                      ),
                      items: cities.map((city) {
                        return DropdownMenuItem(value: city, child: Text(city));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            selectedCity = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Role toggle
              Row(
                children: [
                  const Icon(Icons.supervised_user_circle_outlined, color: Color(0xFF1A2980)),
                  const SizedBox(width: 12),
                  const Text("Register As: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SegmentedButton<String>(
                      segments: const [
                        ButtonSegment<String>(
                          value: 'voter',
                          label: Text('Voter'),
                          icon: Icon(Icons.person, size: 16),
                        ),
                        ButtonSegment<String>(
                          value: 'admin',
                          label: Text('Admin'),
                          icon: Icon(Icons.admin_panel_settings, size: 16),
                        ),
                      ],
                      selected: {selectedRole},
                      onSelectionChanged: (Set<String> newSelection) {
                        setState(() {
                          selectedRole = newSelection.first;
                        });
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: const Color(0xFF1A2980),
                        selectedForegroundColor: Colors.white,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],

            // Submit Button
            ElevatedButton(
              onPressed: handleSendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1A2980),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                elevation: 4,
              ),
              child: Text(
                isSignIn ? "SEND SECURE OTP" : "VERIFY DETAILS & SEND OTP",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            
            // Testing hints
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, size: 16, color: Colors.amber),
                      SizedBox(width: 6),
                      Text("Testing Credentials:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.amber)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isSignIn
                        ? "• Admin login: 9999999999 (OTP: 123456)\n• Voter login: 8888888888 (OTP: 123456)"
                        : "• You can register new voters or admins!\n• Enter any details, and use OTP 123456.",
                    style: TextStyle(fontSize: 11, color: Colors.amber.shade900),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required TextInputType keyboardType,
    int? maxLength,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
        prefixIcon: Icon(icon, color: const Color(0xFF1A2980)),
        counterText: "",
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF1A2980), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
      ),
    );
  }
}
