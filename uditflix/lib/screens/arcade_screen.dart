import 'dart:math' show Random, min;

import 'package:flutter/material.dart';

/// Pantalla de la sección UDIT Arcade.
///
/// Contiene un buscaminas sencillo (9x9 y 10 minas) implementado solo con
/// widgets de Flutter: toque para descubrir, pulsación larga o clic derecho
/// para colocar una bandera.
class ArcadeScreen extends StatefulWidget {
  const ArcadeScreen({super.key});

  @override
  State<ArcadeScreen> createState() => _ArcadeScreenState();
}

class _ArcadeScreenState extends State<ArcadeScreen> {
  static const int _filas = 9;
  static const int _columnas = 9;
  static const int _totalMinas = 10;

  late List<List<_Casilla>> _tablero;
  bool _primeraJugada = true;
  bool _terminado = false;
  bool _ganado = false;
  int _banderas = 0;

  @override
  void initState() {
    super.initState();
    _crearTablero();
  }

  void _crearTablero() {
    _tablero = List.generate(
      _filas,
      (f) => List.generate(_columnas, (c) => _Casilla(f, c)),
    );
    _primeraJugada = true;
    _terminado = false;
    _ganado = false;
    _banderas = 0;
  }

  void _reiniciar() => setState(_crearTablero);

  int get _minasRestantes => _totalMinas - _banderas;

  /// La primera casilla nunca es una mina (ni sus vecinas).
  void _colocarMinas(int fila, int columna) {
    final candidatas =
        _tablero
            .expand((filaCasillas) => filaCasillas)
            .where((casilla) => !_esVecina(casilla, fila, columna))
            .toList()
          ..shuffle(Random());

    for (final casilla in candidatas.take(_totalMinas)) {
      casilla.mina = true;
    }
    for (final filaCasillas in _tablero) {
      for (final casilla in filaCasillas) {
        casilla.minasAlrededor = _contarMinasVecinas(casilla);
      }
    }
    _primeraJugada = false;
  }

  bool _esVecina(_Casilla casilla, int fila, int columna) =>
      (casilla.fila - fila).abs() <= 1 &&
      (casilla.columna - columna).abs() <= 1;

  int _contarMinasVecinas(_Casilla casilla) =>
      _vecinas(casilla).where((vecina) => vecina.mina).length;

  List<_Casilla> _vecinas(_Casilla casilla) {
    final resultado = <_Casilla>[];
    for (var df = -1; df <= 1; df++) {
      for (var dc = -1; dc <= 1; dc++) {
        if (df == 0 && dc == 0) continue;
        final f = casilla.fila + df;
        final c = casilla.columna + dc;
        if (f >= 0 && f < _filas && c >= 0 && c < _columnas) {
          resultado.add(_tablero[f][c]);
        }
      }
    }
    return resultado;
  }

  void _revelar(int fila, int columna) {
    if (_terminado) return;
    final casilla = _tablero[fila][columna];
    if (casilla.revelada || casilla.marcada) return;
    if (_primeraJugada) _colocarMinas(fila, columna);

    if (casilla.mina) {
      _perder();
    } else {
      _revelarEnCadena(casilla);
      _comprobarVictoria();
    }
    setState(() {});
  }

  /// Descubre las casillas vecinas de forma iterativa cuando no hay minas
  /// alrededor, como en el buscaminas clásico.
  void _revelarEnCadena(_Casilla inicio) {
    final pendientes = <_Casilla>[inicio];
    while (pendientes.isNotEmpty) {
      final actual = pendientes.removeLast();
      if (actual.revelada || actual.marcada || actual.mina) continue;
      actual.revelada = true;
      if (actual.minasAlrededor == 0) {
        pendientes.addAll(
          _vecinas(actual).where(
            (vecina) => !vecina.revelada && !vecina.marcada && !vecina.mina,
          ),
        );
      }
    }
  }

  void _alternarBandera(int fila, int columna) {
    if (_terminado) return;
    final casilla = _tablero[fila][columna];
    if (casilla.revelada) return;
    setState(() {
      casilla.marcada = !casilla.marcada;
      _banderas += casilla.marcada ? 1 : -1;
    });
  }

  void _perder() {
    _terminado = true;
    _ganado = false;
    for (final fila in _tablero) {
      for (final casilla in fila) {
        if (casilla.mina) casilla.revelada = true;
      }
    }
  }

  void _comprobarVictoria() {
    final completado = _tablero
        .expand((fila) => fila)
        .every((casilla) => casilla.mina || casilla.revelada);
    if (!completado) return;

    _terminado = true;
    _ganado = true;
    for (final fila in _tablero) {
      for (final casilla in fila) {
        if (casilla.mina) casilla.marcada = true;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0F),
      appBar: AppBar(
        title: const Text('UDIT Buscaminas'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(
              child: Text(
                'Minas: $_minasRestantes',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            onPressed: _reiniciar,
            tooltip: 'Nueva partida',
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final lado = min(
              constraints.maxWidth,
              constraints.maxHeight,
            ).clamp(0.0, 440.0).toDouble();

            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minWidth: constraints.maxWidth,
                  minHeight: constraints.maxHeight,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Text(
                        'Toca para descubrir · Mantén pulsado o clic derecho '
                        'para marcar una mina',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: lado,
                      height: lado,
                      child: GridView.count(
                        crossAxisCount: _columnas,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(4),
                        crossAxisSpacing: 2,
                        mainAxisSpacing: 2,
                        children: [
                          for (final fila in _tablero)
                            for (final casilla in fila)
                              _Celda(
                                key: Key(
                                  'celda-${casilla.fila}-${casilla.columna}',
                                ),
                                casilla: casilla,
                                onRevelar: () =>
                                    _revelar(casilla.fila, casilla.columna),
                                onMarcar: () => _alternarBandera(
                                  casilla.fila,
                                  casilla.columna,
                                ),
                              ),
                        ],
                      ),
                    ),
                    if (_terminado)
                      _PanelResultado(ganado: _ganado, onReiniciar: _reiniciar),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Casilla {
  _Casilla(this.fila, this.columna);

  final int fila;
  final int columna;
  bool mina = false;
  bool revelada = false;
  bool marcada = false;
  int minasAlrededor = 0;
}

class _Celda extends StatelessWidget {
  const _Celda({
    super.key,
    required this.casilla,
    required this.onRevelar,
    required this.onMarcar,
  });

  final _Casilla casilla;
  final VoidCallback onRevelar;
  final VoidCallback onMarcar;

  @override
  Widget build(BuildContext context) {
    final color = casilla.revelada
        ? (casilla.mina ? const Color(0xFFE50914) : const Color(0xFF1C1C24))
        : const Color(0xFF2A2A36);

    return GestureDetector(
      onTap: onRevelar,
      onLongPress: onMarcar,
      onSecondaryTap: onMarcar,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: const Color(0xFF3A3A48)),
        ),
        child: Center(child: _contenido()),
      ),
    );
  }

  Widget? _contenido() {
    if (casilla.marcada && !casilla.revelada) {
      return const Icon(Icons.flag, size: 18, color: Color(0xFFE50914));
    }
    if (!casilla.revelada) return null;
    if (casilla.mina) {
      return const Icon(
        Icons.warning_amber_rounded,
        size: 20,
        color: Colors.white,
      );
    }
    if (casilla.minasAlrededor == 0) return null;

    return Text(
      '${casilla.minasAlrededor}',
      style: TextStyle(
        color: _colorNumero(casilla.minasAlrededor),
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Color _colorNumero(int numero) => switch (numero) {
    1 => const Color(0xFF64B5F6),
    2 => const Color(0xFF81C784),
    3 => const Color(0xFFE57373),
    4 => const Color(0xFFBA68C8),
    5 => const Color(0xFFFFB74D),
    6 => const Color(0xFF4DD0E1),
    7 => const Color(0xFFBDBDBD),
    _ => Colors.white,
  };
}

class _PanelResultado extends StatelessWidget {
  const _PanelResultado({required this.ganado, required this.onReiniciar});

  final bool ganado;
  final VoidCallback onReiniciar;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Card(
        color: const Color(0xFF1C1C24),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ganado ? '¡Has ganado!' : '¡Boom! Has pisado una mina',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ganado
                      ? const Color(0xFF81C784)
                      : const Color(0xFFE50914),
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: onReiniciar,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                ),
                icon: const Icon(Icons.restart_alt),
                label: const Text('Nueva partida'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
