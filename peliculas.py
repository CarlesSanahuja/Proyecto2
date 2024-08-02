from flask import Flask, render_template, request, redirect, url_for, flash
import mysql.connector

app = Flask(__name__)
app.secret_key = 'your_secret_key'  # Necesario para usar flash messages

# Database connection
def get_db_connection():
    connection = mysql.connector.connect(
        host='localhost',
        user='root',
        password='',
        database='database_films'
    )
    return connection

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
    
    cursor.execute("SELECT * FROM Genres")
    genres = cursor.fetchall()

    cursor.execute("SELECT * FROM Actors")
    actors = cursor.fetchall()

    cursor.execute("SELECT * FROM Directors")
    directors = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template('index.html', movies=movies, genres=genres, actors=actors, directors=directors)

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
        flash('Movie added successfully!', 'success')
    except mysql.connector.Error as err:
        flash(f'Error: {err}', 'danger')
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('index'))

@app.route('/add_details', methods=['POST'])
def add_details():
    movie_id = request.form['movie_id']
    genre_id = request.form['genre_id']
    actor_id = request.form['actor_id']
    director_id = request.form['director_id']
    budget = request.form['budget']
    box_office = request.form['box_office']
    duration = request.form['duration']
    review = request.form['review']
    date = request.form['review_date']

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
        if budget or box_office or duration:
            cursor.execute(
                "INSERT INTO Movies_details (movie_id, budget, box_office, duration) VALUES (%s, %s, %s, %s)",
                (movie_id, budget, box_office, duration)
            )
        if review:
            cursor.execute(
                "INSERT INTO reviews (movie_id, review, date) VALUES (%s, %s, %s)",
                (movie_id, review, date)
            )
        connection.commit()
        flash('Details added successfully!', 'success')
    except mysql.connector.Error as err:
        flash(f'Error: {err}', 'danger')
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('index'))

@app.route('/add_actor', methods=['POST'])
def add_actor():
    name = request.form['name']

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("INSERT INTO Actors (name) VALUES (%s)", (name,))
        connection.commit()
        flash('Actor added successfully!', 'success')
    except mysql.connector.Error as err:
        flash(f'Error: {err}', 'danger')
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('index'))

@app.route('/add_director', methods=['POST'])
def add_director():
    name = request.form['name']

    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("INSERT INTO Directors (name) VALUES (%s)", (name,))
        connection.commit()
        flash('Director added successfully!', 'success')
    except mysql.connector.Error as err:
        flash(f'Error: {err}', 'danger')
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('index'))

@app.route('/movie_details/<int:movie_id>', methods=['GET'])
def movie_details(movie_id):
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    cursor.execute("""
        SELECT m.movie_id, m.title, m.release_year, m.duration, m.synopsis, m.language, m.country, m.rating,
               GROUP_CONCAT(DISTINCT g.name ORDER BY g.name ASC SEPARATOR ', ') as genres,
               GROUP_CONCAT(DISTINCT a.name ORDER BY a.name ASC SEPARATOR ', ') as actors,
               GROUP_CONCAT(DISTINCT d.name ORDER BY d.name ASC SEPARATOR ', ') as directors,
               de.budget, de.box_office, de.duration as detail_duration
        FROM Movies m
        LEFT JOIN Movies_Genres mg ON m.movie_id = mg.movie_id
        LEFT JOIN Genres g ON mg.genre_id = g.genre_id
        LEFT JOIN Movies_Actors ma ON m.movie_id = ma.movie_id
        LEFT JOIN Actors a ON ma.actor_id = a.actor_id
        LEFT JOIN Movies_Directors md ON m.movie_id = md.movie_id
        LEFT JOIN Directors d ON md.director_id = d.director_id
        LEFT JOIN Movies_details de ON m.movie_id = de.movie_id
        WHERE m.movie_id = %s
        GROUP BY m.movie_id
    """, (movie_id,))
    movie = cursor.fetchone()

    cursor.close()
    connection.close()

    if movie:
        return render_template('details.html', movie=movie)
    else:
        flash('Movie not found!', 'danger')
        return redirect(url_for('index'))

@app.route('/delete_movie', methods=['POST'])
def delete_movie():
    movie_id = request.form['movie_id']
    
    connection = get_db_connection()
    cursor = connection.cursor()

    try:
        cursor.execute("DELETE FROM Movies_genres WHERE movie_id = %s", (movie_id,))
        cursor.execute("DELETE FROM Movies_actors WHERE movie_id = %s", (movie_id,))
        cursor.execute("DELETE FROM Movies_directors WHERE movie_id = %s", (movie_id,))
        cursor.execute("DELETE FROM Movies_details WHERE movie_id = %s", (movie_id,))
        cursor.execute("DELETE FROM reviews WHERE movie_id = %s", (movie_id,))
        cursor.execute("DELETE FROM Movies WHERE movie_id = %s", (movie_id,))
        connection.commit()
        flash('Movie deleted successfully!', 'success')
    except mysql.connector.Error as err:
        flash(f'Error: {err}', 'danger')
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('index'))

if __name__ == '__main__':
    app.run(debug=True)
