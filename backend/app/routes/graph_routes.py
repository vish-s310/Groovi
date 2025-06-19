from flask import Blueprint, request, jsonify
from app.graph import add_user_node
from app.models.user import User

graph_bp = Blueprint('graph', __name__, url_prefix="/graph")

@graph_bp.route("/add_user", methods=["POST"])
def add_user():
    data = request.json
    user_id = data.get("id")
    user = User.query.get(user_id)

    if not user:
        return jsonify({"error": "User not found"}), 404

    add_user_node(user.id, user.name)
    return jsonify({"message": "User added to graph"}), 200
