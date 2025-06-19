from neo4j import GraphDatabase

driver = GraphDatabase.driver("bolt://localhost:7687", auth=("neo4j", "your-password"))

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
