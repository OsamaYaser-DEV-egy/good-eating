import 'package:good_eating/core/usecase/use_case.dart';
import 'package:good_eating/core/utils/result.dart';
import 'package:good_eating/features/meals/domain/entities/meal_summary.dart';
import 'package:good_eating/features/meals/domain/repositories/meal_repository.dart';

/// Finds meals by name. The parameter is the text typed by the user.
///
/// A blank query returns no results without touching the network.
final class SearchMeals implements UseCase<List<MealSummary>, String> {
  const SearchMeals(this._repository);

  final MealRepository _repository;

  @override
  Future<Result<List<MealSummary>>> call(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return const Success<List<MealSummary>>([]);
    return _repository.searchMeals(trimmed);
  }
}
