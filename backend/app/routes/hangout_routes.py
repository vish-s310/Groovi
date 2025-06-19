from flask import Blueprint, request, jsonify
from app.models.hangout import Hangout
from app import db

from app.graph import (
    create_hangout_node,
    direct_friend,
    second_degree,
    check_approved_second_degree,
    request_second_degree_approval
)

hangout_bp = Blueprint('hangout', __name__, url_prefix="/hangout")

@hangout_bp.route("/send", methods=["POST"])
def send_hangout():
    data = request.json
    host_id = data.get("host_id")
    invitee_ids = data.get("invitee_ids")
    message = data.get("message")
    activity = data.get("activity")
    time = data.get("time")
    location = data.get("location")
    approver_map = data.get("approver_map", {})

    if not host_id or not invitee_ids:
        return jsonify({"error": "Host and invitees are required"}), 400

    allowed_invitees = []
    pending_approval = []

    for invitee_id in invitee_ids:
        if direct_friend(host_id, invitee_id):
            allowed_invitees.append(invitee_id)
        elif second_degree(host_id, invitee_id):
            if check_approved_second_degree(host_id, invitee_id):
                allowed_invitees.append(invitee_id)
            else:
                approver_id = approver_map.get(invitee_id)
                if approver_id:
                    request_second_degree_approval(host_id, invitee_id, approver_id)
                pending_approval.append(invitee_id)

    if allowed_invitees:
        hangout = Hangout(
            host_id=host_id,
            invitee_ids=allowed_invitees,  # ✅ fix: use filtered list
            message=message,
            activity=activity,
            time=time,
            location=location,
            status="pending"
        )

        db.session.add(hangout)
        db.session.commit()
        create_hangout_node(host_id, allowed_invitees, activity)
        hangout_data = hangout.to_dict()
    else:
        hangout_data = None

    return jsonify({
        "message": "Hangout processed",
        "invited": allowed_invitees,
        "pending_approval": pending_approval,
        "hangout": hangout_data
    }), 200


@hangout_bp.route("/respond", methods=["POST"])
def respond_hangout():
    data = request.json
    hangout_id = data.get("hangout_id")
    user_id = data.get("user_id")
    response = data.get("response")

    hangout = Hangout.query.get(hangout_id)
    if not hangout:
        return jsonify({"error": "Hangout not found"}), 404

    if user_id not in hangout.invitee_ids:
        return jsonify({"error": "You are not invited to this hangout"}), 403

    if response == "accepted":
        hangout.status = "approved"
    elif response == "declined":
        hangout.status = "rejected"
    else:
        return jsonify({"error": "Invalid response"}), 400

    db.session.commit()
    return jsonify({"message": f"Hangout {response}"}), 200


@hangout_bp.route("/mine/<int:user_id>", methods=["GET"])
def my_hangouts(user_id):
    sent = Hangout.query.filter_by(host_id=user_id).all()
    received = Hangout.query.filter(Hangout.invitee_ids.any(user_id)).all()

    return jsonify({
        "sent": [h.to_dict() for h in sent],
        "received": [h.to_dict() for h in received]
    }), 200
