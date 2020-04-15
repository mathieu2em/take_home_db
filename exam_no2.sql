begin transaction;
set search_path to releves_notes;
create or replace function releve (...) returns table
 (...) as $$
 ...
$$ language 'sql';
select * from releve('51780','117510');
rollback;
