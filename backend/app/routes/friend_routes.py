from flask import Blueprint, request, jsonify
from app.extensions import db
from app.graph import add_primary_friends, approve_second_degree
from app.models.friendship import Friendship
from app.graph import block_user  
friend_bp = Blueprint('friend', __name__, url_prefix='/friends')


@friend_bp.route('/select', methods=['POST'])
def select_primary_friends():
    data = request.json
    user_id = data.get('user_id')
    friend_ids = data.get('friend_ids')

    if not user_id or not isinstance(friend_ids, list) or len(friend_ids) == 0:
        return jsonify({"error": "user_id and non-empty friend_ids list required"}), 400

    added = []
    skipped = []

    for fid in friend_ids:
        # Update Neo4j
        add_primary_friends(user_id, fid)

        # Enforce directional uniqueness: store only (smaller, larger)
        uid1, uid2 = sorted([user_id, fid])
        exists = Friendship.query.filter_by(user_id=uid1, friend_id=uid2).first()
        
        if not exists:
            db.session.add(Friendship(user_id=uid1, friend_id=uid2))
            added.append((uid1, uid2))
        else:
            skipped.append((uid1, uid2))

    db.session.commit()

    return jsonify({
        "message": "Primary friends processed.",
        "added": added,
        "skipped": skipped
    }), 200


@friend_bp.route("/approve_second_degree", methods=["POST"])
def approve_second_degree_connection():
    data = request.json
    user_id = data.get("user_id")
    target_id = data.get("target_id")

    if not user_id or not target_id:
        return jsonify({"error": "user_id and target_id are required"}), 400

    approve_second_degree(user_id, target_id)

    return jsonify({"message": "2nd-degree connection approved"}), 200

@friend_bp.route("/block", methods=["POST"])
def block():
    data = request.json
    blocker_id = data.get("blocker_id")
    blocked_id = data.get("blocked_id")

    if not blocker_id or not blocked_id:
        return jsonify({"error": "blocker_id and blocked_id required"}), 400

    uid1, uid2 = sorted([blocker_id, blocked_id])

    from app.models.blocked_user import BlockedUser
    exists = BlockedUser.query.filter_by(blocker_id=blocker_id, blocked_id=blocked_id).first()
    if not exists:
        db.session.add(BlockedUser(blocker_id=blocker_id, blocked_id=blocked_id))
        db.session.commit()

    from app.models.friendship import Friendship
    Friendship.query.filter_by(user_id=uid1, friend_id=uid2).delete()
    db.session.commit()

    block_user(blocker_id, blocked_id)

    return jsonify({"message": "User blocked"}), 200

@friend_bp.route("/pending_approvals", methods=["GET"])
def pending_approvals():
    user_id = request.args.get("user_id", type=int)
    if not user_id:
        return jsonify({"error": "user_id is required"}), 400

    from app.graph import get_pending_approvals
    pending = get_pending_approvals(user_id)
    return jsonify({"pending_approvals": pending}), 200
