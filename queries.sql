--1
create view bestsellers as
select shopID, productID, count(*) as amount
from customer_order
group by shopID, productID;

create view organized_bestsellers as
select *
from bestsellers
order by shopID, amount DESC;

select organized_bestsellers.*
from (select organized_bestsellers.*,
             (@rn := if(@c = shopID, @rn + 1,
                        if(@c := shopID, 1, 1)
                       )
             ) as rn
      from organized_bestsellers cross join
           (select @rn := 0, @c := -1) params
      order by shopID, amount desc
     ) organized_bestsellers
having rn <= 2;

--2
select distinct tel
from orderdenied, customer_tel
where userID = customerID;

--3
CREATE view new_customers AS
SELECT customer_order.customerID, product.price
FROM customer_order, product
WHERE customer_order.status != 'denied' AND
customer_order.productID = product.ID AND
customer_order.customerID IN (SELECT userID from customer);

CREATE view old_customers AS
SELECT customer_order.customerID, product.price
FROM customer_order, product
WHERE customer_order.status != 'denied' AND
customer_order.productID = product.ID AND
customer_order.customerID not IN (SELECT userID from customer);

CREATE VIEW dif(avg_price) AS
(SELECT avg(price)
from old_customers)
UNION
(SELECT AVG(price)
FROM new_customers);

select MAX(avg_price) - MIN(avg_price) as difference
from dif;

--4
SELECT *
from courier
where credit IN (SELECT MAX(credit) as credit from courier);

--5
create view v as
SELECT shopID, (closeAt - openAt) as difference
FROM shop;

SELECT shopID, difference
FROM v
ORDER BY difference DESC
LIMIT 1;