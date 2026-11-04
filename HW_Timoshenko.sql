/* Задание 1
Вывести список сотрудников старше 65 лет. */
select	
	concat(last_name, ' ', first_name, ' ', middle_name) as emp_name, 
	dob,
	date_part('year', age(dob)) as emp_age
from
	hr.person
where
	date_part('year', age(dob)) > 65 --исправлено

/* Задание 2
Вывести количество вакантных должностей. 
(Таблица с вакансиями может содержать недостоверные данные, 
решение должно быть без этой таблицы).*/
select
	count (p.pos_id) as vac_count
from
	hr.position p
left join hr.employee e on
	p.pos_id = e.pos_id
where
	e.emp_id is null;

/* Задание 3
Вывести список проектов и 
количество сотрудников, задействованных на этих проектах.*/
select 
	project_id, 
	name,
	employees_id,
	assigned_id,
	count(distinct elems) as headcount
from
	hr.projects p, 
	unnest(array_append(employees_id, assigned_id)) as elems
group by
	project_id


/* Задание 4
Получить список сотрудников,
у которых было повышение заработной платы на 25% */
with cte1 as (
select
	emp_id,
	salary as curr_salary,
	lag(salary) over(partition by emp_id order by effective_from) as prev_salary,
	--исправлено, теперь рассчет в cte1
	round((salary - lag(salary) over(partition by emp_id order by effective_from)) / lag(salary) over(partition by emp_id order by effective_from) * 100, 0) as change_percent
from
	hr.employee_salary
)
select
	c.emp_id,
	concat(p.last_name, ' ', p.first_name, ' ', p.middle_name) as employee_name,
	c.prev_salary,
	c.curr_salary,
	c.change_percent
from
	cte1 c
join hr.employee e on
	c.emp_id = e.emp_id
join hr.person p on
	e.person_id = p.person_id
where
	change_percent = 25;
	--исправлено, теперь условие формулируется кратко

/* Задание 5
Вывести среднее значение суммы договора на каждый год,
округленное до сотых. */
select
	distinct
    extract(year from created_at) as year,
	round(avg(amount) over(partition by extract(year from created_at)), 2) as avg_amount
from
	hr.projects
order by
	year;

/* Задание 6
Одним запросом вывести ФИО сотрудников 
с самым низким и самым высоким окладами за все время. */
select
	distinct 
    concat(p.last_name, ' ', p.first_name, ' ', p.middle_name) as name,
	s.salary
from
	(
	select
		emp_id,
		salary,
		max(salary) over() as max_sal,
		min(salary) over() as min_sal
	from
		hr.employee_salary
) s
join hr.employee e on
	s.emp_id = e.emp_id
join hr.person p on
	e.person_id = p.person_id
where
	s.salary = s.max_sal
	or s.salary = s.min_sal;

/*Задание 7
Вывести текущий оклад сотрудников
и в формате строки вывести зарплатные грейды,
в которые попадает текущий оклад.*/
select
	e.emp_id,
	cs.salary,
	--изменено, через запятую
	string_agg(gs.grade::text, ',' order by gs.grade) as grades_string
from
	(
	select
		distinct on
		(emp_id) 
           emp_id,
		salary
	from
		hr.employee_salary
	order by
		emp_id,
		effective_from desc 
) cs
join hr.employee e on
	cs.emp_id = e.emp_id
	--  изменено на left join, чтобы не терять сотрудников без грейдов
left join hr.grade_salary gs on
	cs.salary between gs.min_salary and gs.max_salary
group by
	e.emp_id,
	cs.salary
/*Чтобы получить вид таблицы как в образце результата,
  нужно применить фильтр к grades_string IS NOT NULL. */
	
/*Задание 8
Создайте представление, которое будет содержать следующую информацию:

ФИО сотрудника
должность сотрудника
структурное подразделение, где числится сотрудник
количество полных лет сотрудника
количество месяцев, сколько сотрудник работает в компании
текущий оклад сотрудника
массив со списком проектов на которых задействован сотрудник*/

create or replace view hr.employee_full_info as
select
	concat(p.last_name, ' ', p.first_name, ' ', p.middle_name) as "фио сотрудника",
	pos.pos_title as "должность",
	str.unit_title as "структурное подразделение",
	date_part('year', age(p.dob)) as "полных лет",
	date_part('year', age(e.hire_date)) * 12 + date_part('month', age(e.hire_date)) as "продолжительность работы, месяцев",
	cs.salary as "текущий оклад",
	--через  left join с комментарием "текущий оклад" далее             
	pl.projects_array as "массив проектов"
	--через  left join с комментарием  "массив проектов" далее
from
	hr.employee e
join hr.person p on
	e.person_id = p.person_id
left join hr.position pos on
	e.pos_id = pos.pos_id
left join hr.structure str on
	pos.unit_id = str.unit_id
	-- текущий оклад
left join (
	select
		distinct on
		(emp_id) emp_id,
		salary
	from
		hr.employee_salary
	order by
		emp_id,
		effective_from desc
) cs on
	e.emp_id = cs.emp_id
	-- массив проектов
left join (
	select
	--изменено добавлены руководители проектов
		elems as emp_id,
		array_agg(distinct pr.project_id order by pr.project_id) as projects_array
	from
		hr.projects pr,
		unnest(array_append(pr.employees_id, pr.assigned_id)) as elems
	where
		elems is not null
	group by
		elems
) pl on
	e.emp_id = pl.emp_id;

		
select * from hr.employee_full_info
/*чтобы получить вид таблицы как в образце результата,
  нужно применить фильтр массив проектов IS NOT NULL. 
  Мое понимание условия ДЗ, что требуется полная сводка инфо по сотрудникам, 
  не только по тем, кто задействован в проектах,
  поэтому базовое решение выдает список всех сотрудников*/

-

