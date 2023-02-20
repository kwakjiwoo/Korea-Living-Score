-------------------------------------------------------------------------------------------------
select 자치구 from korea.house_price
except
select 자치구 from korea.seoul_district sd ;


select trim(자치구),length(trim(자치구)) from korea.house_price hp2 
except
select trim(자치구),length(trim(자치구)) from korea.seoul_district hp;

select * from korea.seoul_district sd ;

select trim(자치구),length(trim(자치구)) from korea.seoul_district
except
select trim(자치구),length(trim(자치구)) from korea.subway ss;

update korea.subway  
set 자치구='Gangnam'
where 자치구 like '%Gangn%';

select *
from korea.subway ss  
where 자치구 like '%Gangn%'
-------------------------------------------------------------------------------------------------



-- SUBJECT 1: Calculate the livability score by elements(school, commercial, park, bus_stop) 
--			and compare with house price

--create seoul district
drop table korea.seoul_district;

update korea.seoul
set wkb_geometry = st_transform(st_setsrid(wkb_geometry, 2097), 4326);

create table korea.seoul_district as
select s1.자치구, st_union(s1.wkb_geometry) geom
from korea.seoul s1
join korea.seoul s2
on s1.자치구 = s2.자치구
and s1.ogc_fid != s2.ogc_fid
group by s1.자치구;

UPDATE korea.seoul_district set 자치구 ='Dobong' WHERE 자치구 = '도봉구';
UPDATE korea.seoul_district set 자치구 ='Dongdaemun' WHERE 자치구 = '동대문구';
UPDATE korea.seoul_district set 자치구 ='Dongjak' WHERE 자치구 = '동작구';
UPDATE korea.seoul_district set 자치구 ='Eunpyeong' WHERE 자치구 = '은평구';
UPDATE korea.seoul_district set 자치구 ='Gangbuk' WHERE 자치구 = '강북구';
UPDATE korea.seoul_district set 자치구 ='Gangdong' WHERE 자치구 = '강동구';
UPDATE korea.seoul_district set 자치구 ='Gangnam' WHERE 자치구 = '강남구';
UPDATE korea.seoul_district set 자치구 ='Gangseo' WHERE 자치구 = '강서구';
UPDATE korea.seoul_district set 자치구 ='Geumcheon' WHERE 자치구 = '금천구';
UPDATE korea.seoul_district set 자치구 ='Guro' WHERE 자치구 = '구로구';
UPDATE korea.seoul_district set 자치구 ='Gwanak' WHERE 자치구 = '관악구';
UPDATE korea.seoul_district set 자치구 ='Gwangjin' WHERE 자치구 = '광진구';
UPDATE korea.seoul_district set 자치구 ='Jongno' WHERE 자치구 = '종로구';
UPDATE korea.seoul_district set 자치구 ='Jung' WHERE 자치구 = '중구';
UPDATE korea.seoul_district set 자치구 ='Jungnang' WHERE 자치구 = '중랑구';
UPDATE korea.seoul_district set 자치구 ='Mapo' WHERE 자치구 = '마포구';
UPDATE korea.seoul_district set 자치구 ='Nowon' WHERE 자치구 = '노원구';
UPDATE korea.seoul_district set 자치구 ='Seocho' WHERE 자치구 = '서초구';
UPDATE korea.seoul_district set 자치구 ='Seodaemun' WHERE 자치구 = '서대문구';
UPDATE korea.seoul_district set 자치구 ='Seongbuk' WHERE 자치구 = '성북구';
UPDATE korea.seoul_district set 자치구 ='Seongdong' WHERE 자치구 = '성동구';
UPDATE korea.seoul_district set 자치구 ='Songpa' WHERE 자치구 = '송파구';
UPDATE korea.seoul_district set 자치구 ='Yangcheon' WHERE 자치구 = '양천구';
UPDATE korea.seoul_district set 자치구 ='Yeongdeug' WHERE 자치구 = '영등포구';
UPDATE korea.seoul_district set 자치구 ='Yongsan' WHERE 자치구 = '용산구';

select * from korea.seoul_district sd ;

-- SELECT DATA
-- select data which is school
drop table korea.school;
create table korea.school as 
select *
from korea.buildings b 
where type='school';

DELETE FROM korea.school
WHERE name IS null
or type is null;

select * from korea.school;

-- select data which is commercial
drop table korea.commercial;
create table korea.commercial as
select *
from korea.buildings b 
where b."type" ='commercial';

DELETE FROM korea.commercial
WHERE name IS null;

select * from korea.commercial;

-- select data which is park
drop table korea.park;
create table korea.park as
select *
from korea.landuse l 
where l.fclass ='park';

DELETE FROM korea.park
WHERE name IS null;

select * from korea.park;

-- select data which is bus_stop
drop table korea.busstop;
create table korea.busstop as
select *
from korea.transport t 
where t.fclass ='bus_stop';

DELETE FROM korea.busstop
WHERE name IS null;

select * from korea.busstop;

-- subway data
drop table korea.subway;
create table korea.subway
(자치구 char(11),
num float);

copy korea.subway(자치구,num)
from '/home/Korea/seoul_subway.csv'
delimiter ',';

select * from korea.subway;

drop table korea.seoul_subway;
create table korea.seoul_subway as
select d.자치구, s.num, d.geom
from korea.seoul_district d
join korea.subway s
on trim(s.자치구) = trim(d.자치구);

select * from korea.seoul_subway;


-- COUNT NUMBERS
-- count the numbers of school in district
drop table korea.seoul_school;
create table korea.seoul_school as
with seoul_school as 
(select 자치구, st_setsrid(st_union(geom), 4326) geom
from korea.seoul_district sd 
group by 자치구)
select sd2.자치구, count(s.ogc_fid) num, sd2.geom
from korea.seoul_district sd2 
join korea.school s 
on st_contains(sd2.geom, s.wkb_geometry)
group by sd2.자치구, sd2.geom;

select * from korea.seoul_school;

-- count the numbers of commercial in district
drop table korea.seoul_commercial;
create table korea.seoul_commercial as
with seoul_commercial as 
(select 자치구, st_setsrid(st_union(geom), 4326) geom
from korea.seoul_district sd 
group by 자치구)
select sd2.자치구, count(c.ogc_fid) num, sd2.geom
from korea.seoul_district sd2 
join korea.commercial c
on st_contains(sd2.geom, c.wkb_geometry)
group by sd2.자치구, sd2.geom;

select * from korea.seoul_commercial;

-- count the numbers of park in district
drop table korea.seoul_park;
create table korea.seoul_park as
with seoul_park as 
(select 자치구, st_setsrid(st_union(geom), 4326) geom
from korea.seoul_district sd 
group by 자치구)
select sd2.자치구, count(p.ogc_fid) num, sd2.geom
from korea.seoul_district sd2 
join korea.park p
on st_contains(sd2.geom, p.wkb_geometry)
group by sd2.자치구, sd2.geom;

select * from korea.seoul_park;

-- count the numbers of bus_stop in district
drop table korea.seoul_bus_stop;
create table korea.seoul_bus_stop as
with seoul_bus_stop as 
(select 자치구, st_setsrid(st_union(geom), 4326) geom
from korea.seoul_district sd 
group by 자치구)
select sd2.자치구, count(bs.ogc_fid) num, sd2.geom
from korea.seoul_district sd2 
join korea.busstop bs
on st_contains(sd2.geom, bs.wkb_geometry)
group by sd2.자치구, sd2.geom;

select * from korea.seoul_bus_stop;

-- NORMALIZE
-- normalize school
SELECT CAST(num as float) FROM korea.seoul_school ;

select min(num)
from korea.seoul_school; --4
select max(num)
from korea.seoul_school; --60

drop table korea.normal_seoul_school;
create table korea.normal_seoul_school as
select 자치구, (num-4.0)/56.0 normalized_num, geom
from korea.seoul_school
order by normalized_num desc;

select * from korea.normal_seoul_school;

-- normalize commercial
SELECT CAST(num as float) FROM korea.seoul_commercial ;

select min(num)
from korea.seoul_commercial; --8
select max(num)
from korea.seoul_commercial; --749

drop table korea.normal_seoul_commercial;
create table korea.normal_seoul_commercial as
select 자치구, (num-8.0)/749.0 normalized_num, geom
from korea.seoul_commercial
order by normalized_num desc;

select * from korea.normal_seoul_commercial;

-- normalize park
SELECT CAST(num as float) FROM korea.seoul_park;

select min(num)
from korea.seoul_park;--6
select max(num)
from korea.seoul_park; --109

drop table korea.normal_seoul_park;
create table korea.normal_seoul_park as
select 자치구, (num-6.0)/109.0 normalized_num, geom
from korea.seoul_park
order by normalized_num desc;

select * from korea.normal_seoul_park;

-- normalize bus_stop
SELECT CAST(num as float) FROM korea.seoul_bus_stop;

select min(num)
from korea.seoul_bus_stop;--164
select max(num)
from korea.seoul_bus_stop;--630

drop table korea.normal_seoul_bus_stop;
create table korea.normal_seoul_bus_stop as
select 자치구, (num-164.0)/630.0 normalized_num, geom
from korea.seoul_bus_stop
order by normalized_num desc;

select * from korea.normal_seoul_bus_stop;

-- normalize subway
SELECT CAST(num as float) FROM korea.seoul_subway;
select min(num)
from korea.seoul_subway;--1
select max(num)
from korea.seoul_subway;--28

drop table korea.normal_seoul_subway;
create table korea.normal_seoul_subway as
select 자치구, (num-1.0)/28.0 normalized_num, geom
from korea.seoul_subway
order by normalized_num desc;

select * from korea.normal_seoul_subway;


-- JOIN ALL TABLES ON 자치구
drop table korea.normalized_elements; 
create table korea.normalized_elements as
select s.자치구, s.normalized_num nor_school, s.geom
,(select normalized_num nor_commercial from korea.normal_seoul_commercial as c where c.자치구 = s.자치구)
,(select normalized_num nor_park from korea.normal_seoul_park as p where p.자치구 = s.자치구)
,(select normalized_num nor_busstop from korea.normal_seoul_bus_stop as b where b.자치구 = s.자치구)
,(select normalized_num nor_subway from korea.normal_seoul_subway as sw where sw.자치구 = s.자치구)
from korea.normal_seoul_school as s;

select * from korea.normalized_elements;


-- ADD ALL THE ELEMENTS
drop table korea.livability_score;
create table korea.livability_score as
select 자치구, nor_school+nor_commercial+nor_park+nor_busstop+nor_subway livability_score, geom 
from korea.normalized_elements
order by livability_score desc;

select * from korea.livability_score;


-- HOUSE PRICE 
drop table korea.house_price;
create table korea.house_price
(자치구 char(10),
price int);

copy korea.house_price(자치구,price)
from '/home/Korea/seoul_house_price.csv'
delimiter ',';

drop table korea.seoul_house_price;
create table korea.seoul_house_price as
select p.자치구, p.price, d.geom
from korea.seoul_district d
join korea.house_price p
on p.자치구 = d.자치구
order by price desc;

select * from korea.seoul_house_price;


-- SUBJECT 2: Find the element which causes the house price

select * from korea.normal_seoul_school;
select * from korea.normal_seoul_commercial;
select * from korea.normal_seoul_park;
select * from korea.normal_seoul_bus_stop;
select * from korea.normal_seoul_subway;
select * from korea.seoul_house_price;







