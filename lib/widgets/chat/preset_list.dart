import 'package:flutter/material.dart';
import '../../models/ai_role.dart';

class PresetList extends StatelessWidget {
  final List<AIRole> roles;
  final AIRole? selectedRole;
  final Function(AIRole) onSelect;
  final Function(AIRole) onEdit;
  final bool isDark;

  const PresetList({
    super.key,
    required this.roles,
    this.selectedRole,
    required this.onSelect,
    required this.onEdit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: RoleCard(
              role: role,
              isSelected: role.id == selectedRole?.id,
              onSelect: onSelect,
              onEdit: onEdit,
              isDark: isDark,
            ),
          );
        },
      ),
    );
  }
}

class RoleCard extends StatelessWidget {
  final AIRole role;
  final bool isSelected;
  final Function(AIRole) onSelect;
  final Function(AIRole) onEdit;
  final bool isDark;

  const RoleCard({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onSelect,
    required this.onEdit,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).colorScheme.primaryContainer
          : isDark
              ? Colors.grey[850]
              : Colors.white,
      child: InkWell(
        onTap: () => onSelect(role),
        onLongPress: () => onEdit(role),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    _getCategoryIcon(),
                    size: 20,
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      role.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : null,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (role.isDefault)
                    Icon(
                      Icons.star,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                role.description,
                style: Theme.of(context).textTheme.bodySmall,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Text(
                role.category,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.secondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon() {
    switch (role.category) {
      case '技术':
        return Icons.code;
      case '教育':
        return Icons.school;
      case '创作':
        return Icons.edit;
      case '翻译':
        return Icons.translate;
      case '分析':
        return Icons.analytics;
      default:
        return Icons.psychology;
    }
  }
}
