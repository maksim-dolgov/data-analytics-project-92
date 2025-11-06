select count(c.customer_id) as customers_count
from customers as c;
-- Данный запрос считает количество покупателей в таблице customers
select
    concat(e.first_name, ' ', e.last_name) as seller,
    count(s.sales_id) as operations,
    floor(sum(s.quantity * p.price)) as income
from products as p
inner join sales as s on s.product_id = p.product_id 
inner join employees as e on e.employee_id = s.sales_person_id
group by seller
order by income desc
limit 10;
-- Данный запрос выводит таблицу с десяткой лучших продавцов. 
-- Таблица состоит из трех колонок - данных о продавце, 
-- суммарной выручке с проданных товаров и количестве проведенных сделок,
-- отсортирована по убыванию выручки.
select * from (
    select
        concat(e.first_name, ' ', e.last_name) as seller,
        floor(avg(s.quantity * p.price)) as average_income
    from products as p
    inner join sales as s on s.product_id = p.product_id 
    inner join employees as e on e.employee_id = s.sales_person_id
    group by seller
    order by average_income
) as b
where
    average_income < (
        select floor(avg(s.quantity * p.price))
        from sales as s inner join products as p on s.product_id = p.product_id
    );
-- Данный запрос выводит таблицу, которая содержит информацию о продавцах,
-- чья средняя выручка за сделку меньше средней выручки за сделку
-- по всем продавцам. 
-- Таблица отсортирована по выручке по возрастанию.
select
    concat(e.first_name, ' ', e.last_name) as seller,
    to_char(s.sale_date, 'fmday') as day_of_week,
    floor(sum(s.quantity * p.price)) as income
from products as p
inner join sales as s on s.product_id = p.product_id 
inner join employees as e on e.employee_id = s.sales_person_id
group by seller, day_of_week, extract(isodow from s.sale_date)
order by extract(isodow from s.sale_date), seller;
-- Данный запрос выводит таблицу, которая содержит 
-- информацию о выручке по дням недели. 
-- Каждая запись содержит имя и фамилию продавца, день недели
-- и суммарную выручку. 
-- Данные отсортированы по порядковому номеру дня недели и продавцу.
select
    case
        when c.age between 16 and 25 then '16-25'
        when c.age between 26 and 40 then '26-40'
        else '40+'
    end as age_category,
    count(c.customer_id) as age_count
from customers as c
group by age_category
order by age_category;
-- Данный запрос выводит таблицу с количеством 
--покупателей в разных возрастных группах: 16-25, 26-40 и 40+. 
-- Таблица отсортирована по возрастным группам и содержит следующие поля:
-- age_category - возрастная группа, age_count.
select
    to_char(s.sale_date, 'YYYY-MM') as selling_month,
    count(distinct s.customer_id) as total_customers,
    floor(sum(s.quantity * p.price)) as income
from sales as s inner join products as p on s.product_id = p.product_id
group by selling_month
order by selling_month;
-- Данный запрос выводит таблицу с количеством 
-- уникальных покупателей и выручке, которую они принесли. 
-- Таблица отсортирована по дате по возрастанию и содержит следующие поля: 
-- date - дата в указанном формате, 
-- total_customers - количество покупателей, income - выручка.
select
    customer,
    sale_date,
    seller
from (
    select
        s.sale_date,
        p.price,
        concat(c.first_name, ' ', c.last_name) as customer,
        row_number()
            over (partition by c.customer_id order by s.sale_date)
            as rn,
        concat(e.first_name, ' ', e.last_name) as seller
    from customers as c inner join sales as s on c.customer_id = s.customer_id
    inner join products as p on s.product_id = p.product_id
    inner join employees as e on s.sales_person_id = e.employee_id
    where p.price = 0
    order by c.customer_id
) as tab
where rn = 1;
-- Данный запрос выводит таблицу с мнформацией о покупателях, 
-- первая покупка которых была в ходе проведения акций. 
-- Таблица отсортирована по id покупателя и содержит следующие поля: 
-- customer - имя и фамилия покупателя, 
-- sale_date - дата покупки, seller - имя и фамилия продавца.
