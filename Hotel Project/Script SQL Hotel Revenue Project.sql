with transaction_count as (
select customer, count(customer) as amount
from dbo.purchase_time$
group by customer)

select b.customer, a.amount
from transaction_count as a
left join dbo.purchase_time$ as b
on a.customer = b.customer
	left join dbo.purchase_percentage$ as c
	on b.transaction_id = c.transaction_id
where amount > (select avg(amount) from transaction_count) and total_items > (select avg(total_items) from dbo.purchase_percentage$)
group by b.customer, a.amount
order by b.customer asc