begin transaction;
set search_path to releves_notes;

CREATE OR REPLACE VIEW notesinfo AS
       SELECT sigle, trimc, matricule, prog, nature, note,
       (SELECT titre FROM titres t WHERE t.sigle = n.sigle) AS titre
       FROM notes n;

CREATE TABLE log_notes (
       trimc     CHAR     (5)  NOT NULL,
       sigle     CHAR     (10) NOT NULL,
       matricule CHAR     (10) NOT NULL,
       prog      CHAR     (7),
       nature    CHAR     (3),
       note      CHAR     (3),
       ts        TIMESTAMP
);

CREATE OR REPLACE FUNCTION log_change()
RETURNS TRIGGER AS $$
BEGIN
IF NEW.note != OLD.note THEN
   insert into log_notes(trimc,sigle,matricule,prog,nature,note,ts) values
   (OLD.trimc,OLD.sigle,OLD.matricule,OLD.prog,OLD.nature,OLD.note,now());
END IF;
return new;
END;
$$ language 'plpgsql';

CREATE TRIGGER  modified_note
BEFORE UPDATE
ON notes
FOR EACH ROW
EXECUTE PROCEDURE log_change();

UPDATE notesinfo SET note='A'
WHERE  sigle='IFT3911' AND matricule='53357' AND trimc='20114';
SELECT * FROM notesinfo WHERE matricule='53357';
SELECT * FROM log_notes;
rollback;

