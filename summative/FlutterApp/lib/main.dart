import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Youth Unemployment Predictor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const PredictionPage(),
    );
  }
}

class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _sexController = TextEditingController();
  final TextEditingController _ageGroupController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();

  String _resultText = "";
  bool _isError = false;
  bool _isLoading = false;
  bool _hasResult = false;

  late AnimationController _animController;
  late Animation<double> _scaleAnim;

  static const String apiUrl =
      "https://youth-unemployment-api.onrender.com/predict";

  // Soft, elegant lavender/violet gradient - not too dark, not too bright
  static const Color bgTop = Color(0xFF6C63B5);
  static const Color bgMid = Color(0xFF8B6FC7);
  static const Color bgBottom = Color(0xFF5B4E9C);

  static const Color accentColor = Color(0xFF4ECDC4);

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(parent: _animController, curve: Curves.elasticOut);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  String _friendlyErrorMessage(dynamic detail) {
    if (detail is List && detail.isNotEmpty) {
      final firstError = detail[0];
      final field = (firstError['loc'] as List).last.toString();
      final fieldNames = {
        "country": "Country",
        "sex": "Sex",
        "age_group": "Age Group",
        "year": "Year",
      };
      final niceField = fieldNames[field] ?? field;

      if (field == "country") {
        return "Invalid $niceField. Please enter a valid African country name (e.g. Kenya, Nigeria, Ghana).";
      } else if (field == "sex") {
        return "Invalid $niceField. Please enter exactly 'Male' or 'Female'.";
      } else if (field == "age_group") {
        return "Invalid $niceField. Please enter exactly 'Under 15', '15-24', or '25+'.";
      } else if (field == "year") {
        return "Invalid $niceField. Please enter a year between 2014 and 2030.";
      }
      return "Invalid input for $niceField.";
    }
    return "Something went wrong with your input. Please check the values and try again.";
  }

  Future<void> _predict() async {
    setState(() {
      _isLoading = true;
      _resultText = "";
      _isError = false;
      _hasResult = false;
    });
    _animController.reset();

    final country = _countryController.text.trim();
    final sex = _sexController.text.trim();
    final ageGroup = _ageGroupController.text.trim();
    final yearText = _yearController.text.trim();

    if (country.isEmpty || sex.isEmpty || ageGroup.isEmpty || yearText.isEmpty) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _hasResult = true;
        _resultText = "Please fill in all fields before predicting.";
      });
      _animController.forward();
      return;
    }

    final year = int.tryParse(yearText);
    if (year == null) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _hasResult = true;
        _resultText = "Year must be a valid whole number (e.g. 2024).";
      });
      _animController.forward();
      return;
    }

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "country": country,
          "sex": sex,
          "age_group": ageGroup,
          "year": year,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _isError = false;
          _hasResult = true;
          _resultText =
              "Predicted Unemployment Rate: ${data['predicted_unemployment_rate']}%";
        });
      } else {
        final data = jsonDecode(response.body);
        setState(() {
          _isLoading = false;
          _isError = true;
          _hasResult = true;
          _resultText = _friendlyErrorMessage(data['detail']);
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
        _hasResult = true;
        _resultText = "Something went wrong. Please check your internet connection and try again.";
      });
    }
    _animController.forward();
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      prefixIcon: Icon(icon, color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(14)),
        borderSide: BorderSide(color: accentColor, width: 2.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgBottom,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgTop, bgMid, bgBottom],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Icon(Icons.insights_rounded, color: accentColor, size: 42),
                const SizedBox(height: 10),
                const Text(
                  "Youth Unemployment Predictor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Enter the details below to predict youth unemployment rate in an African country.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13.5, color: Colors.white70),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _countryController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration("Country (e.g. Kenya)", Icons.public),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _sexController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration("Sex (Male or Female)", Icons.person_outline),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _ageGroupController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration("Age Group (Under 15, 15-24, 25+)", Icons.groups_outlined),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _yearController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: _fieldDecoration("Year (2014-2030)", Icons.calendar_today_outlined),
                ),
                const SizedBox(height: 26),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _predict,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      disabledBackgroundColor: accentColor,
                      foregroundColor: const Color(0xFF1A1B4B),
                      disabledForegroundColor: const Color(0xFF1A1B4B),
                      elevation: 8,
                      shadowColor: accentColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              color: Color(0xFF1A1B4B),
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            "Predict",
                            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
                const SizedBox(height: 26),
                if (_hasResult)
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: _isError
                              ? [Colors.red.shade900, Colors.red.shade600]
                              : [const Color(0xFF06A77D), const Color(0xFF4ECDC4)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_isError ? Colors.redAccent : accentColor)
                                .withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isError
                                ? Icons.error_outline_rounded
                                : Icons.check_circle_outline_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              _resultText,
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: const Text(
                      "Your prediction result will appear here.",
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}