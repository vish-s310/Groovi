from flask import Blueprint, request, jsonify
from app.extensions import db
from app.models.blocked_user import BlockedUser
from app.graph import unblock_user

block_bp = Blueprint('block', __name__, url_prefix='/block')

@block_bp.route('/unblock', methods=['POST'])
def unblock():
    data = request.json
    blocker_id = data.get("blocker_id")
    blocked_id = data.get("blocked_id")

    if not blocker_id or not blocked_id:
        return jsonify({"error": "blocker_id and blocked_id are required"}), 400

    block = BlockedUser.query.filter_by(blocker_id=blocker_id, blocked_id=blocked_id).first()
    if block:
        db.session.delete(block)
        db.session.commit()

    unblock_user(blocker_id, blocked_id)

    return jsonify({"message": "User unblocked"}), 200
@block_bp.route('/blocked_list', methods=['GET'])
def blocked_list():
    user_id = request.args.get("user_id", type=int)
    if not user_id:
        return jsonify({"error": "user_id required"}), 400

    blocked = BlockedUser.query.filter_by(blocker_id=user_id).all()
    result = [{"blocked_id": b.blocked_id} for b in blocked]

    return jsonify({"blocked_users": result}), 200
