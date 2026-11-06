import 'package:good_eating/core/constants/api_constants.dart';
import 'package:good_eating/core/network/api_client.dart';
import 'package:good_eating/core/utils/json_parsing.dart';
import 'package:good_eating/features/meals/data/models/meal_category_model.dart';
import 'package:good_eating/features/meals/data/models/meal_detail_model.dart';
import 'package:good_eating/features/meals/data/models/meal_summary_model.dart';

/// The four TheMealDB endpoints. Methods throw on network or parsing problems;
/// the repository turns those into failures.
abstract interface class MealRemoteDataSource {
  Future<List<MealCategoryModel>> getCategories();

  Future<List<MealSummaryModel>> getMealsByCategory(String category);

  /// Null when no meal has [id].
  Future<MealDetailModel?> getMealDetails(String id);

  Future<List<MealSummaryModel>> searchMeals(String query);
}

final class MealRemoteDataSourceImpl implements MealRemoteDataSource {
  const MealRemoteDataSourceImpl(this._client);

  final ApiClient _client;

  @override
  Future<List<MealCategoryModel>> getCategories() async {
    final json = await _client.get(ApiConstants.categoriesPath);
    return parseJsonList(json, 'categories', MealCategoryModel.fromJson);
  }

  @override
  Future<List<MealSummaryModel>> getMealsByCategory(String category) async {
    final json = await _client.get(
      ApiConstants.filterPath,
      queryParameters: {ApiConstants.categoryQuery: category},
    );
    return parseJsonList(json, 'meals', MealSummaryModel.fromJson);
  }

  @override
  Future<MealDetailModel?> getMealDetails(String id) async {
    final json = await _client.get(
      ApiConstants.lookupPath,
      queryParameters: {ApiConstants.idQuery: id},
    );
    return parseJsonList(json, 'meals', MealDetailModel.fromJson).firstOrNull;
  }

  @override
  Future<List<MealSummaryModel>> searchMeals(String query) async {
    final json = await _client.get(
      ApiConstants.searchPath,
      queryParameters: {ApiConstants.nameQuery: query},
    );
    return parseJsonList(json, 'meals', MealSummaryModel.fromJson);
  }
}
