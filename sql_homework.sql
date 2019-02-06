
-- 1a. Display the first and last names of all actors from the table actor.
SELECT a.first_name, a. last_name
FROM actor a; 

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT CONCAT(a.first_name, ' ', a. last_name)
FROM actor a; 


-- 2a. You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
SELECT a.actor_id, a.first_name, a. last_name
FROM actor a 
WHERE a.first_name LIKE 'JOE';

-- 2b. Find all actors whose last name contain the letters GEN:
SELECT a.actor_id, a.first_name, a. last_name
FROM actor a 
WHERE a.last_name LIKE '%GEN%';

-- 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT a.first_name, a. last_name
FROM actor a 
WHERE a.last_name LIKE '%LI%';
ORDER BY 2,1;

-- 2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT c.country_id, c.country
FROM country c 
WHERE c.country IN ('Afghanistan', 'Bangladesh', 'China');


-- 3a. You want to keep a description of each actor. 
-- You don't think you will be performing queries on a description, 
-- so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN actor_description BLOB AFTER last_name;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column.
ALTER TABLE actor
DROP actor_description;


-- 4a. List the last names of actors, as well as how many actors have that last name.
SELECT a.last_name, COUNT(a.last_name)
FROM actor a
GROUP BY 1
ORDER BY 2 DESC;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT a.last_name, COUNT(a.last_name)
FROM actor a
GROUP BY 1
HAVING COUNT(a.last_name) >= 2;

-- 4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE actor_id = 172;

-- 4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';
    -- I could not do this in a single line of code. I either had to remove the safe updates options(shown above) 
    -- or refer to the primary key(actor_id) instead of the first name (shown below) as requested in the instructions.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE actor_id = 172;


-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
-- Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
SHOW CREATE TABLE address;


-- 6a. Use JOIN to display the first and last names, as well as the address, of each staff member. Use the tables staff and address:
SELECT s.first_name, s.last_name, a.address
FROM	staff s
	JOIN address a ON s.address_id = a.address_id;

-- 6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
SELECT s.first_name, s.last_name, SUM(p.amount)
FROM	staff s
	JOIN payment p ON s.staff_id = p.staff_id
WHERE MONTH(p.payment_date) = 8  
GROUP BY 1,2;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, COUNT(fa.actor_id)
FROM film f
	INNER JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY 1
ORDER BY 2 DESC;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT f.title, COUNT(i.inventory_id)
FROM film f
	LEFT JOIN inventory i ON f.film_id = i.film_id
WHERE f.title LIKE 'Hunchback Impossible'
GROUP BY 1;

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer. List the customers alphabetically by last name:
SELECT c.last_name, c.first_name, SUM(p.amount) 
FROM customer c 
	JOIN payment p ON c.customer_id = p.customer_id
GROUP BY 1,2
ORDER BY 1;


-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.
SELECT f.title, la.name
FROM film f
	JOIN language la ON f.language_id = la.language_id;
 WHERE (SELECT f.title 
	FROM film f
	WHERE f.title LIKE 'A%' OR f.title LIKE 'Q%') AND la.name = 'English';

-- 7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT DISTINCT f.title, aa.*  
FROM (
	SELECT fa.film_id, a.first_name, a.last_name 
	FROM actor a
		LEFT JOIN film_actor fa ON a.actor_id = fa.actor_id) AS aa
	JOIN film f ON aa.film_id = f.film_id
WHERE f.title LIKE 'Alone Trip';
    -- this could have been done more simply by just joining multiple tables??? PROBABLY!


-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.
SELECT cust.email, co.country
FROM customer cust
	JOIN address a ON cust.address_id = a.address_id 
    JOIN city ON a.city_id = city.city_id
    JOIN country co ON city.country_id = co.country_id
WHERE co.country LIKE 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as family films.
SELECT f.title, c.name 
FROM film f 
	JOIN film_category fc ON f.film_id = fc.film_id
    JOIN category c ON fc.category_id = c.category_id
WHERE c.name LIKE 'FAMILY';

-- 7e. Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(r.rental_id)
FROM film f
	JOIN inventory i ON f.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
GROUP BY 1
ORDER BY 2 DESC;

-- 7f. Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, CONCAT('$', FORMAT(SUM(p.amount), 2))
FROM store s
	JOIN staff st ON s.store_id = st.store_id
    JOIN payment p ON st.staff_id = p.staff_id
GROUP BY 1
ORDER BY 2 DESC;

-- 7g. Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, c.city, cn.country
FROM store s
	JOIN address a ON s.address_id = a.address_id
    JOIN city c ON a.city_id = c.city_id
    JOIN country cn ON c.country_id = cn.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
SELECT c.name, SUM(p.amount)
FROM category c 
	JOIN film_category fc ON c.category_id = fc.category_id
	JOIN inventory i ON fc.film_id = i.film_id
    JOIN rental r ON i.inventory_id = r.inventory_id
    JOIN payment p ON r.rental_id = p.rental_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;    


-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW  top_genres_by_gross_revenue  AS (
	SELECT c.name, SUM(p.amount)
	FROM category c 
		JOIN film_category fc ON c.category_id = fc.category_id
		JOIN inventory i ON fc.film_id = i.film_id
		JOIN rental r ON i.inventory_id = r.inventory_id
		JOIN payment p ON r.rental_id = p.rental_id
	GROUP BY 1
	ORDER BY 2 DESC
	LIMIT 5);    

-- 8b. How would you display the view that you created in 8a?
SELECT * 
FROM top_genres_by_gross_revenue;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW top_genres_by_gross_revenue;

