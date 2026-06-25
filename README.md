# MathPro Enterprise v3.3

This version fixes the latest reported issues.

## Fixed in v3.3
- Restored/expanded course catalog.
- Added Graduate Mathematics topics:
  - Dynamic Programming
  - Stochastic Calculus
- Added wider fields:
  - Primary Mathematics
  - Differential Equations
  - Integral Equations
  - Probability and Statistics
  - Operations Research
  - Graduate Mathematics
- Reintroduced safe LaTeX rendering using `MathDisplay`.
- Fixed PDE display such as `u_{tt}=25u_{xx}`.
- Assignment Preview buttons now open a preview screen.
- Assignment preview displays sample questions and answers.
- Teacher assignment bank remains refreshed after returning from assignment creation.

## Important
Assignments still persist only while the FastAPI backend is running. Permanent persistence requires the next database build.

## Run backend

```powershell
cd backend
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
python -m uvicorn app.main:app --reload
```

## Run frontend

```powershell
cd frontend_flutter
flutter clean
flutter pub get
flutter run -d chrome
```
