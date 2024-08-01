from flask import Flask, render_template, request, redirect, url_for, jsonify
import mysql.connector

app = Flask(__name__)

# Database connection
def get_db_connection():
    connection = mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='database_films'
    )
    return connection

# Home route with form and movie list
@app.route('/')
def index():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT m.movie_id, m.title, m.release_year, m.duration, m.synopsis, m.language, m.country, m.rating,
               GROUP_CONCAT(DISTINCT g.name ORDER BY g.name ASC SEPARATOR ', ') as genres,
               GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ', ') as actors,
               GROUP_CONCAT(DISTINCT d.name ORDER BY d.name ASC SEPARATOR ', ') as directors
        FROM Movies m
        LEFT JOIN Movies_Genres mg ON m.movie_id = mg.movie_id
        LEFT JOIN Genres g ON mg.genre_id = g.genre_id
        LEFT JOIN Movies_Actors ma ON m.movie_id = ma.movie_id
        LEFT JOIN Actors a ON ma.actor_id = a.actor_id
        LEFT JOIN Movies_Directors md ON m.movie_id = md.movie_id
        LEFT JOIN Directors d ON md.director_id = d.director_id
        GROUP BY m.movie_id
    """)
    movies = cursor.fetchall()

    cursor.execute("SELECT genre_id, name FROM Genres")
    genres = cursor.fetchall()

    cursor.execute("SELECT actor_id, name FROM Actors")
    actors = cursor.fetchall()

    cursor.execute("SELECT director_id, name FROM Directors")
    directors = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('index.html', movies=movies, genres=genres, actors=actors, directors=directors)

# Route to add movie
@app.route('/add_movie', methods=['POST'])
def add_movie():
    title = request.form['title']
    release_year = request.form['release_year']
    duration = request.form['duration']
    synopsis = request.form['synopsis']
    language = request.form['language']
    country = request.form['country']
    rating = request.form['rating']

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute(
            "INSERT INTO Movies (title, release_year, duration, synopsis, language, country, rating) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (title, release_year, duration, synopsis, language, country, rating)
        )
        connection.commit()
        message = "Movie added successfully!"
    except mysql.connector.Error as err:
        message = f"Error: {err}"
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': message})

# Route to add genre, actor, director to a movie
@app.route('/add_details', methods=['POST'])
def add_details():
    movie_id = request.form['movie_id']
    genre_id = request.form['genre_id']
    actor_id = request.form['actor_id']
    director_id = request.form['director_id']
    budget = request.form['budget']
    box_office = request.form['box_office']
    duration = request.form['duration']

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        if genre_id:
            cursor.execute(
                "INSERT INTO Movies_Genres (movie_id, genre_id) VALUES (%s, %s)",
                (movie_id, genre_id)
            )
        if actor_id:
            cursor.execute(
                "INSERT INTO Movies_Actors (movie_id, actor_id, role) VALUES (%s, %s, 'Unknown')",
                (movie_id, actor_id)
            )
        if director_id:
            cursor.execute(
                "INSERT INTO Movies_Directors (movie_id, director_id) VALUES (%s, %s)",
                (movie_id, director_id)
            )
        if budget:
            cursor.execute(
                "INSERT INTO Movies_details (movie_id, budget, box_office,duration) VALUES (%s, %s, %s,%s)",
                (movie_id, budget, box_office,duration)
            )
        connection.commit()
        message = "Details added successfully!"
    except mysql.connector.Error as err:
        message = f"Error: {err}"
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': message})

# Route to add actor
@app.route('/add_actor', methods=['POST'])
def add_actor():
    name = request.form['name']

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("INSERT INTO Actors (name) VALUES (%s)", (name,))
        connection.commit()
        message = "Actor added successfully!"
    except mysql.connector.Error as err:
        message = f"Error: {err}"
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': message})

# Route to add director
@app.route('/add_director', methods=['POST'])
def add_director():
    name = request.form['name']

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("INSERT INTO Directors (name) VALUES (%s)", (name,))
        connection.commit()
        message = "Director added successfully!"
    except mysql.connector.Error as err:
        message = f"Error: {err}"
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': message})
# Ruta para obtener los detalles de una película
@app.route('/movie_details/<int:movie_id>', methods=['GET'])
def movie_details(movie_id):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)
    cursor.execute("SELECT * FROM Movies_Details WHERE movie_id = %s", (movie_id,))
    details = cursor.fetchone()

    if details:
        return jsonify(details)
    else:
        return jsonify({'message': 'No details found for this movie'})

if __name__ == '__main__':
    app.run(debug=True)
