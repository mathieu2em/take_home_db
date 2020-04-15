begin transaction;
create or replace function 
  amort(...) returns
  table(...) as $$
  ...
$$ language 'sql';
select * from amort(10000.00,1000.00,0.05);
rollback;

