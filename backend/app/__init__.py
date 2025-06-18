from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_cors import CORS
from dotenv import load_dotenv
import os

db = SQLAlchemy()

def create_app():
    load_dotenv()

    app = Flask(__name__)
    CORS(app, resources={r"/*": {"origins": "*"}}, supports_credentials=True)
    app.config.from_object('app.config.Config')

    db.init_app(app)
    from app.routes.auth_routes import auth_bp
    app.register_blueprint(auth_bp)
    from app.routes.hangout_routes import hangout_bp
    app.register_blueprint(hangout_bp)

    return app

