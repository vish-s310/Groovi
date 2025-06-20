from flask import Flask
from app.extensions import db
from flask_cors import CORS
from dotenv import load_dotenv
from app.routes.graph_routes import graph_bp
from app.routes.friend_routes import friend_bp
from app.routes.block_routes import block_bp
import os

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
    app.register_blueprint(graph_bp)
    app.register_blueprint(friend_bp)
    app.register_blueprint(block_bp)
    return app

    
