from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
from typing import Literal
import joblib
import pandas as pd
import os

# Load our saved model, scaler, and feature list
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
model = joblib.load(os.path.join(BASE_DIR, "best_model.pkl"))
scaler = joblib.load(os.path.join(BASE_DIR, "scaler.pkl"))
feature_columns = joblib.load(os.path.join(BASE_DIR, "feature_columns.pkl"))

# List of African countries our model was trained on
african_countries = [
    "Algeria", "Angola", "Benin", "Botswana", "Burkina Faso", "Burundi",
    "Cabo Verde", "Cameroon", "Central African Republic", "Chad", "Comoros",
    "Congo", "Congo, Democratic Republic of the", "Ivory Coast", "Djibouti", "Egypt",
    "Equatorial Guinea", "Eritrea", "Eswatini", "Ethiopia", "Gabon", "Gambia",
    "Ghana", "Guinea", "Guinea-Bissau", "Kenya", "Lesotho", "Liberia", "Libya",
    "Madagascar", "Malawi", "Mali", "Mauritania", "Mauritius", "Morocco",
    "Mozambique", "Namibia", "Niger", "Nigeria", "Rwanda",
    "Sao Tome and Principe", "Senegal", "Sierra Leone",
    "Somalia", "South Africa", "South Sudan", "Sudan", "Tanzania, United Republic of", "Togo",
    "Tunisia", "Uganda", "Zambia", "Zimbabwe"
]

app = FastAPI(title="African Youth Unemployment Prediction API")

# CORS Configuration:
# - allow_origins: This API is primarily consumed by a native Flutter mobile app, which is not
#   subject to browser CORS restrictions. However, since the app may also be tested as Flutter Web
#   during development, we explicitly allow common local development origins (localhost variants)
#   so browser-based testing isn't blocked.
# - allow_credentials: False, since we don't use cookies or authentication sessions.
# - allow_methods: Restricted to GET and POST, since those are the only operations this API supports.
# - allow_headers: Restricted to Content-Type, since that's all a JSON POST request needs.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost",
        "http://localhost:8000",
        "http://localhost:3000",
        "http://127.0.0.1",
        "http://127.0.0.1:8000",
        "http://127.0.0.1:3000",
    ],
    allow_credentials=False,
    allow_methods=["GET", "POST"],
    allow_headers=["Content-Type"],
)

# Defines exactly what a valid "knock" (request) must look like
class PredictionInput(BaseModel):
    country: Literal[tuple(african_countries)] = Field(..., description="African country name")
    sex: Literal["Male", "Female"] = Field(..., description="Sex")
    age_group: Literal["Under 15", "15-24", "25+"] = Field(..., description="Age group")
    year: int = Field(..., ge=2014, le=2030, description="Year between 2014 and 2030")

@app.get("/")
def read_root():
    return {"message": "Welcome to the African Youth Unemployment Prediction API. Visit /docs for Swagger UI."}

@app.post("/predict")
def predict(input_data: PredictionInput):
    try:
        row = pd.DataFrame(0, index=[0], columns=feature_columns)
        row["year"] = input_data.year
        row["sex_encoded"] = 1 if input_data.sex == "Female" else 0
        age_map = {"Under 15": 0, "15-24": 1, "25+": 2}
        row["age_group_encoded"] = age_map[input_data.age_group]

        country_col = f"country_{input_data.country}"
        if country_col in row.columns:
            row[country_col] = 1

        row_scaled = scaler.transform(row)
        prediction = model.predict(row_scaled)[0]

        return {
            "country": input_data.country,
            "sex": input_data.sex,
            "age_group": input_data.age_group,
            "year": input_data.year,
            "predicted_unemployment_rate": round(float(prediction), 3)
        }
    except Exception as e:
        raise HTTPException(status_code=400, detail=str(e))