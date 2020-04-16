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

tab1  as (SELECT trimc,sigle,titre, credits as cred,note
         FROM r0 NATURAL JOIN titres NATURAL JOIN credits),

rz   as (SELECT trimc,sigle,cred,valeur as creds
         FROM tab1 NATURAL JOIN valnotes),

r1   as (SELECT trimc, sum(cred) AS sumcred, sum(creds*cred)/sum(cred) AS moy,
         count(cred) AS numcred FROM rz GROUP BY trimc),

mtr  as (SELECT trimc,'Moy' AS sigle, 'Moyenne du trimestre' AS titre,
                sumcred as cred, moy as note, numcred
         FROM r1 WHERE moy IS NOT NULL),
cumu as (SELECT trimc,'MoyCum' AS sigle, 'Moyenne cumulative' AS titre,
                sum(cred) OVER (ORDER BY trimc) AS cred, 'nada' AS note FROM mtr)
SELECT * FROM tab1
UNION ALL
SELECT trimc,sigle, titre,cred,CAST( note AS CHAR (5)) FROM mtr
UNION ALL
SELECT * FROM cumu ORDER BY trimc,cred,sigle;
$$ language 'sql';
select * from releve('51780','117510');
rollback;
