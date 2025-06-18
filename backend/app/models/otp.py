from app import db
from datetime import datetime, timedelta
class OTP(db.Model):
    __tablename__ = 'otps'
    
    id = db.Column(db.Integer, primary_key=True)
    phone = db.Column(db.String(15), nullable=False)
    code = db.Column(db.String(6), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    
    def is_expired(self):
        return datetime.utcnow() > self.created_at + timedelta(minutes=5)
