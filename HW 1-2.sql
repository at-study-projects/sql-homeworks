select *
from customer

select first_name, last_name
from customer

select first_name, last_name
from customer
where first_name ilike 'a%a'

select distinct extract(month from created_date)
from orders

select product_id, price, round(price / 1.2, 2)
from product

select city
from city
where city like '__q%'

select created_date::time
from orders

select *
from product 
where product like '% %'

select order_id, amount, discount, amount*((100-discount)/100::numeric)
from orders 

select *
from product
where price >= 100 and char_length (product) = 10

select first_name, last_name
from customer 
where char_length(first_name) = char_length(last_name) and left(first_name, 1) = left(last_name, 1)

 /*Сколько городов имеют первый символ названия равный последнему?*/
select count(city) 
from city 
where left(city,1) ilike right (city,1)

/*Получите товары, которые имеют пометку на удаление, какое количество таких товаров?*/
select product 
from product 
where deleted

/*Сколько заказов имеют стоимость от 200 включительно до 215 включительно?*/
select count(amount)
from orders
where amount between 200 and 215

/*Напишите запрос и ответьте на вопрос. Есть ли заказы со скидкой больше 3%?*/
select order_id, discount
from orders orders
where discount >3



