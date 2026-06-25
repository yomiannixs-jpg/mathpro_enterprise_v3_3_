from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api.routes import router, init_db

app = FastAPI(title="MathPro Enterprise v4.0", version="4.0.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(router, prefix="/api")


@app.on_event("startup")
def startup():
    init_db()


@app.get("/")
def root():
    return {
        "status": "ok",
        "app": "MathPro Enterprise",
        "version": "4.0",
        "message": "Persistent assignment bank and full-scale foundation running",
    }
