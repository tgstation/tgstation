#define SAVEFILE_VERSION_MIN	5
#define SAVEFILE_VERSION_MAX	6

datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

datum/preferences/proc/savefile_getslots(mob/user)
	if(IsGuestKey(user.key))
		return new/list()

	var/path = savefile_path(user)
	if(!fexists(path))
		return new/list()

	var/list/slots = new()
	var/savefile/F = new(path)

	// slot 1
	slots.Add(F["slotname"] ? F["slotname"] : "Default") // allow old prefs saves to be loaded as slot 1

	// slots 2 - len
	for(var/i=1, i<=F.dir.len, i++)
		var/dname = F.dir[i]
		if(copytext(dname, 1, 6) == "slot.")
			slots.Insert(2, copytext(dname, 6)) // reverse order so it's oldest->newest, like old system

	return slots

datum/preferences/proc/savefile_createslot(mob/user, slotname)
	if(IsGuestKey(user.key))
		return

	var/path = savefile_path(user)
	if(!fexists(path))
		return

	var/savefile/F = new(path)

	// 1st?
	if(!F["real_name"])
		F["slotname"] = "Default"
		randomize_name()
	else
		F.dir.Add("slot." + slotname)

	var/list/slots = savefile_getslots(user)
	var/slot = slots.Find(slotname)
	savefile_save(user, slot)
	return slot

datum/preferences/proc/savefile_removeslot(mob/user, slot)
	if(IsGuestKey(user.key))
		return

	var/path = savefile_path(user)
	if(!fexists(path))
		return

	var/list/slots = savefile_getslots(user)

	if(slot > 1)
		var/savefile/F = new(path)
		F.dir.Remove("slot." + slots[slot])
	else if(slots.len >= 2)
		// otherwise, we're deleting slot 1, and must move slot 2 to slot 1
		savefile_load(user, 2)
		savefile_save(user, 1)

		var/savefile/F = new(path)
		F["slotname"] = slots[2] // slot 1's name <- slot 2's name
		F.dir.Remove("slot." + slots[2])
	else
		// otherwise, we're wiping the last save (slot 1)
		// actually no, that makes unintuitive, weird things happen
		//F["slotname"] = null
		//F["real_name"] = null
		user << "You must have at least one slot!"

datum/preferences/proc/savefile_save(mob/user, slot)
	if (IsGuestKey(user.key))
		return 0

	var/list/slots = savefile_getslots(user)
	var/savefile/F = new(savefile_path(user))

	//	var/version
	//	F["version"] >> version

	F["version"] << SAVEFILE_VERSION_MAX

	// make this compatible with old single-slot system, making slot 1 be in root
	if(slot != 1)
		if(slots.len < slot)
			return 0
		F.cd = "slot." + slots[slot]

	F["real_name"] << src.real_name
	F["name_is_always_random"] << src.be_random_name

	F["flavor_text"] << flavor_text

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

	F["job_alt_titles"] << job_alt_titles

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
	F["UI"] << src.UI
	F["midis"] << src.midis
	F["ghost_ears"] << src.ghost_ears
	F["pregame_music"] << src.pregame_music
	F["ooccolor"] << src.ooccolor
	F["lastchangelog"] << src.lastchangelog
	F["disabilities"] << src.disabilities

	F["used_skillpoints"] << src.used_skillpoints
	F["skills"] << src.skills
	F["skill_specialization"] << src.skill_specialization

	F["OOC_Notes"] << src.metadata

	return 1

// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist

datum/preferences/proc/savefile_load(mob/user, slot)
	if(IsGuestKey(user.key))	return 0

	var/path = savefile_path(user)
	if(!fexists(path))
		// make it then!
		savefile_save(user, slot)

	var/savefile/F = new(path)

	var/version = null
	F["version"] >> version

	if (isnull(version) || version < SAVEFILE_VERSION_MIN || version > SAVEFILE_VERSION_MAX)
		fdel(path)
		alert(user, "Your savefile was incompatible with this version and was deleted.")
		return 0

	// make this compatible with old single-slot system, making slot 1 be in root
	if(slot == 0)
		return 0
	if(slot != 1)
		var/list/slots = savefile_getslots(user)
		if(slots.len < slot)
			return 0
		F.cd = "slot." + slots[slot]

	F["real_name"] >> src.real_name
	F["gender"] >> src.gender
	F["age"] >> src.age

	F["flavor_text"] >> flavor_text

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
	if(underwear == 0) underwear = 6 //For old players who have 0 in their savefile
	F["backbag"] >> src.backbag
	if(isnull(backbag)) backbag = 2
	F["name_is_always_random"] >> src.be_random_name
	F["midis"] >> src.midis
	F["ghost_ears"] >> src.ghost_ears
	if(isnull(ghost_ears)) ghost_ears = 1 //Hotfix
	F["pregame_music"] >> src.pregame_music
	F["ooccolor"] >> src.ooccolor
	F["lastchangelog"] >> src.lastchangelog
	F["UI"] >> src.UI
	F["be_special"] >> src.be_special

	F["job_civilian_high"] >> src.job_civilian_high
	F["job_civilian_med"] >> src.job_civilian_med
	F["job_civilian_low"] >> src.job_civilian_low

	F["job_medsci_high"] >> src.job_medsci_high
	F["job_medsci_med"] >> src.job_medsci_med
	F["job_medsci_low"] >> src.job_medsci_low


	F["used_skillpoints"] >> src.used_skillpoints
	F["skills"] >> src.skills
	F["skill_specialization"] >> src.skill_specialization
	if(!src.skills) src.skills = list()
	if(!src.used_skillpoints) src.used_skillpoints= 0

	F["job_engsec_high"] >> src.job_engsec_high
	F["job_engsec_med"] >> src.job_engsec_med
	F["job_engsec_low"] >> src.job_engsec_low
	F["disabilities"] >> src.disabilities
	if(isnull(src.disabilities))	//Sanity checking
		src.disabilities = 0
		F["disabilities"] << src.disabilities

	F["job_alt_titles"] >> job_alt_titles
	if(!job_alt_titles)
		job_alt_titles = new()

	F["OOC_Notes"] >> src.metadata

	if(isnull(metadata))
		metadata = ""

	//NOTE: Conversion things go inside this if statement
	//When updating the save file remember to add 1 to BOTH the savefile constants
	//Also take the old conversion things that no longer apply out of this if
	if(version && version < SAVEFILE_VERSION_MAX)
		convert_hairstyles() // convert version 4 hairstyles to version 5

	style_to_datum() // convert f_style and h_style to /datum

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

