# MathPro Enterprise v4.0

This is the next full-scale foundation build.

## New in v4.0
- SQLite-backed persistent assignment bank.
- Created assignments survive backend restarts.
- Assignment preview still works with generated sample questions.
- Assignment delete backend endpoint added.
- Backend database auto-initializes on startup.
- Expanded catalog from v3.3 preserved.
- Dynamic Programming and Stochastic Calculus remain under Graduate Mathematics.
- Olympiad Mathematics retained.

## Important
SQLite is good for local development. For cloud production, the next step should be PostgreSQL.

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

## Commit to GitHub

```powershell
git checkout -b fullscale-v4
git add .
git commit -m "Add MathPro Enterprise v4 persistent assignment bank"
git push -u origin fullscale-v4
```
