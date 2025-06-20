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
def direct_friend(user_id, target_id):
    with driver.session() as session:
        result = session.run("""
            MATCH (a:User {id: $user_id})-[:FRIEND]-(b:User {id: $target_id})
            RETURN COUNT(*) > 0 AS is_friend
        """, user_id=user_id, target_id=target_id)
        return result.single()["is_friend"]

def second_degree(user_id, target_id):
    with driver.session() as session:
        result = session.run("""
            MATCH (a:User {id: $user_id})-[:FRIEND]-(common)-[:FRIEND]-(b:User {id: $target_id})
            WHERE NOT (a)-[:FRIEND]-(b)
            RETURN COUNT(*) > 0 AS is_second_degree
        """, user_id=user_id, target_id=target_id)
        return result.single()["is_second_degree"]

def request_second_degree_approval(user_id, target_id, approver_id):
    with driver.session() as session:
        session.run("""
            MATCH (a:User {id: $user_id}), (b:User {id: $target_id}), (approver:User {id: $approver_id})
            CREATE (a)-[:PENDING_APPROVAL {by: approver_id}]->(b)
        """, user_id=user_id, target_id=target_id, approver_id=approver_id)

def approve_second_degree(user_id, target_id):
    with driver.session() as session:
        session.run("""
            MATCH (a:User {id: $user_id})-[r:PENDING_APPROVAL]->(b:User {id: $target_id})
            DELETE r
            CREATE (a)-[:APPROVED_SECOND_DEGREE]->(b)
        """, user_id=user_id, target_id=target_id)

def get_mutual_friends(user_id, target_id):
    """
    Returns a list of user IDs who are mutual friends of user_id and target_id
    """
    with driver.session() as session:
        result = session.run("""
            MATCH (a:User {id: $user_id})-[:FRIEND]-(mutual)-[:FRIEND]-(b:User {id: $target_id})
            RETURN DISTINCT mutual.id AS mutual_id
        """, user_id=user_id, target_id=target_id)

        return [record["mutual_id"] for record in result]


def get_friend_suggestions(user_id):
    with driver.session() as session:
        result = session.run("""
            MATCH (a:User {id: $user_id})-[:FRIEND]-(friend)-[:FRIEND]-(suggested:User)
            WHERE NOT (a)-[:FRIEND]-(suggested)
              AND NOT (a)-[:BLOCKED]-(suggested)
              AND suggested.id <> $user_id
            RETURN DISTINCT suggested.id AS suggestion_id
        """, user_id=user_id)

        return [record["suggestion_id"] for record in result]

    
def block_user(blocker_id, blocked_id):
    with driver.session() as session:
        session.run("""
            MATCH (a:User {id: $blocker_id}), (b:User {id: $blocked_id})
            MERGE (a)-[:BLOCKED]->(b)
            WITH a, b
            MATCH (a)-[f:FRIEND]-(b)
            DELETE f
        """, blocker_id=blocker_id, blocked_id=blocked_id)
def unblock_user(blocker_id, blocked_id):
    with driver.session() as session:
        session.run("""
            MATCH (a:User {id: $blocker_id})-[r:BLOCKED]->(b:User {id: $blocked_id})
            DELETE r
        """, blocker_id=blocker_id, blocked_id=blocked_id)
def degrees_of_separation(user_id, target_id, max_depth=5):
    """
    Returns the number of hops (degrees) between two users, or None if not connected
    """
    with driver.session() as session:
        result = session.run("""
            MATCH (a:User {id: $user_id}), (b:User {id: $target_id}),
                  path = shortestPath((a)-[:FRIEND*..$max_depth]-(b))
            RETURN length(path) AS degree
        """, user_id=user_id, target_id=target_id, max_depth=max_depth)

        record = result.single()
        return record["degree"] if record else None

def get_pending_approvals(user_id):
    """
    Returns a list of users who have pending approval with user_id
    """
    with driver.session() as session:
        result = session.run("""
            MATCH (:User {id: $user_id})-[r:PENDING_APPROVAL]->(other:User)
            RETURN other.id AS pending_id
        """, user_id=user_id)
        return [record["pending_id"] for record in result]
def check_approved_second_degree(user_id, target_id):
    with driver.session() as session:
        result = session.run("""
            MATCH (a:User {id: $user_id})-[:APPROVED_SECOND_DEGREE]->(b:User {id: $target_id})
            RETURN COUNT(*) > 0 AS approved
        """, user_id=user_id, target_id=target_id)
        return result.single()["approved"]
