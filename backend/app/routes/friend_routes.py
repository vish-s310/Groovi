from flask import Blueprint, request, jsonify
from app.graph import add_primary_friends

friend_bp = Blueprint('friend', __name__, url_prefix='/friends')

@friend_bp.route('/select', methods=['POST'])
def select_primary_friends():
    data = request.json
    user_id = data.get('user_id')
    friend_ids = data.get('friend_ids')

    if not user_id or not friend_ids:
        return jsonify({"error": "user_id and friend_ids are required"}), 400

    for fid in friend_ids:
        add_primary_friends(user_id, fid)
 
    return jsonify({"message": "Primary friends added successfully"}), 200

@friend_bp.route("/approve_second_degree", methods=["POST"])
def approve_second_degree_connection():
    data = request.json
    user_id = data["user_id"]
    target_id = data["target_id"]

    if not user_id or not target_id:
        return jsonify({"error": "user_id and target_id are required"}), 400
        
    approve_second_degree(user_id, target_id)
    return jsonify({"message": "2nd-degree connection approved"}), 200
