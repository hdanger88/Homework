use sakila;

-- 1a. Display the first and last names of all actors from the table actor.

select first_name, last_name from actor;

-- 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name.

select first_name as fn, last_name as ln, concat(first_name," ",last_name) as combo from actor;

-- 2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." 
-- What is one query would you use to obtain this information?

select actor_id, first_name, last_name 
from actor
where first_name = 'Joe';

-- 2b. Find all actors whose last name contain the letters GEN:

select * 
from actor
where last_name like '%GEN%';

-- 2c. Find all actors whose last names contain the letters `LI`. 
--     This time, order the rows by last name and first name, in that order:

select * 
from actor
where last_name like '%LI%'
order by last_name and  first_name;

-- 2d. Using `IN`, display the `country_id` and `country` columns of the 
-- following countries: Afghanistan, Bangladesh, and China:

select country_id, country
from country
where country in ('Afghanistan', 'Bangladesh', 'China');

-- 3a. You want to keep a description of each actor. You don't think you will be performing 
-- queries on a description, so create a column in the table `actor` named `description` and use 
-- the data type `BLOB` (Make sure to research the type `BLOB`, as the difference between it and `VARCHAR` are significant).

alter table actor
add column description blob;

-- 3b. Very quickly you realize that entering descriptions for each actor is too much effort. Delete the `description` column.

alter table actor
drop description;

-- 4a. List the last names of actors, as well as how many actors have that last name.

select last_name, count(last_name)
from actor
group by last_name;

-- 4b. List last names of actors and the number of actors who have that last name, but only for names that are shared by at least two actors

select last_name, count(last_name)
from actor
group by last_name
having count(last_name) >= 2;

-- 4c. The actor `HARPO WILLIAMS` was accidentally entered in the `actor` table as `GROUCHO WILLIAMS`. Write a query to fix the record.

update actor
set first_name = 'Harpo'
where first_name = 'Groucho' and last_name = 'Williams';

-- 4d. Perhaps we were too hasty in changing `GROUCHO` to `HARPO`. It turns out that `GROUCHO` was the correct name after all! In a single query, if the first name of the actor is currently `HARPO`, change it to `GROUCHO`.

update actor
set first_name = 'Groucho'
where last_name = 'Harpo';

-- 5a. You cannot locate the schema of the `address` table. Which query would you use to re-create it?
-- Hint: [https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html](https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html)

show create table address;

CREATE TABLE `address` (
   `address_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
   `address` varchar(50) NOT NULL,
   `address2` varchar(50) DEFAULT NULL,
   `district` varchar(20) NOT NULL,
   `city_id` smallint(5) unsigned NOT NULL,
   `postal_code` varchar(10) DEFAULT NULL,
   `phone` varchar(20) NOT NULL,
   `location` geometry NOT NULL,
   `last_update` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
   PRIMARY KEY (`address_id`),
   KEY `idx_fk_city_id` (`city_id`),
   SPATIAL KEY `idx_location` (`location`),
   CONSTRAINT `fk_address_city` FOREIGN KEY (`city_id`) REFERENCES `city` (`city_id`) ON UPDATE CASCADE
 ) ENGINE=InnoDB AUTO_INCREMENT=606 DEFAULT CHARSET=utf8;

-- 6a. Use `JOIN` to display the first and last names, as well as the address, of each staff member. Use the tables `staff` and `address`:

select s.first_name, s.last_name, a.address
from staff s
join address a 
on s.address_id = a.address_id;

-- 6b. Use `JOIN` to display the total amount rung up by each staff member in August of 2005. Use tables `staff` and `payment`.

select s.first_name, s.last_name, sum(p.amount)
from staff s
join payment p 
on s.staff_id = p.staff_id
where p.payment_date like '2005-08%'
group by p.staff_id;

-- 6c. List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join. 

select title, count(actor_id)
from film 
join film_actor
on film.film_id = film_actor.film_id
group by title;

-- 6d. How many copies of the film Hunchback Impossible exist in the inventory system?

select title, count(inventory_id)
from film f
join inventory i
on f.film_id = i.film_id
where title='Hunchback Impossible';

-- 6e. Using the tables payment and customer and the JOIN command, list the total paid by each customer.
-- List the customers alphabetically by last name.

select last_name, first_name, sum(amount)
from payment p
join customer c
on p.customer_id = c.customer_id
group by p.customer_id
order by last_name asc;

-- 7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 

select title
from film
where title like 'K%' or title like 'Q%' 
and language_id in 
	(
    select language_id 
    from language
    where name='English'
    );
    
-- -- 7b. Use subqueries to display all actors who appear in the film Alone Trip.

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
       where title='Alone Trip'
	  )
	 );
 
-- 7c. You want to run an email marketing campaign in Canada, for which you will need the names and email addresses of all Canadian customers. 
-- Use joins to retrieve this information.

select c.country, cu.first_name, cu.last_name, cu.email
from country c
join customer cu
on c.country_id = cu.customer_id
where country='Canada';

-- 7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.

select title, category
from film_list
where category='Family';

-- 7e. Display the most frequently rented movies in descending order.

select i.film_id, f.title, count(r.inventory_id)
from inventory i
join rental r
on i.inventory_id = r.inventory_id
join film_text f 
on i.film_id = f.film_id
group by r.inventory_id
order by count(r.inventory_id) desc;

-- 7f. Write a query to display how much business, in dollars, each store brought in.

select store_id, address, sum(amount)
from address a
join store s
on s.address_id = a.address_id
join payment p
on s.manager_staff_id = p.staff_id
group by store_id;

-- 7g. Write a query to display for each store its store ID, city, and country.

select store_id, address, city, country
from store s
join address a
on s.address_id = a.address_id
join city c
on c.city_id = a.city_id
join country co 
on c.country_id = co.country_id;


-- 7h. List the top five genres in gross revenue in descending order. (Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)

select name as genre, sum(amount) as gross_revenue
from payment p
join rental r
on p.rental_id = r.rental_id
join inventory i 
on r.inventory_id = i.inventory_id
join film_category f 
on i.film_id = f.film_id
join category c 
on f.category_id = c.category_id
group by genre
order by gross_revenue desc
limit 5;

-- 8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
-- Use the solution from the problem above to create a view. If you haven't solved 7h, you can substitute another query to create a view

create view top_five_genres as
select name as genre, sum(amount) as gross_revenue
from payment p
join rental r
on p.rental_id = r.rental_id
join inventory i 
on r.inventory_id = i.inventory_id
join film_category f 
on i.film_id = f.film_id
join category c 
on f.category_id = c.category_id
group by genre
order by gross_revenue desc
limit 5;

-- 8b. How would you display the view that you created in 8a?

select * 
from top_five_genres;

-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.

drop view top_five_genres; 





































