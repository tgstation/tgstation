/**
 * The controller for [/datum/migration][migrations].
 *
 * The controller handles all the migration datums. It checks if a database connection exists, if the database has already done migrations, and how  many migrations it needs to apply.
 * All you need in order to make it run is to call its new() with SSdbcore correclty initialized.
 *
 * This abstract class handles the logic of appliying packages, checking versions, and giving logs on success or completion.
 * The logic which depends on which DB System you are using (MySQL, SQLite...) is to be defined in children types in the appropriate procs.
 *
 * @author Rob "N3X15" Nelson
 */

/datum/migration_controller
	/// The current states of the database. Associative list: "package_name = current_id".
	var/list/db_states[0]
	/// An associative list of packages to be applied in the form: "package_name = package". A package is in itself a list of migrations executed sequentially, by ascending id.
	var/list/packages[0]

	/// The name of the table the controller will use to check if the database is up to date or not.
	var/TABLE_NAME = "_migrations"
	/// How this controller will call itself in the logs.
	var/id = ""

/**
  * Initialize the migration controller.
  *
  * Checks if a database connection exists and if we can run queries on it. Return TRUE or FALSE depending on the result.
  * The migration controller will not run migrations and exit with a message if this returns FALSE.
  * Redefine this in children types depending on the system you are using.
  */
/datum/migration_controller/proc/setup()
	return FALSE

/**
  * Create the table the controller uses to check versions.
  *
  * Creates a table which is populated with packages IDs and packages numbers.
  * The controller will use it to check if the database is up to date with what the code is expecting.
  * Redefine this in children types depending on the system you are using.
  */
/datum/migration_controller/proc/createMigrationTable()
	return FALSE
/**
  * Creates the controller and make it do its job.
  *
  * This proc check if the controller can apply migrations, check which packages are up to date, and apply migrations.
  * 1. Check if a connection can be established using setup()
  * 2. Check if a migration table exists or not. Creates it if not.
  * 3. Uses subtypesof([/datum/migration]) to populate the list of packages to be applied.
  * A package is a list of related migrations applied sequentially.
  * 4. Uses UpdateAll() to apply all the needed migrations, package after package.
  *
  * This proc does not need to be redefined in children types.
  */
/datum/migration_controller/New()
	if(!setup())
		log_sql("\[Migrations] ([id]): Setup() returned false, will not run migrations for this DBMS.")
	else
		if(!hasTable(TABLE_NAME))
			log_sql("\[Migrations] ([id]): Creating [format_table_name(TABLE_NAME)]")
			createMigrationTable()

		for(var/list/row in query("SELECT pkgID, version FROM [format_table_name(TABLE_NAME)]"))
			if(id=="mysql")
				db_states[row[1]] = text2num(row[2])
			else
				db_states[row["pkgID"]] = text2num(row["version"])

		var/list/newpacks[0]
		for(var/mtype in subtypesof(/datum/migration))
			var/datum/migration/M = new mtype(src)
			if(M.package == "" || M.name == "" || M.dbms != id)
				continue
			if(!(M.package in newpacks))
				newpacks[M.package]=list()
			var/list/pack = newpacks[M.package]
			pack += M
		for(var/pkgID in newpacks)
			if(!(pkgID in packages))
				packages[pkgID]=list()
			var/list/prepack = newpacks[pkgID]
			var/list/pack[prepack.len]
			for(var/datum/migration/M in newpacks[pkgID])
				pack[M.id] = M
			packages[pkgID]=pack
			log_sql("\[Migrations] Loaded [pack.len] [id] DB migrations from package [pkgID].")
		UpdateAll()
/**
  * Get the current version (number of migrations applied) of a package in the database.
  * * pkgID - the ID of the package.
  */
/datum/migration_controller/proc/getCurrentVersion(var/pkgID)
	return (pkgID in db_states) && db_states[pkgID]

/**
  * Leaves a message in the logs if a package is missing migrations.
  */
/datum/migration_controller/proc/VersionCheck()
	for(var/pkgID in packages)
		var/currentVersion = getCurrentVersion(pkgID)
		var/latestVersionAvail = 0
		for(var/datum/migration/M in packages[pkgID])
			if(M.id > latestVersionAvail)
				latestVersionAvail = M.id
		if(latestVersionAvail > currentVersion)
			log_sql("\[Migrations] *** [pkgID] is behind [latestVersionAvail-currentVersion] versions!")

/**
  * Update all the packages if they are missing a version.
  */
/datum/migration_controller/proc/UpdateAll()
	for(var/pkgID in packages)
		var/latestVersionAvail = 0
		for(var/datum/migration/M in packages[pkgID])
			if(M.id > latestVersionAvail)
				latestVersionAvail = M.id
		if(latestVersionAvail > getCurrentVersion())
			UpdatePackage(pkgID, latestVersionAvail)
	VersionCheck()

/**
  * Update a given package to a given version.
  *
  * * pkgID - the ID of the package.
  * * to_version - version to update to.
  */
/datum/migration_controller/proc/UpdatePackage(var/pkgID, var/to_version=-1)
	var/list/package = packages[pkgID]
	var/from_version = getCurrentVersion(pkgID)
	if(to_version==-1)
		for(var/datum/migration/M in packages[pkgID])
			if(M.id > to_version)
				to_version = M.id
	if(from_version == to_version)
		log_sql("\[Migrations] [pkgID] is up to date.")
		return
	log_sql("\[Migrations] Updating [pkgID] from [from_version] to [to_version]...")
	for(var/datum/migration/M in package)
		if(M.id > from_version && M.id <= to_version)
			if(!M.up())
				log_sql("Failed to process migration [pkgID] #[M.id]")
				return FALSE
			else
				M.execute("REPLACE INTO [format_table_name(TABLE_NAME)] (pkgID,version) VALUES ('[pkgID]',[M.id])") // SQLite also supports REPLACE.
				log_sql("\[Migrations] Successfully applied [pkgID]#[M.id] ([M.name])")
	log_sql("\[Migrations] Done!")
	return TRUE

/**
  * Helper procs.
  *
  * These procs are redefined in child types to perform SQL operations depending on the system you are using. (MySQL, SQLite, etc.)
  * See also : [/datum/migration].
  *
  */

/datum/migration_controller/proc/query(var/sql)
	var/datum/DBQuery/query = execute(sql)

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	return rows

/datum/migration_controller/proc/hasResult(var/sql)
	return FALSE

/datum/migration_controller/proc/execute(var/sql)
	return list()

/datum/migration_controller/proc/hasTable(var/tableName)
	return FALSE
