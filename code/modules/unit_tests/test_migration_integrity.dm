/datum/unit_test/test_migration_integrity/Run()
    var/list/seenVersions = list()
    var/highest_major = 0
    var/highest_minor = 0
    for(var/I in subtypesof(/datum/database_migration))
        var/datum/database_migration/test = new I
        if(!isnum(test.schema_version_major))
            Fail("[I].schema_version_major is not a number!")
        if(!isnum(test.schema_version_minor))
            Fail("[I].schema_version_minor is not a number!")

        if(test.schema_version_major > highest_major)
            highest_major = test.schema_version_major
            highest_minor = test.schema_version_minor
        else if(test.schema_version_major == highest_major && test.schema_version_minor > highest_minor)
            highest_minor = test.schema_version_minor

        var/versionString = "[test.schema_version_major].[test.schema_version_minor]"
        if(test.schema_version_major < 4 || (test.schema_version_major == 4 && test.schema_version_minor))
            Fail("Migration [I] has schema version <= 4.7 ([versionString]) which is a legacy schema version!")

        if(seenVersions[versionString])
            Fail("Both [I] and [seenVersions[versionString]] have the same schema version ([versionString])!")
        else
            seenVersions[versionString] = I

    if(highest_major != DB_MAJOR_VERSION || highest_minor != DB_MINOR_VERSION)
        Fail("DB_VERSION defines ([DB_MAJOR_VERSION].[DB_MINOR_VERSION]) don't match highest available migrations ([highestMajor].[highestMinor])!")
