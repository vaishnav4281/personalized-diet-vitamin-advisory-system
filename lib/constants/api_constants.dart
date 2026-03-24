class ApiConstants {
  static const String baseUrl = 'https://diet-health-app.onrender.com/api';
  
  // Auth endpoints (user blueprint)
  static const String login = '/user/login';
  static const String register = '/user/register';
  static const String profile = '/user/profile';        // GET/PUT /{user_id}
  static const String onboarding = '/user/onboarding';  // POST
  
  // Health & Analysis
  static const String analyzeHealth = '/health/analyze-health';
  static const String healthHistory = '/health/history'; // GET /{user_id}
  static const String healthLatest = '/health/latest';   // GET /{user_id}
  
  // Diet
  static const String getDietPlan = '/diet/get-plan';    // GET /{user_id}
  static const String generateDiet = '/diet/generate-diet';
  
  // Routine
  static const String getRoutine = '/routine/get-routine';       // GET /{user_id}
  static const String generateRoutine = '/routine/generate-routine';
  
  // Reminders (under routine blueprint)
  static const String getReminders = '/routine/reminders';        // GET /{user_id}
  static const String addReminder = '/routine/reminders/add-custom';
  static const String saveReminders = '/routine/reminders/save';
  
  // Progress
  static const String logProgress = '/progress/log';
  static const String getProgress = '/progress';         // GET /{user_id}
  static const String getWeeklyProgress = '/progress/weekly'; // GET /{user_id}
}
