import 'package:flutter/material.dart';
import 'home_page.dart';

class LoginNewPage extends StatefulWidget {
  const LoginNewPage({super.key});

  @override
  State<LoginNewPage> createState() => _LoginNewPageState();
}

class _LoginNewPageState extends State<LoginNewPage> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _continue() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Colores institucionales
    const Color azulAgua = Color(0xFF1565C0);
    const Color verdeHoja = Color(0xFF4CAF50);

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // 🔥 LOGO GRANDE
                Image.asset(
                  'assets/icons/logo_suelo_y_agua_real-removebg-preview.png',
                  height: 180,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 45),

                // 📝 CAMPO NOMBRE
                TextFormField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.black), // 🔥 TEXTO NEGRO
                  decoration: InputDecoration(
                    labelText: "Nombre (opcional)",
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    prefixIcon: const Icon(Icons.person, color: azulAgua),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: azulAgua, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // 📞 CAMPO TELÉFONO
                TextFormField(
                  controller: _phoneCtrl,
                  style: const TextStyle(color: Colors.black), // 🔥 TEXTO NEGRO
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: "Número de teléfono",
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    prefixIcon: const Icon(Icons.phone, color: verdeHoja),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: verdeHoja, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? "Ingresa tu teléfono" : null,
                ),

                const SizedBox(height: 40),

                // 🔵 BOTÓN CONTINUAR
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _continue,
                    style: FilledButton.styleFrom(
                      backgroundColor: azulAgua,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      "CONTINUAR",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.3,
                        color: Colors.white,
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
}
