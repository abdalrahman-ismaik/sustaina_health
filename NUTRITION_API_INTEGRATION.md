# Nutrition API Integration

This document describes the integration of the fitness-tribe-ai nutrition API endpoints into the SustainaHealth app.

## Overview

The nutrition features now use the [fitness-tribe-ai](https://github.com/mohamed-12-4/fitness-tribe-ai) repository's API endpoints to provide:

1. **AI Food Recognition** - Analyze meal photos to identify foods and nutrition information
2. **AI Meal Plan Generation** - Generate personalized meal plans based on user preferences

## API Endpoints Used

### 1. Meal Analysis (`POST /meals/analyze`)

Analyzes uploaded meal photos to identify foods, calculate nutrition, and provide sustainability scores.

**Request:**
```json
{
  "image": "base64_encoded_image",
  "meal_type": "breakfast|lunch|dinner|snack" // optional
}
```

**Response:**
```json
{
  "identified_foods": ["Apple", "Banana"],
  "confidence": 0.92,
  "portion_size": "1 medium apple, 1 medium banana",
  "nutrition_info": {
    "calories": 285,
    "carbohydrates": 45,
    "protein": 15,
    "fat": 8,
    "fiber": 7,
    "sugar": 35,
    "sodium": 60
  },
  "sustainability_score": "High",
  "suggestions": ["Great choice! These foods are nutrient-dense."]
}
```

### 2. Meal Plan Generation (`POST /meal-plans/generate`)

Generates personalized meal plans based on user goals and preferences.

**Request:**
```json
{
  "goal": "weight_loss",
  "target_calories": 2000,
  "dietary_restrictions": ["vegetarian"],
  "allergies": ["nuts"],
  "meals_per_day": 3,
  "activity_level": "moderately_active",
  "preferred_cuisines": ["mediterranean"]
}
```

**Response:**
```json
{
  "breakfast": [
    {
      "description": "Oatmeal with berries",
      "ingredients": [
        {
          "ingredient": "Rolled oats",
          "quantity": "1/2 cup",
          "calories": 150
        }
      ],
      "total_calories": 425,
      "recipe": "Cook oats with water, top with berries."
    }
  ],
  "lunch": [...],
  "dinner": [...],
  "snacks": [...],
  "total_daily_calories": 2000,
  "daily_nutrition_summary": {
    "calories": 2000,
    "carbohydrates": 225,
    "protein": 125,
    "fat": 67,
    "fiber": 35,
    "sugar": 50,
    "sodium": 2000
  }
}
```

## Setup Instructions

### 1. Start the API Server

1. Clone the fitness-tribe-ai repository:
   ```bash
   git clone https://github.com/mohamed-12-4/fitness-tribe-ai
   cd fitness-tribe-ai
   ```

2. Install dependencies and start the server:
   ```bash
   pip install -r requirements.txt
   python -m uvicorn app.main:app --reload --port 8000
   ```

3. The API will be available at `http://localhost:8000`

### 2. Configure the App

Update the API base URL in `lib/features/nutrition/data/services/nutrition_api_service.dart`:

- **Android Emulator**: `http://10.0.2.2:8000`
- **iOS Simulator**: `http://localhost:8000`
- **Physical Device**: `http://YOUR_COMPUTER_IP:8000`

## Features Implemented

### 1. AI Food Recognition Screen
- **Location**: `lib/features/nutrition/presentation/screens/ai_food_recognition_screen.dart`
- **Features**:
  - Camera and gallery image selection
  - Real-time API status indicator
  - Detailed nutrition analysis display
  - Direct integration with food logging
  - AI suggestions and sustainability scoring

### 2. AI Meal Plan Generator Screen
- **Location**: `lib/features/nutrition/presentation/screens/ai_meal_plan_generator_screen.dart`
- **Features**:
  - Customizable nutrition goals
  - Dietary restrictions and allergies support
  - Activity level configuration
  - Generated meal plan viewing
  - Save meal plans locally

### 3. Enhanced Nutrition Home Screen
- **Location**: `lib/features/nutrition/presentation/screens/nutrition_home_screen.dart`
- **Features**:
  - Real-time daily nutrition summary
  - Progress tracking with visual indicators
  - Meal-specific food logging
  - API connectivity status

### 4. Integrated Food Logging
- **Location**: `lib/features/nutrition/presentation/screens/food_logging_screen.dart`
- **Features**:
  - Multiple input methods (camera, manual, barcode)
  - Integration with AI food recognition
  - Local storage of food entries
  - Comprehensive nutrition tracking

## Data Models

### Core Nutrition Models
- `MealAnalysisRequest/Response` - AI food recognition
- `MealPlanRequest/Response` - AI meal plan generation
- `FoodLogEntry` - Individual food log entries
- `NutritionInfo` - Detailed nutrition information
- `DailyNutritionSummary` - Daily aggregated nutrition data

### State Management
- **Riverpod Providers**: All nutrition features use Riverpod for state management
- **Local Storage**: SharedPreferences for food logs and saved meal plans
- **API Integration**: Centralized through `NutritionRepository`

## Architecture

```
lib/features/nutrition/
├── data/
│   ├── models/          # Data models and DTOs
│   ├── services/        # API service classes
│   └── repositories/    # Repository implementations
├── domain/
│   └── repositories/    # Repository interfaces
└── presentation/
    ├── providers/       # Riverpod state management
    └── screens/         # UI screens
```

## Error Handling

The integration includes comprehensive error handling:

1. **API Unavailable**: Falls back to mock data for testing
2. **Network Errors**: Graceful error messages with retry options
3. **Invalid Inputs**: Form validation and user guidance
4. **Image Processing**: Error handling for camera/gallery operations

## Testing

When the API server is not available, the app automatically uses mock data that demonstrates the full functionality:

- Mock meal analysis with realistic nutrition data
- Mock meal plans with sample recipes
- Full offline functionality for food logging

## Navigation

New routes added to the app router:

- `/nutrition/ai-recognition` - AI Food Recognition
- `/nutrition/ai-meal-plan` - AI Meal Plan Generator
- `/nutrition/food-logging` - Food Logging
- `/nutrition/insights` - Nutrition Insights

## Future Enhancements

Potential improvements for the nutrition integration:

1. **Real-time Synchronization**: Sync data with backend when available
2. **Offline Capabilities**: Enhanced offline meal planning
3. **Social Features**: Share meal plans and achievements
4. **Advanced Analytics**: Detailed nutrition trends and insights
5. **Integration with Wearables**: Import data from fitness trackers
6. **Recipe Generation**: AI-powered recipe creation
7. **Shopping Lists**: Automatic grocery list generation from meal plans

## Dependencies

The nutrition integration uses these key dependencies:

- `flutter_riverpod`: State management
- `shared_preferences`: Local data storage
- `image_picker`: Camera and gallery integration
- `http`: API communication
- `uuid`: Unique identifier generation

All dependencies are already included in the project's `pubspec.yaml`.
