begin transaction;
SET search_path TO releves_notes;
CREATE OR REPLACE FUNCTION releve (mat char, progn char)
RETURNS TABLE
 (trimc     CHAR     (5) ,
  sigle     CHAR     (10),
  titre     VARCHAR      ,
  cred      NUMERIC      ,
  note      CHAR     (5)
  ) AS $$

WITH
r0   as (SELECT trimc,sigle,note FROM notes
         WHERE notes.matricule = mat AND notes.prog = progn),

tab1 as (SELECT trimc,sigle,titre, credits as cred,note
         FROM r0 NATURAL JOIN titres NATURAL JOIN credits),

a    as (SELECT * FROM tab1 WHERE note != 'R'   AND
                                  note != 'REM' AND
                                  note != '(S)' AND
                                  note != 'SE'  AND
                                  note != 'ABA' ),
b    as (SELECT trimc,sigle,titre,CAST(NULL as NUMERIC) as cred, note FROM tab1 WHERE
                                  note = 'R'   OR
                                  note = 'REM' OR
                                  note = '(S)' OR
                                  note = 'SE'  OR
                                  note = 'ABA' ),

tab2 as (SELECT * FROM a UNION ALL SELECT * FROM b),

-- table avec les valeurs
tab_val as (SELECT trimc,sigle,cred,valeur
            FROM tab2 NATURAL JOIN valnotes),

-- sommes ponderees
tab_sp  as (SELECT DISTINCT trimc, SUM(valeur*cred) OVER (PARTITION BY trimc) AS sum_pond
            FROM tab_val),

-- sommes de credits jusqu'au trimestre en cours
sum_cred as (SELECT DISTINCT trimc, SUM(cred) OVER (ORDER BY trimc) AS sum_tc FROM tab_val ORDER BY trimc),

-- somme des sommes trimestrielles
sum_sum as (SELECT  trimc, SUM(sum_tc) OVER (ORDER BY trimc) as sum_creds
            FROM sum_cred),

-- somme des sommes de prods
sum_sum2 as (SELECT trimc, SUM(sum_pond) OVER (ORDER BY trimc) as sum_prods
             FROM tab_sp),

-- resultat de la division
cumu as (SELECT trimc,'MoyCum' AS sigle, 'Moyenne cumulative' AS titre,
                sum_tc AS cred, CAST(sum_prods/sum_tc AS CHAR (5)) AS note FROM sum_sum NATURAL JOIN sum_cred NATURAL JOIN sum_sum2 ORDER BY trimc),

-- moyenne trimestrielle
tab_moy   as (SELECT trimc, sum(cred) AS sumcred, sum(valeur*cred)/sum(cred) AS moy
          FROM tab_val GROUP BY trimc),

rz   as (SELECT trimc,sigle,cred,valeur as creds
         FROM tab2 NATURAL JOIN valnotes),

r1   as (SELECT trimc, sum(cred) AS sumcred, sum(creds*cred)/sum(cred) AS moy
     FROM rz GROUP BY trimc),

-- ligne correcte pour moyenne trimestrielle
mtr  as (SELECT trimc,'Moy' AS sigle, 'Moyenne du trimestre' AS titre,
                r1.sumcred as cred, r1.moy as note
         FROM r1 WHERE r1.moy IS NOT NULL)

SELECT * FROM tab2
UNION ALL
SELECT trimc,sigle, titre,cred,CAST(note AS CHAR (5)) FROM mtr
UNION ALL
SELECT * FROM cumu
ORDER BY trimc,cred,sigle;
$$ language 'sql';
select * from releve('51780','117510');
rollback;
