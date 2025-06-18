from app import db
from datetime import datetime
class User(db.Model):
    __tablename__ = 'users'
    
    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    bio = db.Column(db.String(255))
    phone = db.Column(db.String(15), unique=True, nullable=False)
    profile_pic = db.Column(db.String(255))  
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
