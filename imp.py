import streamlit as st
import pandas as pd
import psycopg2
from config import DATABASE_CONFIG

# Connect to PostgreSQL
def connect_to_db():
    try:
        conn = psycopg2.connect(**DATABASE_CONFIG)
        return conn
    except Exception as e:
        st.error(f"Error connecting to the database: {e}")
        return None

# Execute a query and fetch results
def execute_query(query, params=None):
    conn = connect_to_db()
    if conn:
        try:
            cursor = conn.cursor()
            cursor.execute(query, params)
            if query.strip().upper().startswith("SELECT"):
                results = cursor.fetchall()
                columns = [desc[0] for desc in cursor.description]
                df = pd.DataFrame(results, columns=columns)
                return df
            conn.commit()
        except Exception as e:
            st.error(f"Error executing query: {e}")
        finally:
            cursor.close()
            conn.close()

# Streamlit App
def main():
    
    st.title("Football Database Application")

    # Sidebar for navigation
    menu = st.sidebar.selectbox(
        "Choose an Option",
        ["Home", "Data Management", "Insights and Analysis", "Custom Query"]
    )

    if menu == "Home":
        st.subheader("Welcome to the Football Database App")
        st.markdown("""
        - Manage your football data (CRUD operations).
        - Explore insights and analytics about leagues, matches, and teams.
        - Execute custom SQL queries to explore more.
        """)

    elif menu == "Data Management":
        st.subheader("Manage Your Football Data")
        crud_option = st.selectbox(
            "Choose Operation", ["Create", "Read", "Update", "Delete"]
        )

        if crud_option == "Create":
            st.text("Insert a new league")
            league_id = st.number_input("League ID", min_value=1, step=1)
            country_id = st.number_input("Country ID", min_value=1, step=1)
            league_name = st.text_input("League Name")
            if st.button("Add League"):
                query = "INSERT INTO league (id, country_id, name) VALUES (%s, %s, %s)"
                execute_query(query, (league_id, country_id, league_name))
                st.success("League added successfully!")

        elif crud_option == "Read":
            st.text("View records")
            table_name = st.selectbox("Select Table", ["country", "league", "team", "matches"])
            if st.button("View Data"):
                query = f"SELECT * FROM {table_name}"
                data = execute_query(query)
                if data is not None:
                    st.dataframe(data)

        elif crud_option == "Update":
            st.text("Update team details")
            team_id = st.number_input("Team API ID", min_value=1, step=1)
            new_name = st.text_input("New Team Long Name")
            if st.button("Update"):
                query = "UPDATE team SET team_long_name = %s WHERE team_api_id = %s"
                execute_query(query, (new_name, team_id))
                st.success("Team updated successfully!")

        elif crud_option == "Delete":
            st.text("Delete a match")
            match_id = st.number_input("Match API ID", min_value=1, step=1)
            if st.button("Delete"):
                query = "DELETE FROM matches WHERE match_api_id = %s"
                execute_query(query, (match_id,))
                st.success("Match deleted successfully!")

    elif menu == "Insights and Analysis":
        st.subheader("Explore Football Insights")
        analytics_option = st.selectbox(
            "Choose Analysis",
            [
                "Leagues and Countries", 
                "Top Scoring Matches", 
                "Teams with High Scoring Matches", 
                "Most Frequent Winning Teams"
            ]
        )

        if analytics_option == "Leagues and Countries":
            query = """
            SELECT country.name AS country_name, league.name AS league_name
            FROM country
            JOIN league ON country.id = league.country_id
            ORDER BY country_name, league_name
            """
            data = execute_query(query)
            if data is not None:
                st.dataframe(data)

        elif analytics_option == "Top Scoring Matches":
            query = """
            SELECT match_api_id, home_team_goal, away_team_goal, 
                   (home_team_goal + away_team_goal) AS total_goals
            FROM matches
            ORDER BY total_goals DESC
            LIMIT 5
            """
            data = execute_query(query)
            if data is not None:
                st.dataframe(data)

        elif analytics_option == "Teams with High Scoring Matches":
            query = """
            SELECT team_long_name, COUNT(*) AS high_scoring_matches
            FROM team
            JOIN matches ON team.team_api_id = matches.home_team_api_id OR team.team_api_id = matches.away_team_api_id
            WHERE home_team_goal + away_team_goal > 5
            GROUP BY team_long_name
            HAVING COUNT(*) > 2
            ORDER BY high_scoring_matches DESC
            """
            data = execute_query(query)
            if data is not None:
                st.dataframe(data)

        elif analytics_option == "Most Frequent Winning Teams":
            query = """
            SELECT team_long_name, COUNT(*) AS wins
            FROM team
            JOIN matches ON team.team_api_id = matches.home_team_api_id AND matches.home_team_goal > matches.away_team_goal
            GROUP BY team_long_name
            ORDER BY wins DESC
            LIMIT 5
            """
            data = execute_query(query)
            if data is not None:
                st.dataframe(data)

    elif menu == "Custom Query":
        st.subheader("Run Your Own SQL Query")
        custom_query = st.text_area("Enter SQL Query")
        if st.button("Execute"):
            data = execute_query(custom_query)
            if data is not None:
                st.dataframe(data)

if __name__ == "__main__":
    main()
