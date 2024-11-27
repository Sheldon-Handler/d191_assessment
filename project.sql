-- detailed_table CREATE
DROP TABLE IF EXISTS detailed_table;
CREATE TABLE detailed_table AS
SELECT f.film_id,
       f.title,
       f.description,
       f.release_year,
       f.language_id,
       f.rental_duration,
       f.rental_rate,
       f.length,
       f.replacement_cost,
       f.rating,
       f.special_features,
       f.fulltext,
       i.inventory_id,
       r.rental_id,
       r.rental_date,
       r.customer_id,
       r.return_date,
       r.staff_id,
       fc.category_id,
       c.name AS category
FROM film f
         JOIN inventory i ON f.film_id = i.film_id
         JOIN rental r ON i.inventory_id = r.inventory_id
         JOIN film_category fc ON f.film_id = fc.film_id
         JOIN category c ON fc.category_id = c.category_id
ORDER BY category DESC;

-- summary_table
DROP TABLE IF EXISTS summary_table;
CREATE TABLE summary_table AS
SELECT category,
       category_id,
       count(DISTINCT film_id)                      AS number_of_titles_in_category,
       SUM(rental_rate)                             AS rental_revenue,
       (SUM(rental_rate) / count(DISTINCT film_id)) AS average_revenue_per_title
FROM detailed_table
GROUP BY category, category_id
ORDER BY average_revenue_per_title DESC;


-- update_summary_table() TRIGGER FUNCTION
CREATE OR REPLACE FUNCTION update_summary_table()
    RETURNS TRIGGER
    LANGUAGE PLPGSQL
AS
$BODY$
BEGIN
    DROP TABLE IF EXISTS summary_table;
    CREATE TABLE summary_table AS
    SELECT category,
           category_id,
           count(DISTINCT film_id)                      AS number_of_titles_in_category,
           SUM(rental_rate)                             AS rental_revenue,
           (SUM(rental_rate) / count(DISTINCT film_id)) AS average_revenue_per_title
    FROM detailed_table
    GROUP BY category, category_id
    ORDER BY average_revenue_per_title DESC;
END;
$BODY$;

-- update_summary_table_trigger
DROP TRIGGER IF EXISTS update_summary_table_trigger ON detailed_table;
CREATE TRIGGER update_summary_table_trigger
    AFTER INSERT OR UPDATE OR DELETE
    ON detailed_table
EXECUTE FUNCTION update_summary_table();


-- update_detailed_table() PROCEDURE
CREATE OR REPLACE PROCEDURE public.update_detailed_table()
    LANGUAGE SQL
AS
$BODY$
DROP TABLE IF EXISTS detailed_table;
    CREATE TABLE detailed_table AS
    SELECT f.film_id,
           f.title,
           f.description,
           f.release_year,
           f.language_id,
           f.rental_duration,
           f.rental_rate,
           f.length,
           f.replacement_cost,
           f.rating,
           f.special_features,
           f.fulltext,
           i.inventory_id,
           r.rental_id,
           r.rental_date,
           r.customer_id,
           r.return_date,
           r.staff_id,
           fc.category_id,
           c.name AS category
    FROM film f
             JOIN inventory i ON f.film_id = i.film_id
             JOIN rental r ON i.inventory_id = r.inventory_id
             JOIN film_category fc ON f.film_id = fc.film_id
             JOIN category c ON fc.category_id = c.category_id
    ORDER BY category DESC;
    $BODY$;