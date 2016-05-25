ALTER TABLE SS13_BAN CHANGE expiration_time expiration_time datetime DEFAULT NULL;
ALTER TABLE SS13_BAN ADD applies_to_admins tinyint(1) DEFAULT NULL AFTER a_ip;

UPDATE SS13_BAN SET job='appearance',expiration_time=NULL WHERE bantype = 'APPEARANCE_PERMABAN';
UPDATE SS13_BAN SET job='appearance' WHERE bantype = 'APPEARANCE_TEMPBAN';

UPDATE SS13_BAN SET job=NULL WHERE job='';

UPDATE SS13_BAN SET expiration_time=NULL WHERE bantype = 'PERMABAN' OR bantype = 'JOB_PERMABAN' OR bantype = 'ADMIN_PERMABAN';

UPDATE SS13_BAN SET applies_to_admins=1 WHERE bantype = 'ADMIN_TEMPBAN' OR bantype = 'ADMIN_PERMABAN';

ALTER TABLE SS13_BAN DROP COLUMN bantype;
ALTER TABLE SS13_BAN DROP COLUMN duration;
ALTER TABLE SS13_BAN DROP COLUMN rounds;
