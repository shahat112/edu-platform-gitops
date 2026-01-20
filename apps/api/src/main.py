from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session
import redis
import clickhouse_driver
from datetime import datetime
import json

from . import models, schemas, services
from .database import SessionLocal, engine
from .config import settings

# Создание таблиц в PostgreSQL
models.Base.metadata.create_all(bind=engine)

app = FastAPI(title="Edu Platform API", version="1.0.0")

# Настройка CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Подключение к Redis
redis_client = redis.Redis(
    host=settings.REDIS_HOST,
    port=settings.REDIS_PORT,
    password=settings.REDIS_PASSWORD,
    decode_responses=True
)

# Подключение к ClickHouse
clickhouse_client = clickhouse_driver.Client(
    host=settings.CLICKHOUSE_HOST,
    port=settings.CLICKHOUSE_PORT,
    user=settings.CLICKHOUSE_USER,
    password=settings.CLICKHOUSE_PASSWORD,
    database=settings.CLICKHOUSE_DB
)

# Dependency для получения БД сессии
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

@app.get("/")
def read_root():
    return {"message": "Edu Platform API", "status": "running"}

@app.get("/health")
def health_check():
    """Health check endpoint для мониторинга"""
    try:
        # Проверка PostgreSQL
        db = SessionLocal()
        db.execute("SELECT 1")
        db.close()
        
        # Проверка Redis
        redis_client.ping()
        
        # Проверка ClickHouse
        clickhouse_client.execute("SELECT 1")
        
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "services": {
                "postgresql": "ok",
                "redis": "ok",
                "clickhouse": "ok"
            }
        }
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"Service unavailable: {str(e)}")

@app.post("/users/")
def create_user(user: schemas.UserCreate, db: Session = Depends(get_db)):
    """Создание пользователя"""
    db_user = services.create_user(db, user)
    # Кэшируем в Redis
    redis_client.setex(f"user:{db_user.id}", 3600, json.dumps(db_user.to_dict()))
    # Логируем в ClickHouse для аналитики
    clickhouse_client.execute(
        "INSERT INTO user_events (user_id, event_type, timestamp) VALUES",
        [(db_user.id, "user_created", datetime.utcnow())]
    )
    return db_user

@app.get("/users/{user_id}")
def get_user(user_id: int, db: Session = Depends(get_db)):
    """Получение пользователя (с кэшированием)"""
    # Пробуем получить из кэша
    cached = redis_client.get(f"user:{user_id}")
    if cached:
        return json.loads(cached)
    
    # Если нет в кэше, получаем из БД
    db_user = services.get_user(db, user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Сохраняем в кэш
    redis_client.setex(f"user:{user_id}", 3600, json.dumps(db_user.to_dict()))
    return db_user

@app.get("/stats")
def get_stats():
    """Получение статистики из ClickHouse"""
    result = clickhouse_client.execute(
        "SELECT event_type, count() as count FROM user_events GROUP BY event_type"
    )
    return {"statistics": dict(result)}

@app.get("/cache-test")
def cache_test():
    """Тест Redis кэширования"""
    count = redis_client.incr("visit_count")
    return {"visit_count": count, "message": "Cache is working!"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
