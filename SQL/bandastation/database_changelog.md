Any time you make a change to the schema files, remember to increment the database schema version. Generally increment the minor number, major should be reserved for significant changes to the schema. Both values go up to 255.

Make sure to also update `DB_MAJOR_VERSION_220` and `DB_MINOR_VERSION_220`, which can be found in `code/modular_bandastation/_defines220/code/defines/subsystems.dm`.

The latest database version is 1.1; The query to update the schema revision table is:

```sql
INSERT INTO `schema_revision_220` (`major`, `minor`) VALUES (1, 1);
```
or

```sql
INSERT INTO `SS13_schema_revision_220` (`major`, `minor`) VALUES (1, 1);
```

-----------------------------------------------------
Version 1.1, 17 April 2024, by larentoun
Created the tables: schema_revision220, ckey_whitelist, admin_wl

```sql
CREATE TABLE `schema_revision220` (
  `major` TINYINT(3) unsigned NOT NULL,
  `minor` TINYINT(3) unsigned NOT NULL,
  `date` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`major`, `minor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
```

```sql
CREATE TABLE `ckey_whitelist` (
	`id` INT(11) NOT NULL AUTO_INCREMENT,
	`date` DATETIME DEFAULT now() NOT NULL,
	`ckey` VARCHAR(32) NOT NULL,
	`adminwho` VARCHAR(32) NOT NULL,
	`port` INT(5) UNSIGNED NOT NULL,
	`date_start` DATETIME DEFAULT now() NOT NULL,
	`date_end` DATETIME NULL,
	`is_valid` BOOLEAN DEFAULT true NOT NULL,
	PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

```sql
CREATE TABLE `admin_wl` (
	`id` int(11) NOT NULL AUTO_INCREMENT,
	`ckey` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL,
	`admin_rank` varchar(32) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Administrator',
	`level` int(2) NOT NULL DEFAULT '0',
	`flags` int(16) NOT NULL DEFAULT '0',
	PRIMARY KEY (`id`),
	KEY `ckey` (`ckey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```
-----------------------------------------------------
