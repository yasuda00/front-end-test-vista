
import 'package:flutter/foundation.dart';

import '../models/company.dart';
import '../services/api_service.dart';

class CompanyProvider extends ChangeNotifier {
  final ApiService _apiService;

  CompanyProvider(this._apiService);

  List<Company> _companies = [];

  bool _isLoading = false;
  bool _isCreating = false;
  String? _errorMessage;

  List<Company> get companies => _companies;
  bool get isLoading => _isLoading;
  bool get isCreating => _isCreating;
  String? get errorMessage => _errorMessage;

  // Fetch all companies
  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.getCompanies();

      _companies = data
          .map(
            (json) => Company.fromJson(
              json as Map<String, dynamic>,
            ),
          )
          .toList();
    } catch (error) {
      _errorMessage = error.toString().replaceFirst('Exception: ', '');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create a company
  Future<bool> createCompany({
    required String name,
    required String registrationNumber,
  }) async {
    _isCreating = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createCompany(
        name: name,
        registrationNumber: registrationNumber,
      );

      await fetchCompanies();

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
