from flask import Blueprint, request, jsonify
from app.models.hangout import Hangout
from app import db
from app.graph import create_hangout_node

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

    if not host_id or not invitee_ids:
        return jsonify({"error": "Host and invitees are required"}), 400

    hangout = Hangout(
        host_id=host_id,
        invitee_ids=invitee_ids,
        message=message,
        activity=activity,
        time=time,
        location=location,
        status="pending"
    )

    db.session.add(hangout)
    db.session.commit()

    return jsonify({"message": "Hangout sent", "hangout": hangout.to_dict()}), 200


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
    
 create_hangout_node(host_id, invitee_ids, activity)

    return jsonify({
        "sent": [h.to_dict() for h in sent],
        "received": [h.to_dict() for h in received]
    }), 200
   
