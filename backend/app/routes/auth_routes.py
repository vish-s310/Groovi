import random
from flask import Blueprint, request, jsonify
from app.models.user import User
from app.models.otp import OTP
from app import db

auth_bp = Blueprint('auth', __name__, url_prefix="/auth")
@auth_bp.route("/ping", methods=["GET", "OPTIONS"])
def ping():
    if request.method == "OPTIONS":
        return '', 200
    return jsonify({"message": "Groovi backend is live!"}), 200

@auth_bp.route("/register", methods=["POST"])
def register():
    """
    Register user by phone number
    ---
    tags:
      - Auth
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              phone:
                type: string
                example: "9876543210"
    responses:
      200:
        description: OTP sent
      400:
        description: Missing phone
    """
    data = request.json
    phone = data.get("phone")

    if not phone:
        return jsonify({"error": "Phone number is required"}), 400

    code = str(random.randint(100000, 999999))

    otp = OTP(phone=phone, code=code)
    db.session.add(otp)
    db.session.commit()

    print(f"📲 OTP for {phone} is {code} (simulated)")  # Mock for now
    return jsonify({"message": f"OTP sent to {phone}"}), 200


@auth_bp.route("/verify", methods=["POST"])
def verify():
    """
    Verify OTP and login/register user
    ---
    tags:
      - Auth
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              phone:
                type: string
                example: "some phone number as a string"
              code:
                type: string
                example: "some otp as a string, using mock otp for dev but will use sms in deployment"
    responses:
      200:
        description: User verified
      400:
        description: Invalid or expired OTP
    """
    data = request.json
    phone = data.get("phone")
    code = data.get("code")

    otp = OTP.query.filter_by(phone=phone, code=code).order_by(OTP.created_at.desc()).first()

    if not otp or otp.is_expired():
        return jsonify({"error": "Invalid or expired OTP"}), 400

    user = User.query.filter_by(phone=phone).first()
    if not user:
        user = User(phone=phone)
        db.session.add(user)
    
    db.session.commit()
    return jsonify({"message": "User verified", "user_id": user.id}), 200
@auth_bp.route("/update_profile", methods=["POST"])
def update_profile():
    """
    Update profile details
    ---
    tags:
      - Auth
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            properties:
              user_id:
                type: integer
                example: 1
              name:
                type: string
                example: "Mangaboi"
              bio:
                type: string
                example: "Guitar baja leta hoon"
              profile_pic:
                type: string
                example: "some url idk lol"
    responses:
      200:
        description: Profile updated
      404:
        description: User not found
    """
    data = request.json
    user_id = data.get("user_id")
    name = data.get("name")
    bio = data.get("bio")
    profile_pic = data.get("profile_pic")

    user = User.query.get(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404

    user.name = name or user.name
    user.bio = bio or user.bio
    user.profile_pic = profile_pic or user.profile_pic

    db.session.commit()
    return jsonify({"message": "Profile updated"}), 200
