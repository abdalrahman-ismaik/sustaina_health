# AI Workout Generation Feature

## Overview

The AI Workout Generation feature allows users to create personalized workout plans using an external AI API. Users can input their personal information, fitness goals, available equipment, and preferences to generate customized workout plans.

## Features Implemented

### 1. Data Models

- **WorkoutPlan**: Complete workout plan structure
- **WorkoutSession**: Individual workout sessions
- **Exercise**: Individual exercises with sets, reps, and rest periods
- **WorkoutComponent**: Warmup, cardio, and cooldown components
- **UserProfile**: User's personal information and preferences

### 2. API Integration

- **WorkoutApiService**: Handles communication with the workout generation API
- Endpoint: `http://localhost:8000/workout-plans/generate`
- Health check functionality to verify API availability
- Error handling for network issues and API failures

### 3. State Management (Riverpod)

- **userProfileProvider**: Manages user profile data
- **workoutGenerationProvider**: Handles workout generation state
- **apiHealthProvider**: Monitors API availability
- **savedWorkoutsProvider**: Manages saved workouts

### 4. User Interface

#### AI Workout Generator Screen

- **Personal Information**: Weight, height, age, sex input
- **Fitness Goals**: Selectable goals (bulking, cutting, weight loss, etc.)
- **Workouts per Week**: Slider for selecting frequency (1-7 times)
- **Equipment Selection**: Multi-select equipment options
- **API Status Indicator**: Shows if the API server is running
- **Real-time Validation**: Ensures all required fields are filled
- **Workout Preview**: Shows generated workout summary

#### Workout Detail Screen

- **Plan Overview**: Sessions per week, total sessions
- **Component Details**: Warmup, cardio, cooldown information
- **Tabbed Sessions**: Each workout session in separate tabs
- **Exercise List**: Detailed exercise information with sets, reps, rest
- **Action Buttons**: Start workout, save workout options

## How to Use

### Prerequisites

1. Start the AI workout API server at `http://localhost:8000`
2. Ensure the app has internet connectivity

### Using the Feature

1. **Navigate** to the AI Workout Generator from the Exercise section
2. **Check API Status** - Green indicator means API is available
3. **Fill Personal Info**: Enter weight (kg), height (cm), age, and sex
4. **Select Fitness Goal**: Choose from available options
5. **Set Frequency**: Use slider to select workouts per week
6. **Choose Equipment**: Select available equipment from the chips
7. **Generate Workout**: Tap the generate button
8. **View Results**: See workout preview and tap "View Details" for full plan
9. **Save Workout**: Optionally save the workout for later use

### API Request Format

```json
{
  "weight": 70,
  "height": 175,
  "age": 25,
  "sex": "male",
  "goal": "bulking",
  "workouts_per_week": 3,
  "equipment": ["dumbbells", "barbell", "resistance bands"]
}
```

### API Response Structure

The API returns a comprehensive workout plan including:

- Warmup instructions and duration
- Cardio recommendations
- Multiple workout sessions with exercises
- Cooldown instructions
- Sets, reps, and rest periods for each exercise

## Equipment Options

- dumbbells
- barbell
- resistance bands
- kettlebells
- pull-up bar
- bench
- cable machine
- treadmill
- stationary bike
- yoga mat
- foam roller
- medicine ball

## Fitness Goals

- bulking (muscle building)
- cutting (fat loss while maintaining muscle)
- weight_loss (general weight reduction)
- general_fitness (overall health)
- strength (strength building)
- endurance (cardiovascular fitness)

## Error Handling

- **API Unavailable**: Clear error message with instructions
- **Invalid Input**: Form validation with helpful messages
- **Network Errors**: Graceful error handling with retry options
- **Missing Data**: Guided prompts to complete required fields

## Data Persistence

- User profiles are stored locally using Riverpod state management
- Generated workouts can be saved locally using SharedPreferences
- Workout history is maintained for easy access

## Future Enhancements

- Workout execution with timer functionality
- Progress tracking and analytics
- Social sharing features
- Offline workout generation
- Integration with wearable devices
- Nutrition recommendations based on fitness goals

## Technical Architecture

```
├── data/
│   ├── models/          # Data models
│   ├── services/        # API services
│   └── repositories/    # Repository implementations
├── domain/
│   └── repositories/    # Repository interfaces
└── presentation/
    ├── providers/       # Riverpod providers
    └── screens/         # UI screens
```

## Dependencies Added

- http: ^1.1.0 (already included)
- shared_preferences (for local storage)
- flutter_riverpod (for state management)

This feature provides a complete workout generation experience that integrates seamlessly with the existing SustainaHealth app architecture.
