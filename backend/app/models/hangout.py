from app.extensions import db
from datetime import datetime
from sqlalchemy.dialects.postgresql import ARRAY

class Hangout(db.Model):
    __tablename__ = 'hangouts'

    id = db.Column(db.Integer, primary_key=True)
    host_id = db.Column(db.Integer, db.ForeignKey('users.id'), nullable=False)
    invitee_ids = db.Column(ARRAY(db.Integer), nullable=False) 
    message = db.Column(db.String(255))
    activity = db.Column(db.String(100))
    time = db.Column(db.String(50))        
    location = db.Column(db.String(100))    
    status = db.Column(db.String(20), default="pending") 
    created_at = db.Column(db.DateTime, default=datetime.utcnow)

    def to_dict(self):
        return {
            "id": self.id,
            "host_id": self.host_id,
            "invitee_ids": self.invitee_ids,
            "message": self.message,
            "activity": self.activity,
            "time": self.time,
            "location": self.location,
            "status": self.status,
            "created_at": self.created_at.isoformat()
        }
