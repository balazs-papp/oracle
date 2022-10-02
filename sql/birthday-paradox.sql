set verify off
accept people number prompt 'Number of people: '
accept tries number prompt 'Number of tries: '
with
num_people as (select * from dual connect by level <= &&people),
num_tries as (select rownum t from dual connect by level <= &&tries),
birthdays as (select num_tries.t, round(dbms_random.value(1, 365)) v from num_tries, num_people), 
same_birthdays as (select birthdays.t, birthdays.v, count(*) from birthdays group by birthdays.t, birthdays.v having count(*) > 1)
select count(distinct same_birthdays.t) / &&tries * 100 as percent from same_birthdays;