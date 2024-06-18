-- Oppgave 2
-- 2a
select navn
from planet
where stjerne = 'Proxima Centauri'

-- 2b
select distinct navn, oppdaget
from planet
where stjerne = 'TRAPPIST-1' or stjerne = 'Kepler-154'

-- 2c
select count(navn)
from planet
where masse is NULL

--2d
select navn, masse
from planet
where oppdaget = 2020 and masse > (select avg(masse) from planet)

--2e
select max(oppdaget)-min(oppdaget) as Differanse_mellom_oppdaget
from planet


--Oppgave 3
--3a
select p.navn
from planet as p inner join materie as m on (p.navn = m.planet)
where (p.masse > 3 and p.masse < 10) and m.molekyl like 'H2O'

--3b
select p.navn
from planet as p 
	inner join materie as m on (p.navn = m.planet)
	inner join stjerne as s on (p.stjerne = s.navn)
where m.molekyl like '%H%' and s.avstand < (s.masse*12)

--3c
select p.navn
from planet as p
	inner join planet as pp on (p.stjerne = pp.stjerne)
	inner join stjerne as s on (p.stjerne = s.navn)
where s.avstand < 50 and (pp.masse > 10 and p.masse > 10) and not (p.navn = pp.navn)


--Oppgave 4
/*
Natural join setter to tabeller sammen på en kolonne med samme attributtnavn.
Begge tabellene har en kolonnen som heter navn men verdiene i disse kolonnene
samsvarer overhode ikke og vil ende opp med en ny tabell uten noe data.
*/


--Oppgave 5
--5a
insert into stjerne
values ('Sola', 0, 1)

--5b
insert into planet(navn, masse, stjerne)
values ('Jorda', 0.003146, 'Sola')


--Oppgave 6
create table observasjon(
	observasjons_id int primary key,
	tidspunkt timestamp not null,
	planet text not null references planet (navn),
	kommentar text
);