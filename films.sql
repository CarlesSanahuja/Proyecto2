-- Drop the database database_films if it exists
DROP DATABASE IF EXISTS database_films;

-- Create the database database_films
CREATE DATABASE database_films;
USE database_films;

CREATE TABLE Movies (
    movie_id INT PRIMARY KEY AUTO_INCREMENT,
    title NVARCHAR(255),
    release_year YEAR,
    duration INT,
    synopsis TEXT,
    language NVARCHAR(50),
    country NVARCHAR(100),
    rating NVARCHAR(50)
);

CREATE TABLE Genres (
    genre_id INT PRIMARY KEY AUTO_INCREMENT,
    name NVARCHAR(100)
);

-- Add description column to Genres table
ALTER TABLE Genres
ADD description TEXT;

CREATE TABLE Movies_Genres (
    movie_id INT,
    genre_id INT,
    PRIMARY KEY (movie_id, genre_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (genre_id) REFERENCES Genres(genre_id)
);

CREATE TABLE Directors (
    director_id INT PRIMARY KEY AUTO_INCREMENT,
    name NVARCHAR(255)
);

CREATE TABLE Movies_Directors (
    movie_id INT,
    director_id INT,
    PRIMARY KEY (movie_id, director_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (director_id) REFERENCES Directors(director_id)
);

CREATE TABLE Actors (
    actor_id INT PRIMARY KEY AUTO_INCREMENT,
    name NVARCHAR(255)
);

CREATE TABLE Movies_Actors (
    movie_id INT,
    actor_id INT,
    role NVARCHAR(255),
    PRIMARY KEY (movie_id, actor_id),
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id),
    FOREIGN KEY (actor_id) REFERENCES Actors(actor_id)
);

CREATE TABLE Reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    text TEXT,
    date DATE,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

CREATE TABLE Ratings (
    rating_id INT PRIMARY KEY AUTO_INCREMENT,
    movie_id INT,
    score INT,
    date DATE,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

CREATE TABLE Movies_Details (
    movie_id INT PRIMARY KEY,
    budget DECIMAL(15, 2),
    box_office DECIMAL(15, 2),
    duration INT,
    FOREIGN KEY (movie_id) REFERENCES Movies(movie_id)
);

-- Create trigger to check if the movie already exists before allowing insertion
DELIMITER //

CREATE TRIGGER before_movie_insert
BEFORE INSERT ON Movies
FOR EACH ROW
BEGIN
    -- Check if the movie already exists by title and release year
    IF EXISTS (
        SELECT 1
        FROM Movies
        WHERE title = NEW.title AND release_year = NEW.release_year
    ) THEN
        -- If the movie already exists, raise an error
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'The movie already exists.';
    END IF;
END //

DELIMITER ;

-- Create trigger  to Prevent Negative score Values
DELIMITER //

CREATE TRIGGER prevent_negative_score
BEFORE INSERT ON ratings
FOR EACH ROW
BEGIN
    IF NEW.score < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Score value cannot be negative';
    END IF;
END //

DELIMITER ;
-- Insert data into Movies table
INSERT INTO Movies (title, release_year, duration, synopsis, language, country, rating) VALUES
('The Shawshank Redemption', 1994, 142, 'Two imprisoned men bond over a number of years.', 'English', 'USA', 'R'),
('The Godfather', 1972, 175, 'The aging patriarch of an organized crime dynasty transfers control of his clandestine empire to his reluctant son.', 'English', 'USA', 'R'),
('The Dark Knight', 2008, 152, 'When the menace known as the Joker emerges from his mysterious past, he wreaks havoc and chaos on the people of Gotham.', 'English', 'USA', 'PG-13'),
('Pulp Fiction', 1994, 154, 'The lives of two mob hitmen, a boxer, a gangster and his wife, and a pair of diner bandits intertwine in four tales of violence and redemption.', 'English', 'USA', 'R'),
('The Lord of the Rings: The Return of the King', 2003, 201, 'Gandalf and Aragorn lead the World of Men against Sauron''s army to draw his gaze from Frodo and Sam as they approach Mount Doom with the One Ring.', 'English', 'New Zealand', 'PG-13'),
('Forrest Gump', 1994, 142, 'The presidencies of Kennedy and Johnson, the events of Vietnam, Watergate, and other history unfold through the perspective of an Alabama man with an IQ of 75.', 'English', 'USA', 'PG-13'),
('Inception', 2010, 148, 'A thief who steals corporate secrets through the use of dream-sharing technology is given the inverse task of planting an idea into the mind of a C.E.O.', 'English', 'USA', 'PG-13'),
('Fight Club', 1999, 139, 'An insomniac office worker and a devil-may-care soap maker form an underground fight club that evolves into something much, much more.', 'English', 'USA', 'R'),
('The Matrix', 1999, 136, 'A computer hacker learns from mysterious rebels about the true nature of his reality and his role in the war against its controllers.', 'English', 'USA', 'R'),
('The Lord of the Rings: The Fellowship of the Ring', 2001, 178, 'A meek Hobbit from the Shire and eight companions set out on a journey to destroy the powerful One Ring and save Middle-earth from the Dark Lord Sauron.', 'English', 'New Zealand', 'PG-13');

-- Insert data into Genres table
INSERT INTO Genres (name) VALUES
('Drama'),
('Crime'),
('Action'),
('Adventure'),
('Fantasy'),
('Romance'),
('Sci-Fi'),
('Thriller'),
('Comedy'),
('Animation');

-- Update data in Genres table with descriptions
UPDATE Genres SET description = 'Serious presentations or representations of real life or historical events' WHERE name = 'Drama';
UPDATE Genres SET description = 'Stories involving crime and its detection' WHERE name = 'Crime';
UPDATE Genres SET description = 'Films with high energy, physical stunts and chases' WHERE name = 'Action';
UPDATE Genres SET description = 'Films involving travel and exploration in exotic locations' WHERE name = 'Adventure';
UPDATE Genres SET description = 'Films with magical or supernatural elements' WHERE name = 'Fantasy';
UPDATE Genres SET description = 'Stories centered on romantic relationships' WHERE name = 'Romance';
UPDATE Genres SET description = 'Films with futuristic or scientific elements' WHERE name = 'Sci-Fi';
UPDATE Genres SET description = 'Films that elicit excitement and suspense' WHERE name = 'Thriller';
UPDATE Genres SET description = 'Films designed to provoke laughter' WHERE name = 'Comedy';
UPDATE Genres SET description = 'Films using animated images or objects' WHERE name = 'Animation';


-- Insert data into Movies_Genres table
INSERT INTO Movies_Genres (movie_id, genre_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 2),
(5, 4),
(6, 1),
(7, 7),
(8, 8),
(9, 7),
(10, 4);

-- Insert data into Directors table
INSERT INTO Directors (name) VALUES
('Frank Darabont'),
('Francis Ford Coppola'),
('Christopher Nolan'),
('Quentin Tarantino'),
('Peter Jackson'),
('Robert Zemeckis'),
('David Fincher'),
('Lana Wachowski'),
('Lilly Wachowski'),
('Steven Spielberg');

-- Insert data into Movies_Directors table
INSERT INTO Movies_Directors (movie_id, director_id) VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 3),
(8, 7),
(9, 8),
(10, 5);

-- Insert data into Actors table
INSERT INTO Actors (name) VALUES
('Tim Robbins'),
('Morgan Freeman'),
('Marlon Brando'),
('Al Pacino'),
('Christian Bale'),
('Heath Ledger'),
('John Travolta'),
('Samuel L. Jackson'),
('Elijah Wood'),
('Viggo Mortensen');

-- Insert data into Movies_Actors table
INSERT INTO Movies_Actors (movie_id, actor_id, role) VALUES
(1, 1, 'Andy Dufresne'),
(1, 2, 'Ellis Boyd Redding'),
(2, 3, 'Don Vito Corleone'),
(2, 4, 'Michael Corleone'),
(3, 5, 'Bruce Wayne'),
(3, 6, 'Joker'),
(4, 7, 'Vincent Vega'),
(4, 8, 'Jules Winnfield'),
(5, 9, 'Frodo Baggins'),
(5, 10, 'Aragorn');

-- Insert data into Reviews table
INSERT INTO Reviews (movie_id, text, date) VALUES
(1, 'Amazing movie!', '2023-01-11'),
(2, 'A true classic.', '2023-01-12'),
(3, 'Best superhero film.', '2023-01-13'),
(4, 'Tarantino at his best.', '2023-01-14'),
(5, 'Epic conclusion.', '2023-01-15'),
(6, 'Heartwarming story.', '2023-01-16'),
(7, 'Mind-blowing.', '2023-01-17'),
(8, 'Thought-provoking.', '2023-01-18'),
(9, 'Revolutionary sci-fi.', '2023-01-19'),
(10, 'Incredible journey.', '2023-01-20');

-- Insert data into Ratings table
INSERT INTO Ratings (movie_id, score, date) VALUES
(1, 5, '2023-01-11'),
(2, 5, '2023-01-12'),
(3, 5, '2023-01-13'),
(4, 5, '2023-01-14'),
(5, 5, '2023-01-15'),
(6, 5, '2023-01-16'),
(7, 5, '2023-01-17'),
(8, 5, '2023-01-18'),
(9, 5, '2023-01-19'),
(10, 5, '2023-01-20');

-- Insert data into Movies_Details table
INSERT INTO Movies_Details (movie_id, budget, box_office, duration) VALUES
(1, 25000000.00, 28341469.00, 142), -- The Shawshank Redemption
(2, 6000000.00, 134966411.00, 175), -- The Godfather
(3, 185000000.00, 1004558444.00, 152), -- The Dark Knight
(4, 8000000.00, 213928762.00, 154), -- Pulp Fiction
(5, 94000000.00, 1146030912.00, 201), -- The Lord of the Rings: The Return of the King
(6, 55000000.00, 678222284.00, 142), -- Forrest Gump
(7, 160000000.00, 829895144.00, 148), -- Inception
(8, 63000000.00, 101209702.00, 139), -- Fight Club
(9, 63000000.00, 465277911.00, 136), -- The Matrix
(10, 93000000.00, 887871136.00, 178); -- The Lord of the Rings: The Fellowship of the Ring


-- Simple Queries

-- 1 Get the title of all registered movies
SELECT title FROM Movies;

-- 2 Show all available genres
SELECT * FROM Genres;

-- 3 Show review for the movie Pulp Fiction with id 4
SELECT text FROM Reviews WHERE review_id = 4;

-- 4 Show rating for the movie Pulp Fiction with id 4
SELECT score FROM Ratings WHERE movie_id = 4;

-- 5 Show the id of the actors in the movie Pulp Fiction with id 4
SELECT actor_id FROM Movies_Actors WHERE movie_id = 4;

-- 6 Show the id of the director of the movie Pulp Fiction with id 4
SELECT director_id FROM Movies_Directors WHERE movie_id = 4;

-- 7 Get movies released after 2000
SELECT * FROM Movies WHERE release_year > 2000;

-- 8 Get the total number of movies introduced
SELECT COUNT(*) AS total_movies FROM Movies;

-- 9 Get the total duration of all movies
SELECT SUM(duration) AS total_duration FROM Movies;

-- 10 Get title and synopsis of the first three movies introduced
SELECT title, synopsis FROM Movies LIMIT 3;

-- Complex Queries

-- 1 Get all movies and their genres
SELECT m.title, g.name AS genre
FROM Movies m
JOIN Movies_Genres mg ON m.movie_id = mg.movie_id
JOIN Genres g ON mg.genre_id = g.genre_id;

-- 2 Get all movies and their directors
SELECT m.title, d.name AS director
FROM Movies m
JOIN Movies_Directors md ON m.movie_id = md.movie_id
JOIN Directors d ON md.director_id = d.director_id;

-- 3 Get all movies directed by a specific director
SELECT m.title
FROM Movies m
JOIN Movies_Directors md ON m.movie_id = md.movie_id
JOIN Directors d ON md.director_id = d.director_id
WHERE d.name = 'Christopher Nolan';

-- 4 Get all movies in which a specific actor appears
SELECT m.title
FROM Movies m
JOIN Movies_Actors ma ON m.movie_id = ma.movie_id
JOIN Actors a ON ma.actor_id = a.actor_id
WHERE a.name = 'Morgan Freeman';

-- 5 Get the budget and box office of all movies
SELECT m.title, md.budget, md.box_office
FROM Movies m
JOIN Movies_Details md ON m.movie_id = md.movie_id;

-- 6 Get the average rating of each movie
SELECT m.title, AVG(r.score) AS average_rating
FROM Movies m
JOIN Ratings r ON m.movie_id = r.movie_id
GROUP BY m.title;

-- 7  Get the list of actors who have worked with a specific director (e.g., 'Christopher Nolan')
SELECT DISTINCT a.name AS actor
FROM Actors a
JOIN Movies_Actors ma ON a.actor_id = ma.actor_id
JOIN Movies m ON ma.movie_id = m.movie_id
JOIN Movies_Directors md ON m.movie_id = md.movie_id
JOIN Directors d ON md.director_id = d.director_id
WHERE d.name = 'Christopher Nolan';

-- 8 Get the average duration of movies for each director
SELECT d.name AS director, AVG(m.duration) AS average_duration
FROM Directors d
JOIN Movies_Directors md ON d.director_id = md.director_id
JOIN Movies m ON md.movie_id = m.movie_id
GROUP BY d.name;

-- 9 Get the movies with the highest rating in each genre
SELECT title, genre, max_rating
FROM (
    SELECT m.title, g.name AS genre, MAX(r.score) OVER (PARTITION BY g.name) AS max_rating, r.score
    FROM Movies m
    JOIN Movies_Genres mg ON m.movie_id = mg.movie_id
    JOIN Genres g ON mg.genre_id = g.genre_id
    JOIN Ratings r ON m.movie_id = r.movie_id
) AS genre_ratings
WHERE score = max_rating;


-- 10 Get the directors who have directed movies in more than one genre
SELECT name
FROM (
    SELECT d.name, COUNT(DISTINCT mg.genre_id) AS genre_count
    FROM Directors d
    JOIN Movies_Directors md ON d.director_id = md.director_id
    JOIN Movies_Genres mg ON md.movie_id = mg.movie_id
    GROUP BY d.name
) AS director_genres
WHERE genre_count > 1;

-- Transaction that inserts a new movie and its related details into multiple tables
START TRANSACTION;

-- Insert into Movies
INSERT INTO Movies (title, release_year, duration, synopsis, language, country, rating) VALUES
('The Matrix Reloaded', 2003, 138, 'Neo and the rebel leaders estimate that they have 72 hours until 250,000 probes discover Zion and destroy it.', 'English', 'USA', 'R');

-- Get the last inserted movie_id
SET @last_movie_id = LAST_INSERT_ID();

-- Insert into Movies_Details
INSERT INTO Movies_Details (movie_id, budget, box_office, duration) VALUES
(@last_movie_id, 150000000, 742128461, 138);

-- Insert into Movies_Genres
INSERT INTO Movies_Genres (movie_id, genre_id) VALUES
(@last_movie_id, (SELECT genre_id FROM Genres WHERE name = 'Sci-Fi'));
COMMIT;

-- Function 1: Calculate Average Rating for a Movie

DELIMITER //

CREATE FUNCTION get_avg_rating(movie_id INT) RETURNS DECIMAL(3, 2)
BEGIN
    DECLARE avg_rating DECIMAL(3, 2);
    SELECT AVG(score) INTO avg_rating
    FROM Ratings
    WHERE movie_id = movie_id;
    RETURN avg_rating;
end//

DELIMITER ;

-- Function 2: Get Movie Duration
DELIMITER //
CREATE FUNCTION get_movie_duration(movie_id INT) RETURNS INT
BEGIN
    DECLARE duration INT;
    SELECT duration INTO duration
    FROM Movies
    WHERE movie_id = movie_id;
    RETURN duration;
end//

DELIMITER ;

