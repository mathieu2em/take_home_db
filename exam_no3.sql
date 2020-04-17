begin transaction;
CREATE OR REPLACE FUNCTION
  amort(emprunt NUMERIC, period_pay NUMERIC, taux_interet NUMERIC) RETURNS
  TABLE(period INTEGER, pay NUMERIC, rest NUMERIC) AS $$

  WITH RECURSIVE temp (period, pay, rest)

  AS (SELECT 1 , 0.0 , emprunt
      UNION
      SELECT period+1,
             CASE
             WHEN ((rest +(rest*taux_interet)-period_pay) > 0)
             THEN period_pay
             ELSE CAST (rest+(rest*taux_interet) AS NUMERIC(100,2))
             END,
             CASE
             WHEN ((rest +(rest*taux_interet)-period_pay) > 0)
             THEN CAST (rest+(rest*taux_interet)-period_pay  AS NUMERIC(100,2) )
             ELSE 0
             END
      from temp WHERE rest > 0)
  SELECT period, pay, rest FROM temp;
$$ language 'sql';
select * from amort(10000.00,1000.00,0.05);
rollback;

