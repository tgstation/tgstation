

var/global/datum/migration_controller/migration_controller = null

/datum/migration_controller
	var/list/db_states[0]
	var/list/packages[0]

	var/TABLE_NAME = "_migrations"
	var/DBConnection/db

/datum/migration_controller/New()
	// Change this if needed.
	db = dbcon
	/////////////////////////

	if(!db || !db.IsConnected())
		return

	var/DBQuery/Q=null

	if(!hasTable(TABLE_NAME))
		var/tableSQL = {"
CREATE TABLE IF NOT EXISTS [TABLE_NAME] (
	pkgID VARCHAR(15) PRIMARY KEY, -- Implies NOT NULL
	version INT(11) NOT NULL
);
		"}
		Q = db.NewQuery(tableSQL)
		Q.Execute()
		Q.Close()

	Q = db.NewQuery("SELECT pkgID, version FROM [TABLE_NAME]")
	Q.Execute()
	while(Q.NextRow())
		db_states[Q.item[1]] = text2num(Q.item[2])

	var/list/newpacks[0]
	for(var/mtype in typesof(/datum/migration)-/datum/migration)
		var/datum/migration/M = new mtype()
		M.db = db
		if(M.package == "" || M.name == "") continue
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
			//world.log << "\[Migrations] [pkgID]#[M.id] = [M.type] - [M.name]"
		packages[pkgID]=pack
		world.log << "\[Migrations] Loaded [pack.len] DB migrations from package [pkgID]."

	//VersionCheck()
	UpdateAll()

/datum/migration_controller/proc/getCurrentVersion(var/pkgID)
	if(pkgID in db_states)
		return db_states[pkgID]
	else
		return 0

/datum/migration_controller/proc/VersionCheck()
	for(var/pkgID in packages)
		var/currentVersion = getCurrentVersion(pkgID)
		var/latestVersionAvail = 0
		for(var/datum/migration/M in packages[pkgID])
			if(M.id > latestVersionAvail)
				latestVersionAvail = M.id
		//world.log << "\[Migrations] Package [pkgID]: Current: [currentVersion], Avail: [latestVersionAvail]"
		if(latestVersionAvail > currentVersion)
			world.log << "\[Migrations] *** [pkgID] is behind [latestVersionAvail-currentVersion] versions!"

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
		world.log << "\[Migrations] [pkgID] is up to date."
		return
	world.log << "\[Migrations] Updating [pkgID] from [from_version] to [to_version]..."
	for(var/datum/migration/M in package)
		if(M.id > from_version && M.id <= to_version)
			if(!M.up())
				//world << "[log_text] <span style='font-weight:bold;color:red;'>FAIL</span><br>Failed to process migration [pkgID] #[M.id]!"
				world.log << "Failed to process migration [pkgID] #[M.id]"
				return FALSE
			else
				M.execute("REPLACE INTO [TABLE_NAME] (pkgID,version) VALUES ('[pkgID]',[M.id])")
				world.log << "\[Migrations] Successfully applied [pkgID]#[M.id] ([M.name])"
	world.log << "\[Migrations] Done!"
	return TRUE

/datum/migration_controller/proc/query(var/sql)
	var/DBQuery/query = execute(sql)

	var/list/rows=list()
	while(query.NextRow())
		rows += list(query.item)
	return rows

/datum/migration_controller/proc/hasResult(var/sql)
	var/DBQuery/query = execute(sql)

	if (query.NextRow())
		return TRUE
	return FALSE

/datum/migration_controller/proc/execute(var/sql)
	var/DBQuery/query = db.NewQuery(sql)
	query.Execute()
	return query

/datum/migration_controller/proc/hasTable(var/tableName)
	return hasResult("SHOW TABLES LIKE '[tableName]")