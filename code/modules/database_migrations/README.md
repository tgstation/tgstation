# Migration System

Allows the game to make table changes in a non-breaking fashion. These changes will be applied at the start of rounds if the server is configured to

## Creating a new migration

1. Create a file in the format `<schema major version>.<schema minor version>_<migration_name>.dm`, add it to the `.dme`
2. In that file create the type `/datum/database_migration/<migration_name>`. Set the `schema_version_major` and `schema_version_minor fields appropriatly
3. Override the `Up()` and `Down()` procs
    - In these procs call `M("<sql query>")` to make modifications. Do no error checking, or modifications to the `schema_version` table the framework will handle transactions and aborting.
        - Result sets are currently not supported. Change the implementation if necessary
    - The `Up()` proc should upgrade the schema the specified version
    - The `Down()` proc should perform queries to undo the `Up()` proc

Do not modify old migrations, add in-between versions, or add versions < 4.7
