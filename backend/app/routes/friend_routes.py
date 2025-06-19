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
