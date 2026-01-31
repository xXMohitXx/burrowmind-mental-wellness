/// API Endpoints for BurrowMind Backend
class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Change for production
  static const String baseUrl = 'http://localhost:8000/api/v1';

  // Auth endpoints
  static const String authRegister = '/auth/register';
  static const String authLogin = '/auth/login';
  static const String authRefresh = '/auth/refresh';
  static const String authLogout = '/auth/logout';
  static const String authForgotPassword = '/auth/forgot-password';
  static const String authVerifyOtp = '/auth/verify-otp';
  static const String authResetPassword = '/auth/reset-password';

  // User endpoints
  static const String userProfile = '/user/profile';
  static const String userSettings = '/user/settings';
  static const String userAvatar = '/user/avatar';

  // Chat (AI) endpoints
  static const String chatSend = '/chat/send';
  static const String chatContext = '/chat/context';
  static const String chatSafetyCheck = '/chat/safety-check';
  static const String chatHistory = '/chat/history';

  // Resources endpoints
  static const String resourcesArticles = '/resources/articles';
  static const String resourcesCourses = '/resources/courses';

  // Community endpoints
  static const String communityPosts = '/community/posts';
  static const String communityPrograms = '/community/programs';

  // Support endpoints
  static const String supportContact = '/support/contact';
  static const String supportFeedback = '/support/feedback';
  static const String supportFaq = '/support/faq';

  // Analytics endpoints
  static const String analyticsSync = '/analytics/sync';
}
