--Oppgave 1
select p.firstname, p.lastname, fch.filmcharacter
from filmparticipation as fp
	join person as p on (fp.personid = p.personid)
	join film as f on (fp.filmid = f.filmid)
	join filmcharacter as fch on (fp.partid = fch.partid)
where f.title = 'Star Wars'

--Oppgave 2
select country, count(country) as ant_filmer
from filmcountry
group by country

--Oppgave 3 ikke riktig?
select country, avg(rt.time::int)
from runningtime as rt
where country is not null and rt.time ~ '^\d$'
group by country
having count(rt.time) >= 200

--Oppgave 4
select f.title, count(filmid) as num_genre, fi.filmtype
from filmgenre as fg
	join film as f using (filmid)
	join filmitem as fi using (filmid)
group by fg.filmid, fi.filmtype, f.title
having fi.filmtype = 'C'
order by num_genre desc, f.title
limit 10

--Oppgave 5
with ant_movies as (
	select country, count(filmid) as ant_filmer
	from filmcountry
	group by country
	order by ant_filmer desc),

countries_all_genre as (
	select country, genre, count(*) as country_genre
	from filmcountry as fc
		join filmgenre as fg using (filmid)
	group by country, genre
	order by country_genre desc),

countries_pop_genre as (
	select country, genre
	from countries_all_genre as cag
	where cag.genre = (
		select cag2.genre
		from countries_all_genre as cag2
		where cag.country = cag2.country
		limit 1)
	order by cag.country),

countries_rating as (
	select country, avg(rank) as avg_rating
	from filmcountry as fc
		join filmrating as fr using (filmid)
	group by country)

select country, ant_filmer, avg_rating, genre
from ant_movies as am
	join countries_pop_genre as cpg using (country)
	join countries_rating using (country)

--Oppgave 6
select distinct p.firstname, p.lastname, p2.firstname, p2.lastname
from filmitem as fi
    join filmcountry as fc using (filmid)
    join filmparticipation as fp using (filmid)
    join person as p on (p.personid = fp.personid)

    join filmparticipation as fp2 using (filmid)
    join person as p2 on (p2.personid = fp2.personid)

where fc.country = 'Norway' and fi.filmtype = 'C' and fp.personid < fp2.personid
group by p.firstname, p.lastname, p2.firstname, p2.lastname
having count(*) > 40

--Oppgave 7
select distinct f.prodyear, f.title
from film as f 
    inner join filmgenre as fg on (f.filmid = fg.filmid) 
    inner join filmcountry as fc on (f.filmid = fc.filmid) 
where (f.title like '% Dark %' and f.title like '% Night %') or (f.title like '%Dark%' or f.title like '%Night%') 
and ((fg.genre = 'Horror' and fc.country like 'Romania') or (fg.genre = 'Horror' or fc.country = 'Romania'))

--Oppgave 8 - fikk ikke til denne og neste 100%
select f.filmid
from film as f
	left join filmparticipation as fp on (f.filmid = fp.filmid)
where prodyear >= 2010

--Oppgave 9
select count(filmid)
from filmgenre
where not genre = 'Horror' and not genre = 'Sci-Fi'

--Oppgave 10
WITH
aboveEight AS
(SELECT f.title, f.filmid, fr.rank, fr.votes
  FROM filmitem AS fi
  NATURAL JOIN filmrating as fr
  NATURAL JOIN film as f
WHERE fi.filmtype = 'C' AND fr.votes > 1000 AND fr.rank >= 8),

intFilms AS(
  (SELECT aboveEight.title, aboveEight.filmid, aboveEight.rank, aboveEight.votes
    FROM aboveEight
    GROUP BY aboveEight.title, aboveEight.filmid, aboveEight.rank, aboveEight.votes
    ORDER BY aboveEight.rank DESC, aboveEight.votes DESC
    LIMIT 10)
    UNION
(SELECT aboveEight.title, aboveEight.filmid, aboveEight.rank, aboveEight.votes
  FROM aboveEight
  INNER JOIN filmparticipation AS fp ON fp.filmid = aboveEight.filmid
  INNER JOIN person AS p ON p.personid = fp.personid
  WHERE p.firstname = 'Harrison' AND p.lastname = 'Ford')
    UNION
(SELECT aboveEight.title, aboveEight.filmid, aboveEight.rank, aboveEight.votes
  FROM aboveEight
  INNER JOIN filmgenre as fg ON fg.filmid = aboveEight.filmid
  WHERE fg.genre = 'Comedy' OR fg.genre = 'Romance'))

  SELECT intFilms.title,
  (SELECT count(*)
  from filmlanguage AS fl WHERE fl.filmid = intFilms.filmid)
  FROM intFilms
  ORDER BY intFilms.title