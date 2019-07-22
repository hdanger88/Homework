USE sakila;

-- 1a. Display the first and last names of all actors from the table `actor`.

select first_name, last_name
from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column `Actor Name`.

select
concat (upper(first_name), ' ', upper(last_name))
as Actor_Name
from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?

select actor_id, first_name, last_name
from actor
where first_name = "Joe";

-- 2b. Find all actors whose last name contain the letters `GEN`:

select actor_id, first_name, last_name
from actor
where actor.last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. This time, order the rows by last name and first name, in that order:

select actor_id, last_name, first_name
from actor
where actor.last_name like '%LI%'
order by  last_name, first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the following countries: Afghanistan, Bangladesh, and China:

select country_id, country
from country 
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing queries on a description, 
-- so create a column in the table `actor` named `description` and use the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

alter table actor
add column description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

alter table actor
drop column description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name
count(*) as 'Count'
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name
count(*) as 'Count'
from actor
group by last_name;
having count >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

update actor 
set first_name = 'HARPO'
where first_name ='GROUCHO' AND last_name ='WILLIAMS';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

update actor 
set first_name = 'GROUCHO'
where first_name = 'HARPO';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?

describe sakila.address;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

select first_name, last_name, address
from staff s 
join address a
on s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

select first_name, last_name, sum(amount), payment_date
from staff s 
join payment p
on s.staff_id = p.staff_id
where payment_date > '2005-08%';

-- 6c. List each film and the number of actors who are listed for that film. Use tables `film_actor` and `film`. Use inner join.

select title, count(actor_id)
from film_actor fa
join film f
on fa.film_id = f.film_id
group by f.title;

-- 6d. How many copies of the film `Hunchback Impossible` exist in the inventory system?

select title, 
( 
select count(*) 
from inventory
where film.film_id = inventory.film_id
) 
as 'Copies'
from film
where title = "Hunchback Impossible";

-- 6e. Using the tables `payment` and `customer` and the `JOIN` command, list the total paid by each customer. List the customers alphabetically by last name:

select first_name, last_name, sum(amount)
from customer c
join payment p 
on c.customer_id = p.customer_id
group by last_name;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters `K` and `Q`
-- have also soared in popularity. Use subqueries to display the titles of movies starting with the letters `K` and `Q` whose language is English.

select title
from film
where (title like 'K%' or title like 'Q%') 
and title in 
	(
    select language_id
    from film
    where language_id = "English"
    );

-- 7b. Use subqueries to display all actors who appear in the film `Alone Trip`.

select first_name, last_name
from actor
where actor_id in
	(
	select actor_id
	from film_actor
	where film_id in
		(
		select film_id
		from film
		where title = 'Alone Trip'
));	

-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.

select country, last_name, first_name, email
from country c
left join customer cust
on c.country_id = cust.customer_id
where country = 'Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. Identify all movies categorized as _family_ films.

select title
from film f
join film_category fc
on f.film_id = fc.film_id
where category_id = 'Family';

-- 7e. Display the most frequently rented movies in descending order.

select title, count(f.film_id) as times_rented
from  film f
join inventory i 
on f.film_id = i.film_id
join rental r 
on i.inventory_id = r.inventory_id
group by title 
order by times_rented desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select s.store_id, sum(amount) as total_revenue
from store s
join staff st 
on s.store_id = st.store_id
join payment p
on p.staff_id = st.staff_id 
group by s.store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store_id, city, country
from store s
join address a
on s.address_id = a.address_id
join city c
on a.city_id = c.city_id
join country 
on c.country_id = country.country_id;

-- 7h. List the top five genres in gross revenue in descending order. (**Hint**: you may need to use the following tables: category, 
-- film_category, inventory, payment, and rental.)

select name as Genre, SUM(amount) as total_revenue
from category c
join film_category fc
on  c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on r.rental_id = p.rental_id
group by Genre 
order by total_revenue  
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view.

create view top_five_grossing_genres as

select name as Genre, SUM(amount) as total_revenue
from category c
join film_category fc
on  c.category_id = fc.category_id
join inventory i
on fc.film_id = i.film_id
join rental r
on i.inventory_id = r.inventory_id
join payment p 
on r.rental_id = p.rental_id
group by Genre 
order by total_revenue  
limit 5;

-- 8b. How would you display the view that you created in 8a?

select * from top_five_grossing_genres;

-- 8c. You find that you no longer need the view `top_five_genres`. Write a query to delete it.

drop view top_five_grossing_genres;