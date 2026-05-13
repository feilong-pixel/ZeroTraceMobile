class AppPreferences {
  const AppPreferences({
    this.languageCode,
    this.themeMode = AppThemeMode.system,
    this.reviewSort = ReviewSort.recommendedFirst,
    this.thumbnailSize = 256,
    this.hasCompletedFirstRun = false,
  });

  final String? languageCode;
  final AppThemeMode themeMode;
  final ReviewSort reviewSort;
  final int thumbnailSize;
  final bool hasCompletedFirstRun;

  AppPreferences copyWith({
    String? languageCode,
    AppThemeMode? themeMode,
    ReviewSort? reviewSort,
    int? thumbnailSize,
    bool? hasCompletedFirstRun,
  }) {
    return AppPreferences(
      languageCode: languageCode ?? this.languageCode,
      themeMode: themeMode ?? this.themeMode,
      reviewSort: reviewSort ?? this.reviewSort,
      thumbnailSize: thumbnailSize ?? this.thumbnailSize,
      hasCompletedFirstRun: hasCompletedFirstRun ?? this.hasCompletedFirstRun,
    );
  }
}

enum AppThemeMode {
  system,
  light,
  dark,
}

enum ReviewSort {
  recommendedFirst,
  newestFirst,
  largestFirst,
}
