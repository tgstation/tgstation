var/B_shadowling = 8192

/datum/preferences/proc/hippie_character_pref_load(savefile/S)
	//moths
	S["feature_moth_wings"] >> features["moth_wings"]
	features["moth_wings"] 	= sanitize_inlist(features["moth_wings"], GLOB.moth_wings_list)
	//gear loadout
	var/text_to_load
	S["loadout"] >> text_to_load
	var/list/saved_loadout_paths = splittext(text_to_load, "|")
	LAZYCLEARLIST(chosen_gear)
	gear_points = initial(gear_points)
	for(var/i in saved_loadout_paths)
		var/datum/gear/path = text2path(i)
		if(path)
			LAZYADD(chosen_gear, path)
			gear_points -= initial(path.cost)

/datum/preferences/update_antagchoices(current_version, savefile/S) //shadowling override
	if((!islist(be_special) || old_be_special ) && current_version < 12)
		//Archived values of when antag pref defines were a bitfield+fitflags
		var/B_traitor = 1
		var/B_operative = 2
		var/B_changeling = 4
		var/B_wizard = 8
		var/B_malf = 16
		var/B_rev = 32
		var/B_alien = 64
		var/B_pai = 128
		var/B_cultist = 256
		var/B_blob = 512
		var/B_ninja = 1024
		var/B_monkey = 2048
		var/B_gang = 4096
		var/B_shadowling = 8192
		var/B_abductor = 16384

		var/B_vampire = 32768

		var/list/archived = list(B_traitor,B_operative,B_changeling,B_wizard,B_malf,B_rev,B_alien,B_pai,B_cultist,B_blob,B_ninja,B_monkey,B_gang,B_abductor,B_shadowling,B_vampire)

		be_special = list()

		for(var/flag in archived)
			if(old_be_special & flag)
				//this is shitty, but this proc should only be run once per player and then never again for the rest of eternity,
				switch(flag)
					if(1) //why aren't these the variables above? Good question, it's because byond complains the expression isn't constant, when it is.
						be_special += ROLE_TRAITOR
					if(2)
						be_special += ROLE_OPERATIVE
					if(4)
						be_special += ROLE_CHANGELING
					if(8)
						be_special += ROLE_WIZARD
					if(16)
						be_special += ROLE_MALF
					if(32)
						be_special += ROLE_REV
					if(64)
						be_special += ROLE_ALIEN
					if(128)
						be_special += ROLE_PAI
					if(256)
						be_special += ROLE_CULTIST
					if(512)
						be_special += ROLE_BLOB
					if(1024)
						be_special += ROLE_NINJA
					if(2048)
						be_special += ROLE_MONKEY
					if(8192)
						be_special += ROLE_SHADOWLING
					if(16384)
						be_special += ROLE_ABDUCTOR
					if(32768)
						be_special += ROLE_VAMPIRE

/datum/preferences/proc/hippie_character_pref_save(savefile/S)
	//moths
	S["feature_moth_wings"] << features["moth_wings"]
	//gear loadout
	if(islist(chosen_gear))
		if(chosen_gear.len)
			var/text_to_save = chosen_gear.Join("|")
			S["loadout"] << text_to_save
		else
			S["loadout"] << "" //empty string to reset the value
