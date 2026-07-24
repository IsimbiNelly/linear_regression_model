# Youth Unemployment Predictor (Africa)

## Mission
This project applies machine learning to predict youth unemployment rates across African countries, aligning with my mission to use technology to empower Africans especially young people and women through data-driven insights that support workforce development, informed decision-making and sustainable economic opportunity.

## Live API
Base URL: https://youth-unemployment-api.onrender.com
Interactive Swagger docs: https://youth-unemployment-api.onrender.com/docs
(Note: the API is hosted on Render's free tier, so it may take 30–60 seconds to wake up if it hasn't been used recently.)

## Demo Video
[YouTube Demo Video](PASTE_YOUTUBE_LINK_HERE)

## Project Structure
```
summative/
├── linear_regression/   # Data analysis + model training notebook
├── API/                 # FastAPI backend (deployed to Render)
└── FlutterApp/           # Mobile app (Flutter)
```

## Running the Mobile App

### Requirements
- Flutter SDK installed
- A physical Android device (with USB debugging enabled) or an emulator

### Steps
1. Clone this repository:
```
   git clone https://github.com/IsimbiNelly/linear_regression_model.git
```
2. Navigate to the Flutter app folder:
```
   cd linear_regression_model/summative/FlutterApp
```
3. Get the dependencies:
```
   flutter pub get
```
4. Connect your Android device or start an emulator, then check it's detected:
```
   flutter devices
```
5. Run the app:
```
   flutter run
```
6. Fill in the prediction form (Country, Sex, Age Group, Year) and tap **Predict** to get a live prediction from the deployed API.