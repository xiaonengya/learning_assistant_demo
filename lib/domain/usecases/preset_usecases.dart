import '../models/ai_role.dart';
import '../models/ai_preset_text.dart';
import '../repositories/preset_repository.dart';

// AIRole 相关用例
class GetRoles {
  final PresetRepository repository;

  GetRoles(this.repository);

  Future<List<AIRole>> call() async {
    return await repository.getRoles();
  }
}

class GetDefaultRole {
  final PresetRepository repository;

  GetDefaultRole(this.repository);

  Future<AIRole?> call() async {
    return await repository.getDefaultRole();
  }
}

class SaveRole {
  final PresetRepository repository;

  SaveRole(this.repository);

  Future<void> call(AIRole role) async {
    await repository.saveRole(role);
  }
}

class DeleteRole {
  final PresetRepository repository;

  DeleteRole(this.repository);

  Future<void> call(String id) async {
    await repository.deleteRole(id);
  }
}

class SetDefaultRole {
  final PresetRepository repository;

  SetDefaultRole(this.repository);

  Future<void> call(String id) async {
    await repository.setDefaultRole(id);
  }
}

// AIPresetText 相关用例
class GetPresetTexts {
  final PresetRepository repository;

  GetPresetTexts(this.repository);

  Future<List<AIPresetText>> call() async {
    return await repository.getPresetTexts();
  }
}

class GetDefaultPresetText {
  final PresetRepository repository;

  GetDefaultPresetText(this.repository);

  Future<AIPresetText?> call() async {
    return await repository.getDefaultPresetText();
  }
}

class SavePresetText {
  final PresetRepository repository;

  SavePresetText(this.repository);

  Future<void> call(AIPresetText preset) async {
    await repository.savePresetText(preset);
  }
}

class DeletePresetText {
  final PresetRepository repository;

  DeletePresetText(this.repository);

  Future<void> call(String id) async {
    await repository.deletePresetText(id);
  }
}

class SetDefaultPresetText {
  final PresetRepository repository;

  SetDefaultPresetText(this.repository);

  Future<void> call(String id) async {
    await repository.setDefaultPresetText(id);
  }
}

class RemoveDefaultPresetText {
  final PresetRepository repository;

  RemoveDefaultPresetText(this.repository);

  Future<void> call() async {
    await repository.removeDefaultPresetText();
  }
}
