USE sakila;
 
 ## 1a. Display the first and last names of all actors from the table actor
SELECT first_name, last_name 
FROM ACTOR;
 
 ## 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.
SELECT upper(CONCAT(first_name, ',',  last_name)) as Actor_name
FROM ACTOR;
 
 #2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
 # What is one query would you use to obtain this information?
SELECT actor_id, first_name, last_name 
FROM ACTOR
WHERE first_name = 'Joe';

#2b. Find all actors whose last name contain the letters GEN:
SELECT actor_id, first_name, last_name 
FROM ACTOR
WHERE last_name like '%gen%';

##2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
SELECT actor_id, first_name, last_name 
FROM ACTOR
WHERE last_name like '%LI%'
ORDER BY last_name, first_name;

##2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
SELECT country_id,  country
FROM country
WHERE country in ('Afghanistan', 'Bangladesh', 'China');

#3a. You want to keep a description of each actor. You don't think you will be performing queries on a description,
#so create a column in the table actor named description and use the data type BLOB (Make sure to research the type BLOB, 
#as the difference between it and VARCHAR are significant).
ALTER TABLE actor 
ADD description BLOB NULL;

#3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the description column
ALTER TABLE actor 
DROP COLUMN description;

#4a. List the last names of actors, as well as how many actors have that last name.
SELECT last_name
FROM ACTOR
WHERE last_name is not null;

SELECT count(last_name)
FROM ACTOR
WHERE last_name is not null;

#4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors
SELECT last_name, COUNT(*) as number_
FROM actor
GROUP BY last_Name
HAVING COUNT(*) > 1;

#4c. The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. Write a query to fix the record.
UPDATE actor
SET first_name = 'HARPO'
WHERE first_name = 'GROUCHO' 
AND last_Name = 'WILLIAMS';

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, change it to GROUCHO.
UPDATE actor
SET first_name = 'GROUCHO'
WHERE first_name = 'HARPO';

#5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
SHOW CREATE TABLE address;

#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. Use tables staff and payment.
select * from payment WHERE payment_date like '%2005-08%';
SELECT s.staff_id, SUM(amount) AS amount
FROM staff s
JOIN payment p ON s.staff_id = p.staff_id
WHERE payment_date like '%2005-08%'
GROUP BY (p.staff_id);

#6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
SELECT f.title, count(fa.actor_id) as actor_count
FROM film f
JOIN film_actor fa ON f.film_id = fa.film_id
GROUP BY (fa.film_id) ;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT count(*) 
FROM film f
JOIN inventory i ON f.film_id = i.film_id
WHERE f.title = 'Hunchback Impossible';

#6e. Using the tables payment and customer and the JOIN command, 
#list the total paid by each customer. List the customers alphabetically by last name:
SELECT first_name, last_name, sum(amount) as total
FROM payment p
JOIN customer c ON p.customer_id = c.customer_id
GROUP BY p.customer_id
ORDER BY last_name ;

#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, 
#films starting with the letters K and Q have also soared in popularity. Use subqueries to display the titles 
#of movies starting with the letters K and Q whose language is English.
SELECT title
FROM film 
WHERE (title LIKE 'Q%' or title LIKE 'K%')
AND language_id in (select language_id from language where name = 'English');

#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN (
					SELECT actor_id FROM film_actor WHERE film_id in (
																		SELECT film_id FROM film WHERE title = 'Alone Trip'));
                                                                        
#7b. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
#Use joins to retrieve this information.
SELECT cu.first_name, cu.last_name, cu.email
FROM customer cu
JOIN address a ON a.address_id = cu.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON co.country_id = c.country_id
where co.country = 'Canada';

#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
#Identify all movies categorized as family films.
SELECT title, rating 
FROM film f
JOIN film_category fc ON fc.film_id = f.film_id
JOIN category c ON c.category_id = c.category_id
WHERE c.name = 'Family';

#7e. Display the most frequently rented movies in descending order
SELECT title, rental_date
FROM film f
JOIN inventory i ON f.film_id = i.film_id
JOIN rental r ON r.inventory_id = i.inventory_id
ORDER BY rental_date desc;

#7f. Write a query to display how much business, in dollars, each store brought in.
SELECT sa.store_id, sum(p.amount) AS amount
FROM store s
JOIN staff sa ON sa.store_id = s.store_id
JOIN payment p ON p.staff_id = sa.staff_id
GROUP BY sa.store_id;

#7e.Write a query to display for each store its store ID, city, and country.
SELECT s.store_id, city, country
FROM store s
JOIN address a ON s.address_id = a.address_id
JOIN city c ON a.city_id = c.city_id
JOIN country co ON co.country_id = c.country_id;

#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: #category, film_category, inventory, payment, and rental.)
SELECT  c.name, sum(p.amount) as total_amount
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN inventory i      ON i.film_id      = fc.film_id
JOIN rental r         ON i.inventory_id = r.inventory_id
JOIN payment p             ON p.rental_id    = r.rental_id
GROUP BY c.name
ORDER BY total_amount DESC LIMIT 5;


#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW VW_TOP_5
AS
SELECT  c.name, sum(p.amount) as total_amount
FROM category c
JOIN film_category fc ON fc.category_id = c.category_id
JOIN inventory i      ON i.film_id      = fc.film_id
JOIN rental r         ON i.inventory_id = r.inventory_id
JOIN payment p             ON p.rental_id    = r.rental_id
GROUP BY c.name
ORDER BY total_amount DESC LIMIT 5;

#8b. How would you display the view that you created in 8a?
select * from VW_TOP_5;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW VW_TOP_5;
