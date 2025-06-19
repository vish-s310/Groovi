import random
from flask import Blueprint, request, jsonify
from app.models.user import User
from app.models.otp import OTP
from app import db
from app.graph import add_user_node 

auth_bp = Blueprint('auth', __name__, url_prefix="/auth")

@auth_bp.route("/ping", methods=["GET", "OPTIONS"])
def ping():
    if request.method == "OPTIONS":
        return '', 200
    return jsonify({"message": "Groovi backend up and running!"}), 200


@auth_bp.route("/register", methods=["POST"])
def register():
    data = request.json
    phone = data.get("phone")

    if not phone:
        return jsonify({"error": "Phone number is required"}), 400

    code = str(random.randint(100000, 999999))
    otp = OTP(phone=phone, code=code)
    db.session.add(otp)
    db.session.commit()

    print(f"OTP for {phone} is {code} (simulated)")
    return jsonify({"message": f"OTP sent to {phone}"}), 200


@auth_bp.route("/verify", methods=["POST"])
def verify():
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
        add_user_node(user.id, "") 
    else:
        db.session.commit()
    return jsonify({"message": "User verified", "user_id": user.id}), 200


@auth_bp.route("/update_profile", methods=["POST"])
def update_profile():
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
    add_user_node(user.id, user.name) 
    return jsonify({"message": "Profile updated"}), 200
