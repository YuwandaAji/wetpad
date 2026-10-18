import 'search_models.dart';

abstract class SearchRepository {
  Future<List<SearchCategory>> fetchCategories();

  Future<CategoryFeed> fetchCategoryFeed(
    String categoryId, {
    StoryFilter filter = const StoryFilter(),
  });

  Future<List<String>> fetchFilterTags(String categoryId);

  Future<List<String>> fetchTrendingKeywords();

  Future<List<SearchStory>> searchStories(String query);
}
