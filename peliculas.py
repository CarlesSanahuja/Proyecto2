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
    cursor.execute("SELECT title, release_year, 'Drama' AS genre, rating FROM Movies")
    movies = cursor.fetchall()
    cursor.close()
    connection.close()
    return render_template('index.html', movies=movies)

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

    # Insert movie data into database
    try:
        cursor.execute(
            "INSERT INTO Movies (title, release_year, duration, synopsis, language, country, rating) VALUES (%s, %s, %s, %s, %s, %s, %s)",
            (title, release_year, duration, synopsis, language, country, rating)
        )
        connection.commit()
        message = "Movie added successfully!"
        return index()
    except mysql.connector.Error as err:
        message = f"Error: {err}"
    finally:
        cursor.close()
        connection.close()

    return jsonify({'message': message})

if __name__ == '__main__':
    app.run(debug=True)
