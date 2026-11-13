
import 'package:flutter/foundation.dart';

import '../services/api_service.dart';

class ServiceProvider extends ChangeNotifier {
  final ApiService _apiService;

  ServiceProvider(this._apiService);

  bool _isCreating = false;
  String? _errorMessage;

  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  // Create a service
  Future<bool> createService({
    required int companyId,
    required String name,
    String? description,
    required double price,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createService(
        companyId: companyId,
        name: name,
        description: description,
        price: price,
      );

      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isCreating = false;
      notifyListeners();
    }
  }
}
