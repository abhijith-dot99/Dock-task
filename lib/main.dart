import 'package:flutter/material.dart';

/// Entrypoint of the application.
void main() {
  runApp(const MyApp());
}

/// [Widget] building the [MaterialApp].
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
       debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Dock(
              items: const [
                Icons.person,
                Icons.message,
                Icons.call,
                Icons.camera,
                Icons.photo,
              ],
              builder: (icon, isHovering) {
                final backgroundColor =
                    Colors.primaries[icon.hashCode % Colors.primaries.length];

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: backgroundColor,
                  ),
                  child: Center(
                    child: Icon(icon, color: Colors.white),
                  ),
                );
              }),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial [T] items to put in this [Dock].
  final List<T> items;

  /// Builder building the provided [T] item with a hover state.
  final Widget Function(T, bool isHovering) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State of the [Dock] used to manipulate the [_items].
class _DockState<T extends Object> extends State<Dock<T>> {
  /// [T] items being manipulated.
  late final List<T> _items = widget.items.toList();

  /// Track hover state for each item.
  final Map<int, bool> _hoveringStates = {};

  /// Resets all hover states.
  void _resetHoverStates() {
    setState(() {
      _hoveringStates.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return Draggable<T>(
            data: item,
            feedback: Material(
              color: Colors.transparent,
              child: widget.builder(item, false),
            ),
            onDragCompleted: _resetHoverStates, // Reset hover states after drag
            onDragEnd: (_) => _resetHoverStates(), // Reset hover on drag end
            child: DragTarget<T>(
              onAccept: (receivedItem) {
                setState(() {
                  final oldIndex = _items.indexOf(receivedItem);
                  _items.removeAt(oldIndex);
                  _items.insert(index, receivedItem);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return MouseRegion(
                  onEnter: (_) {
                    setState(() {
                      _hoveringStates[index] = true;
                    });
                  },
                  onExit: (_) {
                    setState(() {
                      _hoveringStates[index] = false;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.all(8),
                    transform: _hoveringStates[index] ?? false
                        ? Matrix4.translationValues(0, -15, 0)
                        : Matrix4.translationValues(0, 0, 0),
                    child: widget.builder(
                      item,
                      _hoveringStates[index] ?? false,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}