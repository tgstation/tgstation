#define SAVEFILE_VERSION_MIN	7
#define SAVEFILE_VERSION_MAX	7

datum/preferences/proc/savefile_path(mob/user)
	if(!user.client)
		return null
	else
		return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences[user.client.activeslot].sav"

datum/preferences/proc/savefile_saveslot(mob/user,var/slot)//Mirrors default slot across each save
	if(!user.client)
		return null
	else
		for(var/i = 1; i <= MAX_SAVE_SLOTS; i += 1)
			var/savefile/F = new /savefile("data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences[i].sav")
			F["default_slot"] << slot
	return 1

datum/preferences/proc/savefile_save(mob/user)
	if (IsGuestKey(user.key))
		return 0

	var/savefile/F = new /savefile(src.savefile_path(user))
//	var/version
//	F["version"] >> version

	F["version"] << SAVEFILE_VERSION_MAX

	F["real_name"] << src.real_name
	F["name_is_always_random"] << src.be_random_name

	F["gender"] << src.gender
	F["age"] << src.age

	//Job data
	F["job_civilian_high"] << src.job_civilian_high
	F["job_civilian_med"] << src.job_civilian_med
	F["job_civilian_low"] << src.job_civilian_low

	F["job_medsci_high"] << src.job_medsci_high
	F["job_medsci_med"] << src.job_medsci_med
	F["job_medsci_low"] << src.job_medsci_low

	F["job_engsec_high"] << src.job_engsec_high
	F["job_engsec_med"] << src.job_engsec_med
	F["job_engsec_low"] << src.job_engsec_low

	F["userandomjob"] << src.userandomjob

	//Body data
	F["hair_red"] << src.r_hair
	F["hair_green"] << src.g_hair
	F["hair_blue"] << src.b_hair
	F["facial_red"] << src.r_facial
	F["facial_green"] << src.g_facial
	F["facial_blue"] << src.b_facial
	F["skin_tone"] << src.s_tone
	F["hair_style_name"] << src.h_style
	F["facial_style_name"] << src.f_style
	F["eyes_red"] << src.r_eyes
	F["eyes_green"] << src.g_eyes
	F["eyes_blue"] << src.b_eyes
	F["blood_type"] << src.b_type
	F["underwear"] << src.underwear
	F["backbag"] << src.backbag
	F["backbag"] << src.backbag



	F["be_special"] << src.be_special
	//F["UI"] << src.UI
	if(isnull(UI_style))
		UI_style = "Midnight"
	F["UI_style"] << UI_style
	F["midis"] << src.midis
	F["ghost_ears"] << src.ghost_ears
	F["ghost_sight"] << src.ghost_sight
	F["ooccolor"] << src.ooccolor
	F["lastchangelog"] << src.lastchangelog

	F["OOC_Notes"] << src.metadata

	F["sound_adminhelp"] << src.sound_adminhelp
	F["default_slot"] << src.default_slot
	F["slotname"] << src.slot_name
	F["lobby_music"] << src.lobby_music

	return 1

// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist

datum/preferences/proc/savefile_load(mob/user)
	if(IsGuestKey(user.key))	return 0

	var/path = savefile_path(user)

	if(!fexists(path))
		//Is there a preference file before this was committed?
		path = "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"
		if(!fexists(path))
			//No there is not
			return 0
		else
			//Yes there is. Let's rename it.
			var/savefile/oldsave = new/savefile(path)
			fcopy(oldsave, savefile_path(user))
			fdel(path) // We don't need the old file anymore
			path = savefile_path(user)
			// Did nothing break?
			if(!fexists(path))
				return 0

	var/savefile/F = new /savefile(path)

	var/version = null
	F["version"] >> version

	if(isnull(version) || version < SAVEFILE_VERSION_MIN || version > SAVEFILE_VERSION_MAX)
		fdel(path)
		if(version)
			alert(user, "Your savefile was incompatible with this version and was deleted.")
		return 0

	F["real_name"] >> src.real_name
	F["gender"] >> src.gender
	F["age"] >> src.age

	F["hair_red"] >> src.r_hair
	F["hair_green"] >> src.g_hair
	F["hair_blue"] >> src.b_hair
	F["facial_red"] >> src.r_facial
	F["facial_green"] >> src.g_facial
	F["facial_blue"] >> src.b_facial
	F["skin_tone"] >> src.s_tone
	F["hair_style_name"] >> src.h_style
	F["facial_style_name"] >> src.f_style
	F["eyes_red"] >> src.r_eyes
	F["eyes_green"] >> src.g_eyes
	F["eyes_blue"] >> src.b_eyes
	F["blood_type"] >> src.b_type
	F["underwear"] >> src.underwear
	if(underwear == 0) underwear = 12 //For old players who have 0 in their savefile
	F["backbag"] >> src.backbag
	if(isnull(backbag)) backbag = 2
	F["name_is_always_random"] >> src.be_random_name
	F["midis"] >> src.midis
	F["ghost_ears"] >> src.ghost_ears
	if(isnull(ghost_ears)) ghost_ears = 1 //Hotfix
	F["ghost_sight"] >> src.ghost_sight
	if(isnull(ghost_sight)) ghost_sight = 1 //Hotfix
	F["ooccolor"] >> src.ooccolor
	F["lastchangelog"] >> src.lastchangelog
	//F["UI"] >> src.UI
	F["UI_style"] >> src.UI_style
	if(isnull(UI_style))
		UI_style = "Midnight"
	F["be_special"] >> src.be_special

	F["job_civilian_high"] >> src.job_civilian_high
	F["job_civilian_med"] >> src.job_civilian_med
	F["job_civilian_low"] >> src.job_civilian_low

	F["job_medsci_high"] >> src.job_medsci_high
	F["job_medsci_med"] >> src.job_medsci_med
	F["job_medsci_low"] >> src.job_medsci_low

	F["job_engsec_high"] >> src.job_engsec_high
	F["job_engsec_med"] >> src.job_engsec_med
	F["job_engsec_low"] >> src.job_engsec_low

	F["userandomjob"] >> src.userandomjob

	F["OOC_Notes"] >> src.metadata

	F["sound_adminhelp"] >> src.sound_adminhelp
	F["default_slot"] >> src.default_slot
	if(isnull(default_slot))
		default_slot = 1
	F["slotname"] >> src.slot_name
	F["lobby_music"] >> src.lobby_music
	if(isnull(lobby_music))
		lobby_music = 1

	if(isnull(metadata))
		metadata = ""

	//NOTE: Conversion things go inside this if statement
	//When updating the save file remember to add 1 to BOTH the savefile constants
	//Also take the old conversion things that no longer apply out of this if
	if(version && version < SAVEFILE_VERSION_MAX)
		convert_hairstyles() // convert version 4 hairstyles to version 5

	return 1

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN



datum/preferences/proc/convert_hairstyles()
	// convert hairstyle names from old savefiles
	switch(h_style)
		if("Balding")
			h_style = "Balding Hair"
		if("Fag")
			h_style = "Flow Hair"
		if("Jensen Hair")
			h_style = "Adam Jensen Hair"
		if("Kusangi Hair")
			h_style = "Kusanagi Hair"

	switch(f_style)
		if("Watson")
			f_style = "Watson Mustache"
		if("Chaplin")
			f_style = "Square Mustache"
		if("Selleck")
			f_style = "Selleck Mustache"
		if("Van Dyke")
			f_style = "Van Dyke Mustache"
		if("Elvis")
			f_style = "Elvis Sideburns"
		if("Abe")
			f_style = "Abraham Lincoln Beard"
		if("Hipster")
			f_style = "Hipster Beard"
		if("Hogan")
			f_style = "Hulk Hogan Mustache"
		if("Jensen Goatee")
			f_style = "Adam Jensen Beard"
	return

#undef SAVEFILE_VERSION_MIN
#undef SAVEFILE_VERSION_MAX
