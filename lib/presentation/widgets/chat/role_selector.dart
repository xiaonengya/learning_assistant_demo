import 'package:flutter/material.dart';
import '../../../domain/models/ai_role.dart';

class RoleSelector extends StatelessWidget {
  final List<AIRole> roles;
  final AIRole? selectedRole;
  final Function(AIRole) onRoleSelected;

  const RoleSelector({
    super.key,
    required this.roles,
    this.selectedRole,
    required this.onRoleSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: roles.length,
        itemBuilder: (context, index) {
          final role = roles[index];
          final isSelected = role.id == selectedRole?.id;
          
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              elevation: isSelected ? 4 : 1,
              color: isSelected 
                  ? Theme.of(context).colorScheme.primaryContainer 
                  : null,
              child: InkWell(
                onTap: () => onRoleSelected(role),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _getCategoryIcon(role.category),
                            size: 16,
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.primary.withOpacity(0.6),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              role.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Theme.of(context).colorScheme.onPrimaryContainer
                                    : null,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (role.isDefault)
                            Icon(
                              Icons.star,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: Text(
                          role.description,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
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
