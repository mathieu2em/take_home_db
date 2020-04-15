begin transaction;
set search_path to releves_notes;

CREATE VIEW notesinfo AS
       SELECT sigle, trimc, matricule, prog, nature, note, titre
       FROM notes NATURAL JOIN titres

CREATE TABLE log_notes (
       trimc     CHAR     (5)  NOT NULL,
       sigle     CHAR     (10) NOT NULL,
       matricule CHAR     (10) NOT NULL,
       prog      CHAR     (7),
       nature    CHAR     (3),
       note      CHAR     (3),
       ts        TIMESTAMP
);

CREATE OR REPLACE FUNCTION ...

CREATE TRIGGER  ...

update notesinfo set note='A'
where  sigle='IFT3911' and matricule='53357' and trimc='20114';
select * from notesinfo where matricule='53357';
select * from log_notes;
rollback;

