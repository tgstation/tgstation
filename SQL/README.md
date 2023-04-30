## Updating the database

The latest database version is **5.23**.

### As a server operator...
The query to update the schema revision table is:

```sql
INSERT INTO `schema_revision` (`major`, `minor`) VALUES (5, 23);
```

or

```sql
INSERT INTO `SS13_schema_revision` (`major`, `minor`) VALUES (5, 23);
```

If you are behind, look through the `updates` folder in this directory. Run the queries for every file on a newer version. For example, if your database is currently on 5.20, you would run 5_21_xxx.sql, 5_22_xxx.sql, etc.

In any query remember to add a prefix to the table names if you use one.

### As a developer...
Any time you make a change to the schema files, remember to increment the database schema version. Generally increment the minor number, major should be reserved for significant changes to the schema. Both values go up to 255.

Make sure to update `DB_MAJOR_VERSION` and `DB_MINOR_VERSION`, which can be found in `code/__DEFINES/subsystem.dm`.

Then, file your changes as a .sql file in `updates`. The filename format is `MAJOR_MINOR_description_of_change.sql`. For example, if in 5.20, you add a "food" table, you might name it `5_20_food.sql`.

If you are using [ezdb](../.github/guides/EZDB.md), you should be able to rerun the script, and get all the new updates.
