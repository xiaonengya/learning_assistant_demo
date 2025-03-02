import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/theme/theme_bloc.dart';

class ThemeColorSelector extends StatelessWidget {
  final List<Color> colors;

  const ThemeColorSelector({
    super.key,
    this.colors = const [
      Colors.blue,
      Colors.green,
      Colors.purple,
      Colors.orange,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.amber,
      Colors.indigo,
      Colors.cyan,
    ],
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        final currentColor = state.colorSeed;
        
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: colors.map((color) {
            final isSelected = currentColor.value == color.value;
            
            return GestureDetector(
              onTap: () {
                // 修正: 使用正确的事件名 ChangeColorEvent 而不是 ChangeThemeColorEvent
                context.read<ThemeBloc>().add(ChangeColorEvent(color));
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: isSelected
                      ? Border.all(
                          color: isDark(context) ? Colors.white : Colors.black54,
                          width: 3,
                        )
                      : null,
                ),
                child: isSelected
                    ? Icon(
                        Icons.check,
                        color: isDark(context) ? Colors.white : Colors.black54,
                      )
                    : null,
              ),
            );
          }).toList(),
        );
      },
    );
  }
  
  bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}
