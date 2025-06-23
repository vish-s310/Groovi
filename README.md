# 📱 Groovi – Mobile Social Graph App for Spontaneous Hangouts

Groovi is a graph-based social networking and hangout planning mobile application designed to help users connect with their 1st-degree (direct) and 2nd-degree (mutual) friends in real time.

It uses a Neo4j graph database to model user relationships and social approvals, a Flask REST API as the backend, and a Flutter mobile application as the frontend interface. The app is designed with privacy, mutual consent, and casual discoverability in mind.

## 🧩 Problem Statement

Develop a mobile app that enables users to plan casual hangouts with their 1st and 2nd-degree connections. During onboarding, users select their top 8 close friends and create a profile with their name, bio, and images. Mobile number verification is done via OTP through the terminal (no SMS). Users can view a graph-based network of connections, select people to hang out with, add an optional activity message, and send hangout requests. Requests to 2nd-degree connections require mutual friend approval for the first time.

Technologies used:

Layer                    Tech Stack             
Frontend                 Flutter
Backend                  Flask
REST API                 Flask-RESTful
Database                 SQLAlchemy
Graph DB                 Neo4j
Auth/OTP                 Terminal-based OTP Simulation
Dev Tools                Git, Neo4j Browser, Android Studio, Swagger, Postman, Docker

    
 Features
     
     User Onboarding
     
Mobile number input with OTP-based (terminal simulated) authentication.


Profile setup: full name, bio, profile picture.


Selection of top N (default 8) friends from contacts as 1st-degree connections.


All user data stored in PostgreSQL.


     Graph Network View
     
Visualizes:


Nodes: users


Edges: friendship relationships


1st-degree: Direct connections


2nd-degree: Connections of your connections


Rendered in Flutter using a custom force-directed layout engine to support pan, zoom, and select.


     Hangout Planning
     
Select any user (1st or 2nd-degree) from the graph.


Add optional description: "walk", "jam session", "watch a movie".


Request is sent to selected users as a backend event with status pending.


 Mutual Approval Protocol:
 
Type                                 Requirement
1st-degree invite                    Direct invitation allowed.
2nd-degree invite                    Requires 1st-degree friend to approve once.


1. The approval gets stored in a separate approvals table and a CONNECTED_APPROVED edge in Neo4j.


2. Once approved once, further requests to that 2nd-degree user do not need additional approvals.


3. 2nd-degree connections are updated dynamically using shortest path traversal in Neo4j.




Contributors:

sampagavi

tridipta28

GeekyNerd2005

vish-s310
