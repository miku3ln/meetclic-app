import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Perfiles tipo Netflix',
      theme: ThemeData.dark(),
      home: const PerfilPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class PerfilPage extends StatelessWidget {
  const PerfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    final perfiles = [
      {'nombre': "Jota's", 'color': Colors.pink, 'icono': Icons.bug_report},
      {'nombre': "Alex", 'color': Colors.amber, 'icono': Icons.face},
      {'nombre': "MAMI", 'color': Colors.red, 'icono': Icons.face_2},
      {'nombre': "Niños", 'color': Colors.deepPurple, 'icono': Icons.child_care},
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Banner superior (imagen destacada)
            Stack(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: Image.network(
                    'https://i.imgur.com/fJUbZgM.jpeg', // Puedes poner aquí una imagen real
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'N PELÍCULA',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          letterSpacing: 2,
                        ),
                      ),
                      Text(
                        'EL MURO NEGRO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Estreno el jueves',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),
            const Text(
              'Elige tu perfil',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
            const SizedBox(height: 20),

            // Perfiles
            Expanded(
              child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  ...perfiles.map((perfil) {
                    return Column(
                      children: [
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: perfil['color'] as Color,
                          child: Icon(
                            perfil['icono'] as IconData,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          perfil['nombre'] as String,
                          style: const TextStyle(color: Colors.white),
                        )
                      ],
                    );
                  }),
                  // Botón Agregar
                  Column(
                    children: const [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.add, size: 30, color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text('Agregar', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  // Botón Editar
                  Column(
                    children: const [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.grey,
                        child: Icon(Icons.edit, size: 30, color: Colors.white),
                      ),
                      SizedBox(height: 6),
                      Text('Editar', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
