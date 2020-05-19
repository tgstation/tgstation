/datum/migration_controller
	var/list/db_states[0]
	var/list/packages[0]

	var/TABLE_NAME = "_migrations"
	var/id = ""

/datum/migration_controller/proc/setup()
	return FALSE
/datum/migration_controller/proc/createMigrationTable()
	return FALSE

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
		for(var/mtype in typesof(/datum/migration)-list(/datum/migration))
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

/datum/migration_controller/proc/getCurrentVersion(var/pkgID)
	return (pkgID in db_states) && db_states[pkgID]

/datum/migration_controller/proc/VersionCheck()
	for(var/pkgID in packages)
		var/currentVersion = getCurrentVersion(pkgID)
		var/latestVersionAvail = 0
		for(var/datum/migration/M in packages[pkgID])
			if(M.id > latestVersionAvail)
				latestVersionAvail = M.id
		if(latestVersionAvail > currentVersion)
			log_sql("\[Migrations] *** [pkgID] is behind [latestVersionAvail-currentVersion] versions!")

/datum/migration_controller/proc/UpdateAll()
	for(var/pkgID in packages)
		var/latestVersionAvail = 0
		for(var/datum/migration/M in packages[pkgID])
			if(M.id > latestVersionAvail)
				latestVersionAvail = M.id
		if(latestVersionAvail > getCurrentVersion())
			UpdatePackage(pkgID, latestVersionAvail)
	VersionCheck()

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
