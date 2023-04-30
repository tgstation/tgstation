-- Version 5.12, 29 December 2020, by Missfox
-- Modified table `messages`, adding column `playtime` to show the user's playtime when the note was created.

ALTER TABLE `messages` ADD `playtime` INT(11) NULL DEFAULT(NULL) AFTER `severity`
