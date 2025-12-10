import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../services/auth_service.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  static const _campusOptions = [
    'Balfour',
    'Ermelo',
    'Evander',
    'Mpuluzi',
    'Perdekop',
    'Standerton',
  ];

  static const _genderOptions = ['Male', 'Female', 'Prefer not to say'];

  static const _departmentOptions = [
    'Engineering',
    'Business',
    'IT',
    'Hospitality',
    'Tourism',
    'Safety in Society',
    'Primary Health',
  ];

  static const _natedLevels = ['N1', 'N2', 'N3', 'N4', 'N5', 'N6'];
  static const _ncvLevels = ['Level 2', 'Level 3', 'Level 4'];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  final RegExp _emailRegex = RegExp(
    r'^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$',
  );

  bool _isNated = true;
  bool _isPasswordObscure = true;
  bool _agreedToCode = false;
  bool _isEmailValid = false;
  bool _isLoading = false;

  String _loadingStatus = '';
  File? _selectedImage;

  String _selectedGender = _genderOptions.first;
  String _selectedCampus = _campusOptions.first;
  String _selectedDepartment = _departmentOptions.first;
  String _selectedLevel = _natedLevels.first;

  final AuthService _authService = AuthService();
  late final ConfettiController _confettiController;
  late final FocusNode _nameFocusNode;
  late final FocusNode _surnameFocusNode;
  late final FocusNode _emailFocusNode;
  late final FocusNode _passwordFocusNode;
  late final List<FocusNode> _focusNodes;

  final ShakeController _nameShakeController = ShakeController();
  final ShakeController _surnameShakeController = ShakeController();
  final ShakeController _emailShakeController = ShakeController();
  final ShakeController _passwordShakeController = ShakeController();

  StateSetter? _mintingDialogSetState;

  List<String> get _levelOptions => _isNated ? _natedLevels : _ncvLevels;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    _nameFocusNode = FocusNode();
    _surnameFocusNode = FocusNode();
    _emailFocusNode = FocusNode();
    _passwordFocusNode = FocusNode();
    _focusNodes = [
      _nameFocusNode,
      _surnameFocusNode,
      _emailFocusNode,
      _passwordFocusNode,
    ];
    _emailController.addListener(_validateEmail);
  }

  void _validateEmail() {
    setState(() {
      _isEmailValid = _emailRegex.hasMatch(_emailController.text.trim());
    });
  }

  @override
  void dispose() {
    _emailController.removeListener(_validateEmail);
    for (final node in _focusNodes) {
      node.dispose();
    }
    _confettiController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF0D47A1),
                    Color(0xFF2962FF),
                    Color(0xFF448AFF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                emissionFrequency: 0.02,
                numberOfParticles: 20,
                gravity: 0.25,
                colors: const [
                  Color(0xFF2962FF),
                  Color(0xFFFFD740),
                  Color(0xFF0D47A1),
                ],
              ),
            ),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                      child: Container(
                        width: double.infinity,
                        constraints: const BoxConstraints(maxWidth: 520),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.6),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 40,
                              offset: const Offset(0, 30),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Image.asset(
                                  'assets/images/logo.png',
                                  height: 80,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            Text(
                              'Join the Vibe',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: const Color(0xFF0D47A1),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ToggleButtons(
                              borderRadius: BorderRadius.circular(18),
                              isSelected: [_isNated, !_isNated],
                              fillColor: const Color(0xFF2962FF),
                              selectedColor: Colors.white,
                              color: const Color(0xFF0D47A1),
                              onPressed: (index) {
                                setState(() {
                                  _isNated = index == 0;
                                  _selectedLevel = _levelOptions.first;
                                });
                              },
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  child: Text('Nated'),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 18,
                                    vertical: 8,
                                  ),
                                  child: Text('NCV'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(child: _buildProfilePicker()),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: _buildNameField()),
                                const SizedBox(width: 12),
                                Expanded(child: _buildSurnameField()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildEmailField(),
                            const SizedBox(height: 16),
                            _buildPasswordField(),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildDropdown(
                                    value: _selectedGender,
                                    label: 'Gender',
                                    items: _genderOptions,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => _selectedGender = value);
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _buildDropdown(
                                    value: _selectedCampus,
                                    label: 'Campus',
                                    items: _campusOptions,
                                    onChanged: (value) {
                                      if (value == null) return;
                                      setState(() => _selectedCampus = value);
                                    },
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              value: _selectedDepartment,
                              label: 'Department',
                              items: _departmentOptions,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedDepartment = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildDropdown(
                              value: _selectedLevel,
                              label: 'Level',
                              items: _levelOptions,
                              onChanged: (value) {
                                if (value == null) return;
                                setState(() => _selectedLevel = value);
                              },
                            ),
                            const SizedBox(height: 16),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _agreedToCode,
                                  onChanged: (value) {
                                    setState(
                                      () => _agreedToCode = value ?? false,
                                    );
                                  },
                                  fillColor: MaterialStateProperty.all(
                                    const Color(0xFF2962FF),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _showVibeCodeDialog,
                                    child: Text(
                                      'I agree to the Vibe Code',
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(
                                            color: Colors.black87,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: const Color(
                                              0xFF2962FF,
                                            ),
                                          ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _agreedToCode && !_isLoading
                                    ? _handleSignup
                                    : null,
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Text('Create Account'),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(
                                  Icons.lock_outline,
                                  size: 12,
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'Your data is encrypted and secure',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                            Center(
                              child: TextButton(
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFFFFD740),
                                  textStyle: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                onPressed: () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const LoginScreen(),
                                      ),
                                    );
                                  }
                                },
                                child: const Text(
                                  'Already have an account? Login',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicker() {
    return GestureDetector(
      onTap: _pickProfileImage,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: const Color(0xFF2962FF).withOpacity(0.15),
        child: _selectedImage == null
            ? const Icon(Icons.camera_alt, color: Colors.white, size: 32)
            : ClipOval(
                child: Image.file(
                  _selectedImage!,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
      ),
    );
  }

  Widget _buildNameField() {
    return ShakeWidget(
      controller: _nameShakeController,
      child: TextField(
        controller: _nameController,
        focusNode: _nameFocusNode,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [_CapitalizeWordsFormatter()],
        textInputAction: TextInputAction.next,
        onSubmitted: (_) =>
            FocusScope.of(context).requestFocus(_surnameFocusNode),
        style: const TextStyle(color: Colors.black87),
        decoration: _fieldDecoration('Name', Icons.badge_outlined),
      ),
    );
  }

  Widget _buildSurnameField() {
    return ShakeWidget(
      controller: _surnameShakeController,
      child: TextField(
        controller: _surnameController,
        focusNode: _surnameFocusNode,
        textCapitalization: TextCapitalization.words,
        inputFormatters: [_CapitalizeWordsFormatter()],
        textInputAction: TextInputAction.next,
        onSubmitted: (_) =>
            FocusScope.of(context).requestFocus(_emailFocusNode),
        style: const TextStyle(color: Colors.black87),
        decoration: _fieldDecoration('Surname', Icons.badge),
      ),
    );
  }

  Widget _buildEmailField() {
    final showSuggestion = _emailController.text.trim().endsWith('@gm');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShakeWidget(
          controller: _emailShakeController,
          child: TextField(
            controller: _emailController,
            focusNode: _emailFocusNode,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onSubmitted: (_) =>
                FocusScope.of(context).requestFocus(_passwordFocusNode),
            onChanged: (_) => setState(() {}),
            style: const TextStyle(color: Colors.black87),
            decoration: _fieldDecoration('Email', Icons.mail_outline).copyWith(
              suffixIcon: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: _isEmailValid ? 1 : 0,
                child: const Icon(Icons.check_circle, color: Colors.green),
              ),
            ),
          ),
        ),
        AnimatedOpacity(
          opacity: showSuggestion ? 1 : 0,
          duration: const Duration(milliseconds: 200),
          child: showSuggestion
              ? Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: GestureDetector(
                    onTap: _applyGmailSuggestion,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEEF4FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Use @gmail.com',
                        style: TextStyle(
                          color: Color(0xFF0D47A1),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return ShakeWidget(
      controller: _passwordShakeController,
      child: TextField(
        controller: _passwordController,
        focusNode: _passwordFocusNode,
        obscureText: _isPasswordObscure,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => FocusScope.of(context).unfocus(),
        style: const TextStyle(color: Colors.black87),
        decoration: _fieldDecoration('Password', Icons.lock_outline).copyWith(
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordObscure ? Icons.visibility_off : Icons.visibility,
              color: const Color(0xFF2962FF),
            ),
            onPressed: () =>
                setState(() => _isPasswordObscure = !_isPasswordObscure),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: _fieldDecoration(label, Icons.keyboard_arrow_down),
      dropdownColor: Colors.white,
      iconEnabledColor: const Color(0xFF2962FF),
      style: const TextStyle(color: Colors.black87),
      items: items
          .map(
            (item) => DropdownMenuItem<String>(value: item, child: Text(item)),
          )
          .toList(),
      onChanged: onChanged,
    );
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: const Color(0xFF2962FF)),
      filled: true,
      fillColor: Colors.white,
      labelStyle: const TextStyle(color: Colors.black54),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFF2962FF), width: 1.5),
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    if (kIsWeb) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile photos require a mobile device.'),
        ),
      );
      return;
    }

    try {
      final picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;
      setState(() => _selectedImage = File(picked.path));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Unable to pick image: $error')));
    }
  }

  void _applyGmailSuggestion() {
    final text = _emailController.text;
    if (!text.endsWith('@gm')) return;
    final updated = '${text.substring(0, text.length - 3)}@gmail.com';
    _emailController.text = updated;
    _emailController.selection = TextSelection.collapsed(
      offset: updated.length,
    );
  }

  bool _validateForm() {
    var isValid = true;
    if (_nameController.text.trim().isEmpty) {
      _nameShakeController.shake();
      isValid = false;
    }
    if (_surnameController.text.trim().isEmpty) {
      _surnameShakeController.shake();
      isValid = false;
    }
    if (!_emailRegex.hasMatch(_emailController.text.trim())) {
      _emailShakeController.shake();
      isValid = false;
    }
    if (_passwordController.text.trim().length < 6) {
      _passwordShakeController.shake();
      isValid = false;
    }
    if (!isValid && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please double-check the highlighted fields.'),
        ),
      );
    }
    return isValid;
  }

  Future<void> _handleSignup() async {
    FocusScope.of(context).unfocus();
    if (!_validateForm()) return;

    setState(() => _isLoading = true);
    _loadingStatus = 'Creating Student Profile...';
    _openMintingDialog();

    try {
      _updateMintingStatus('Creating Student Profile...');
      await Future.delayed(const Duration(seconds: 1));

      final result = await _authService.signUp(
        email: _emailController.text,
        password: _passwordController.text,
        name: _nameController.text,
        surname: _surnameController.text,
        campus: _selectedCampus,
        department: _selectedDepartment,
        level: _selectedLevel,
        studentType: _isNated ? 'Nated' : 'NCV',
        gender: _selectedGender,
      );

      _updateMintingStatus('Assigning Campus...');
      await Future.delayed(const Duration(seconds: 1));

      final user = result.credential.user;
      if (user != null) {
        await _maybeUploadProfileImage(user);
      }

      _updateMintingStatus('Done!');
      await Future.delayed(const Duration(milliseconds: 500));
      _closeMintingDialog();

      _confettiController.play();
      await Future.delayed(const Duration(milliseconds: 1500));

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      _closeMintingDialog();
      _showError(error.message ?? 'Signup failed.');
      _shakeAllFields();
    } catch (error) {
      _closeMintingDialog();
      _showError(error.toString());
      _shakeAllFields();
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _shakeAllFields() {
    _nameShakeController.shake();
    _surnameShakeController.shake();
    _emailShakeController.shake();
    _passwordShakeController.shake();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openMintingDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            _mintingDialogSetState = setState;
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    _loadingStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0D47A1),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _updateMintingStatus(String status) {
    _loadingStatus = status;
    _mintingDialogSetState?.call(() {});
  }

  void _closeMintingDialog() {
    if (_mintingDialogSetState != null &&
        Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true).pop();
    }
    _mintingDialogSetState = null;
  }

  Future<void> _maybeUploadProfileImage(User user) async {
    final image = _selectedImage;
    if (image == null) return;

    final storagePath =
        'profile_images/${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref(storagePath);
    await ref.putFile(image, SettableMetadata(contentType: 'image/jpeg'));
    final downloadUrl = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'photoUrl': downloadUrl,
    });
    await user.updatePhotoURL(downloadUrl);
  }

  void _showVibeCodeDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('The Vibe Code'),
        content: const Text('1. Be Respectful.\n2. No Spam.\n3. Have Fun.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ShakeController {
  VoidCallback? _listener;

  void shake() => _listener?.call();
}

class ShakeWidget extends StatefulWidget {
  const ShakeWidget({super.key, required this.controller, required this.child});

  final ShakeController controller;
  final Widget child;

  @override
  State<ShakeWidget> createState() => _ShakeWidgetState();
}

class _ShakeWidgetState extends State<ShakeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _offsetAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8, end: 0), weight: 1),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    widget.controller._listener = () {
      if (!_controller.isAnimating) {
        _controller.forward(from: 0);
      }
    };
  }

  @override
  void dispose() {
    widget.controller._listener = null;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offsetAnimation,
      builder: (context, child) => Transform.translate(
        offset: Offset(_offsetAnimation.value, 0),
        child: child,
      ),
      child: widget.child,
    );
  }
}

class _CapitalizeWordsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    if (text.isEmpty) return newValue;

    final capitalized = text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return word;
          final first = word.substring(0, 1).toUpperCase();
          final rest = word.length > 1 ? word.substring(1).toLowerCase() : '';
          return '$first$rest';
        })
        .join(' ');

    return TextEditingValue(
      text: capitalized,
      selection: TextSelection.collapsed(offset: capitalized.length),
    );
  }
}
