 /*1.1из таблицы с пользователями столбцы с именем и фамилией + алиасы
  *  присоедините таблицу с адресами и выведите значение адреса.*/
select first_name as "Имя", last_name as "Фамилия", a.address
from customer c
join address a on a.address_id = c.address_id

/*1.2 Напишите запрос, который выведет количество товаров в категории "Музыка"*/
select count(*)
from category c 
join product p on c.category_id = p.category_id
where c.category = 'Музыка'

/*2.1 Выведите имя и фамилию пользователя из города “Aden” */
select c.first_name, c.last_name
from customer c
join address a on a.address_id = c.address_id
join city c2 on c2.city_id = a.city_id
where c2.city = 'Aden'

/*2.2 Получите количество сотрудников, которые числятся в “Группа развития розничных продаж”*/
select count(*)
from staff s
join "structure" s2 on s.unit_id = s2.unit_id
where s2.unit = 'Группа развития розничных продаж'

/*2.3 Cреднее значение платежей по каждому пользователю, у которых первая буква фамилии начинается на “А”.*/
select avg(o.amount)
from customer c
join orders o on o.customer_id = c.customer_id
where c.last_name ilike 'a%' 

/*3.1 Какое количество платежей было совершено?*/
select count(*)
from orders

/*3.2 Какое количество заказов было совершено пользователями из города “El Alto”?*/
select count(*)
from city c
join address a on a.city_id=c.city_id 
join customer c2 on c2.address_id = a.address_id 
join orders o on c2.customer_id = o.customer_id
where c.city ='El Alto'

/*3.3 Сколько “Черепах” купила “Williams Linda”*/
select sum(opl.amount)
from order_product_list opl
join orders o on o.order_id = opl.order_id
join customer c on c.customer_id = o.customer_id 
join product p on p.product_id = opl.product_id
where c.last_name = 'Williams' and c.first_name = 'Linda'and p.product = 'Черепаха'

/*3.4 Сколько уникальных пользователей совершали покупки товаров из категории “Игрушки”?*/
select count(distinct customer_id)
from order_product_list opl
join orders o on o.order_id = opl.order_id
join product p on p.product_id = opl.product_id
join category cat on cat.category_id = p.category_id 
where cat.category = 'Игрушки'


