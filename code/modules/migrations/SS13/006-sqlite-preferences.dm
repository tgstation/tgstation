/datum/migration/ss13/sqlite
	id = 6
	name = "languages n shit son"

/datum/migration/ss13/sqlite/up()
	var/sqlitedb = ("players2.sqlite")
	var/list/tables = list("body" = list("ID" = "INTEGER PRIMARY KEY AUTOINCREMENT","player_ckey" = "TEXT NOT NULL","player_slot" = "INTEGER NOT NULL",\
										 "hair_red" = "INTEGER","hair_green" = "INTEGER","hair_blue" = "INTEGER","facial_red" = "INTEGER","facial_green" = "INTEGER",\
										 "facial_blue" = "INTEGER","skin_tone" = "INTEGER","hair_style_name" = "TEXT","facial_style_name" = "TEXT","eyes_red" = "INTEGER",\
										 "eyes_green" = "INTEGER","eyes_blue" = "INTEGER","underwear" = "INTEGER","backbag" = "INTEGER","b_type" = "TEXT"),\
							"jobs" = list("ID" = "INTEGER PRIMARY KEY AUTOINCREMENT","player_ckey" = "TEXT_NOT_NULL", "player_slot" = "INTEGER NOT NULL",\
										"alternate_option" = "INTEGER", "job_civilian_high" = "INTEGER", "job_civilian_med" = "INTEGER", "job_civilian_low" = "INTEGER",\
										"job_medsci_high" = "INTEGER", "job_medsci_med" = "INTEGER", "job_medsci_low" = "INTEGER", "job_engsec_high" = "INTEGER",\
										"job_engsec_med" = "INTEGER", "job_engsec_low" = "INTEGER"),\
							"limbs" = list("ID" = "INTEGER PRIMARY KEY AUTOINCREMENT", "player_ckey" = "TEXT NOT NULL","player_slot" = "INTEGER NOT NULL", "l_arm" = "TEXT",\
											"r_arm" = "TEXT", "l_leg" = "TEXT", "r_leg" = "TEXT", "l_foot" = "TEXT", "r_foot" = "TEXT", "l_hand" = "TEXT", "r_hand" = "TEXT", "heart" = "TEXT",\
											"eyes" = "TEXT", "lungs" = "TEXT", "liver" = "TEXT", "kidneys" = "TEXT"),\
							"players" = list("ID" = "INTEGER PRIMARY KEY AUTOINCREMENT", "player_ckey" = "TEXT NOT NULL","player_slot" = "INTEGER NOT NULL", "ooc_notes" = "TEXT", "real_name" = "TEXT",\
											"random_name" = "INTEGER", "gender" = "TEXT", "age" = "INTEGER", "species" = "TEXT", "language" = "TEXT", "flavor_text" = "TEXT", "med_record" = "TEXT",\
											"sec_record" = "TEXT","gen_record" = "TEXT", "player_alt_titles" = "TEXT", "be_special" = "TEXT", "disabilities" = "INTEGER", "nanotrasen_relation" = "TEXT"),\
							"client" = list("ID" = "INTEGER PRIMARY KEY AUTOINCREMENT", "ckey" = "INTEGER UNIQUE", "ooc_color" = "TEXT", "lastchangelog" = "TEXT", "UI_style" = "TEXT", "default_slot" = "INTEGER",\
											"toggles" = "INTEGER", "UI_style_color" = "TEXT", "UI_style_alpha" = "INTEGER", "randomslot" = "INTEGER", "volume" = "INTEGER", "special" = "INTEGER", "warns" = "INTEGER",\
											"warnbans" = "INTEGER", "usewmp" = "INTEGER", "usenanoui" = "INTEGER", "progress_bars" = "INTEGER"),\
							"client_roles" = list("ckey" = "TEXT NOT NULL", "slot" = "INTEGER NOT NULL", "role" = "TEXT NOT NULL", "preference" = "INTEGERNOT NULL"))
	if(tables && tables.len)
		var/database/query/check = new
		var/database/query/insert = new
		for(var/table in tables)
			var/list/columns = tables[table]
			testing("Checking migrations for sqlite table [table]([columns.len] entries)")
			check.Add("PRAGMA table_info('[table]');")
			if(!check.Execute(sqlitedb))
				warning("Error reading PRAGMA table info for table [table], [check.Error()] - [check.ErrorMsg()]")
				continue
			while(check.NextRow())
				var/row = check.GetRowData()
				var/name = row["name"]
				//testing("[table] has column [name]")
				columns.Remove(name)
			if(!columns.len)
				testing("[table] is up to date")
				continue
			//testing("Adding [columns.len] columns to [table]")
			for(var/column in columns)
				var/datatype = columns[column]
				testing("Adding \"[column]:[datatype]\" to [table]")
				insert.Add("ALTER TABLE [table] ADD '[column]' [datatype];")
				insert.Execute(sqlitedb)
				if(insert.Error()) warning("Error inserting column [column], [insert.Error()] - [insert.ErrorMsg()]")
		/*check.Add("SHOW COLUMNS FROM players LIKE [list2text(columns," OR LIKE ")]")
		if(check.Execute(sqlitedb))
			for(var/column in columns)
				if(!q.GetColumn(column))
					insert.Add("ALTER TABLE players ADD [column] VARCHAR(255)")
					insert.Execute(sqlitedb)
					if(insert.Error()) warning("Error inserting column [column], [insert.Error()] - [insert.ErrorMsg()]")
					insert.Clear()*/
