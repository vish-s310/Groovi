from flask import Blueprint, request, jsonify
from app.models.hangout import Hangout
from app import db

hangout_bp = Blueprint('hangout', __name__, url_prefix="/hangout")

@hangout_bp.route("/send", methods=["POST"])
def send_hangout():
    """
    Send a hangout request to one or more users
    ---
    tags:
      - Hangouts
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              host_id:
                type: integer
                example: 1
              recipient_ids:
                type: array
                items:
                  type: integer
                example: [2, 3]
              message:
                type: string
                example: "Gedi maare aaj?"
    responses:
      200:
        description: Hangout created
    """
    data = request.json
    host_id = data.get("host_id")
    invitee_ids = data.get("invitee_ids")
    message = data.get("message")
    activity = data.get("activity")

    if not host_id or not invitee_ids:
        return jsonify({"error": "Host and invitees are required"}), 400

    hangout = Hangout(
        host_id=host_id,
        invitee_ids=invitee_ids,
        message=message,
        activity=activity,
        status="pending"
    )

    db.session.add(hangout)
    db.session.commit()

    return jsonify({"message": "Hangout sent", "hangout": hangout.to_dict()}), 200

@hangout_bp.route("/respond", methods=["POST"])
def respond_hangout():
    """
    Accept or reject a hangout invite
    ---
    tags:
      - Hangouts
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              hangout_id:
                type: integer
                example: 12
              user_id:
                type: integer
                example: 3
              status:
                type: string
                enum: [accepted, rejected]
                example: accepted
    responses:
      200:
        description: Response recorded
    """
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
    """
    Get all hangouts involving user with whatev user id entered :)
    ---
    tags:
      - Hangouts
    parameters:
      - name: user_id
        in: path
        type: integer
        required: true
        example: 1
    responses:
      200:
        description: Hangouts list
    """
    sent = Hangout.query.filter_by(host_id=user_id).all()
    received = Hangout.query.filter(Hangout.invitee_ids.any(user_id)).all()

    return jsonify({
        "sent": [h.to_dict() for h in sent],
        "received": [h.to_dict() for h in received]
    }), 200
