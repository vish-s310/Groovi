import os
from dotenv import load_dotenv
from neo4j import GraphDatabase

load_dotenv()

NEO4J_URI = os.getenv("NEO4J_URI", "bolt://localhost:7687")
NEO4J_USER = os.getenv("NEO4J_USER", "neo4j")
NEO4J_PASSWORD = os.getenv("NEO4J_PASSWORD", "your-password")

driver = GraphDatabase.driver(NEO4J_URI, auth=(NEO4J_USER, NEO4J_PASSWORD))


def add_user_node(user_id, name):
    with driver.session() as session:
        session.run("""
            MERGE (u:User {id: $id})
            SET u.name = $name
        """, id=user_id, name=name)


def create_hangout_node(host_id, invitee_ids, activity):
    with driver.session() as session:
        session.run("""
            MATCH (host:User {id: $host_id})
            CREATE (h:Hangout {activity: $activity})
            CREATE (host)-[:HOSTED]->(h)
            WITH h
            UNWIND $invitee_ids AS invitee_id
            MATCH (invitee:User {id: invitee_id})
            CREATE (invitee)-[:INVITED]->(h)
        """, host_id=host_id, invitee_ids=invitee_ids, activity=activity)

def add_primary_friends(user_id, friend_id):
    with driver.session() as session:
        session.run("""
            MATCH (a:User {id: $user_id}), (b:User {id: $friend_id})
            MERGE (a)-[:FRIEND]->(b)
            MERGE (b)-[:FRIEND]->(a)
        """, user_id=user_id, friend_id=friend_id)

