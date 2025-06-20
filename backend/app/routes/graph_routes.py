from flask import Blueprint, request, jsonify
from app.graph import add_user_node
from app.graph import get_mutual_friends
from app.graph import get_friend_suggestions
from app.models.user import User


graph_bp = Blueprint('graph', __name__, url_prefix="/graph")

@graph_bp.route("/add_user", methods=["POST"])
def add_user():
    data = request.json
    user_id = data.get("id")

    if not user_id:
        return jsonify({"error": "User ID is required"}), 400

    try:
        user_id = int(user_id)
    except (TypeError, ValueError):
        return jsonify({"error": "Invalid user ID"}), 400

    user = User.query.get(user_id)

    if not user:
        return jsonify({"error": "User not found"}), 404

    add_user_node(user.id, user.name)
    return jsonify({"message": "User added to graph"}), 200


@graph_bp.route("/mutuals", methods=["GET"])
def mutual_friends():
    user_id = request.args.get("user_id", type=int)
    target_id = request.args.get("target_id", type=int)
    if not user_id or not target_id:
        return jsonify({"error": "Both user_id and target_id required"}), 400

    mutuals = get_mutual_friends(user_id, target_id)
    return jsonify({"mutual_friends": mutuals})


@graph_bp.route("/suggestions", methods=["GET"])
def friend_suggestions():
    user_id = request.args.get("user_id", type=int)
    if not user_id:
        return jsonify({"error": "user_id required"}), 400

    suggestions = get_friend_suggestions(user_id)
    return jsonify({"suggestions": suggestions})

@graph_bp.route("/degrees", methods=["GET"])
def degrees():
    user_id = request.args.get("from", type=int)
    target_id = request.args.get("to", type=int)

    if not user_id or not target_id:
        return jsonify({"error": "Both from and to user IDs are required"}), 400

    from app.graph import degrees_of_separation
    degree = degrees_of_separation(user_id, target_id)

    if degree is None:
        return jsonify({"connected": False, "degree": None}), 200

    return jsonify({"connected": True, "degree": degree}), 200
