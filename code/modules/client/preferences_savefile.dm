#define SAVEFILE_VERSION_MIN	8
#define SAVEFILE_VERSION_MAX	11

//handles converting savefiles to new formats
//MAKE SURE YOU KEEP THIS UP TO DATE!
//If the sanity checks are capable of handling any issues. Only increase SAVEFILE_VERSION_MAX,
//this will mean that savefile_version will still be over SAVEFILE_VERSION_MIN, meaning
//this savefile update doesn't run everytime we load from the savefile.
//This is mainly for format changes, such as the bitflags in toggles changing order or something.
//if a file can't be updated, return 0 to delete it and start again
//if a file was updated, return 1


/datum/preferences/proc/savefile_update()
	// Preseed roles.
	for(var/role_id in special_roles)
		roles[role_id]=0

	if(savefile_version < 8)	//lazily delete everything + additional files so they can be saved in the new format
		for(var/ckey in preferences_datums)
			var/datum/preferences/D = preferences_datums[ckey]
			if(D == src)
				var/delpath = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/"
				if(delpath && fexists(delpath))
					fdel(delpath)
				break
		return 0

	if(savefile_version == SAVEFILE_VERSION_MAX)	//update successful.
		save_preferences()
		save_character()
		return 1
	return 0


/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)	return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"
	savefile_version = SAVEFILE_VERSION_MAX


/datum/preferences/proc/load_preferences_sqlite(var/ckey)
	var/list/preference_list_client = new
	var/database/query/check = new
	var/database/query/q = new
	check.Add("SELECT ckey FROM client WHERE ckey = ?", ckey)
	if(check.Execute(db))
		if(!check.NextRow())
			return 0
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	q.Add("SELECT * FROM client WHERE ckey = ?", ckey)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			for(var/a in row)
				preference_list_client[a] = row[a]
	else
		message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	ooccolor 		=	preference_list_client["ooc_color"]
	lastchangelog 	= 	preference_list_client["lastchangelog"]
	UI_style 		=	preference_list_client["UI_style"]
	default_slot 	=	text2num(preference_list_client["default_slot"])
	toggles 		=	text2num(preference_list_client["toggles"])
	UI_style_color	= 	preference_list_client["UI_style_color"]
	UI_style_alpha 	= 	text2num(preference_list_client["UI_style_alpha"])
	warns			=	text2num(preference_list_client["warns"])
	warnbans		=	text2num(preference_list_client["warnsbans"])
	volume			=	text2num(preference_list_client["volume"])
	special_popup	=	text2num(preference_list_client["special"])
	randomslot		=	text2num(preference_list_client["randomslot"])

	ooccolor		= 	sanitize_hexcolor(ooccolor, initial(ooccolor))
	lastchangelog	= 	sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= 	sanitize_inlist(UI_style, list("White", "Midnight","Orange","old"), initial(UI_style))
	//be_special		= 	sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= 	sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles			= 	sanitize_integer(toggles, 0, 65535, initial(toggles))
	UI_style_color	= 	sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= 	sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= 	sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= 	sanitize_integer(volume, 0, 100, initial(volume))
	special_popup	= 	sanitize_integer(special_popup, 0, 1, initial(special_popup))

	return 1


/datum/preferences/proc/load_preferences()
	if(!path)				return 0
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["version"] >> savefile_version
	//Conversion
	if(!savefile_version || !isnum(savefile_version) || savefile_version < SAVEFILE_VERSION_MIN || savefile_version > SAVEFILE_VERSION_MAX)
		if(!savefile_update())  //handles updates
			savefile_version = SAVEFILE_VERSION_MAX
			save_preferences()
			save_character()
			return 0

	//general preferences
	S["ooccolor"]			>> ooccolor
	S["lastchangelog"]		>> lastchangelog
	S["UI_style"]			>> UI_style
	//S["be_special"]			>> be_special
	S["default_slot"]		>> default_slot
	S["toggles"]			>> toggles
	S["UI_style_color"]		>> UI_style_color
	S["UI_style_alpha"]		>> UI_style_alpha
	S["warns"]				>> warns
	S["warnbans"]			>> warnbans
	S["randomslot"]			>> randomslot
	S["volume"]				>> volume
	S["special_popup"]		>> special_popup
	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, list("White", "Midnight","Orange","old"), initial(UI_style))
	//be_special		= sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= sanitize_integer(volume, 0, 100, initial(volume))
	special_popup	= sanitize_integer(special_popup, 0, 1, initial(special_popup))
	return 1


/datum/preferences/proc/save_preferences_sqlite(var/user, var/ckey)
	if(!(world.timeofday >= (lastPolled + POLLED_LIMIT)))
		user << "You need to wait [round((((lastPolled + POLLED_LIMIT) - world.timeofday) / 10))] seconds before you can save again."
		return

	var/database/query/check = new
	var/database/query/q = new
	check.Add("SELECT ckey FROM client WHERE ckey = ?", ckey)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT into client (ckey, ooc_color, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, special) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",\
			ckey, ooccolor, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, special_popup)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
		else
			q.Add("UPDATE client SET ooc_color=?,lastchangelog=?,UI_style=?,default_slot=?,toggles=?,UI_style_color=?,UI_style_alpha=?,warns=?,warnbans=?,randomslot=?,volume=?,special=? WHERE ckey = ?",\
			ooccolor, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, special_popup, ckey)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	user << "Preferences Updated."
	lastPolled = world.timeofday
	return 1

/datum/preferences/proc/save_preferences()
	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["version"] << savefile_version

	//general preferences
	S["ooccolor"]			<< ooccolor
	S["lastchangelog"]		<< lastchangelog
	S["UI_style"]			<< UI_style
	//S["be_special"]			<< be_special
	S["default_slot"]		<< default_slot
	S["toggles"]			<< toggles
	S["UI_style_color"]		<< UI_style_color
	S["UI_style_alpha"]		<< UI_style_alpha
	S["warns"]				<< warns
	S["warnbans"]			<< warnbans
	S["randomslot"]			<< randomslot
	S["volume"]				<< volume
	return 1

//saving volume changes
/datum/preferences/proc/save_volume()
	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["volume"]				<< volume
	return 1

/datum/preferences/proc/load_save_sqlite(var/ckey, var/user, var/slot)
	var/list/preference_list = new
	var/database/query/q     = new
	var/database/query/check = new

	check.Add("SELECT player_ckey FROM players WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			user << "You have no character file to load, please save one first."
			return 0
	else
		message_admins("load_save_sqlite Check Error #: [check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	q.Add({"
SELECT
    limbs.player_ckey,
    limbs.player_slot,
    limbs.l_arm,
    limbs.r_arm,
    limbs.l_leg,
    limbs.r_leg,
    limbs.l_foot,
    limbs.r_foot,
    limbs.l_hand,
    limbs.r_hand,
    limbs.heart,
    limbs.eyes,
    players.player_ckey,
    players.player_slot,
    players.ooc_notes,
    players.real_name,
    players.random_name,
    players.gender,
    players.age,
    players.species,
    players.language,
    players.flavor_text,
    players.med_record,
    players.sec_record,
    players.gen_record,
    players.player_alt_titles,
    players.disabilities,
    players.nanotrasen_relation,
    jobs.player_ckey,
    jobs.player_slot,
    jobs.alternate_option,
    jobs.job_civilian_high,
    jobs.job_civilian_med,
    jobs.job_civilian_low,
    jobs.job_medsci_high,
    jobs.job_medsci_med,
    jobs.job_medsci_low,
    jobs.job_engsec_high,
    jobs.job_engsec_med,
    jobs.job_engsec_low,
    body.player_ckey,
    body.player_slot,
    body.hair_red,
    body.hair_green,
    body.hair_blue,
    body.facial_red,
    body.facial_green,
    body.facial_blue,
    body.skin_tone,
    body.hair_style_name,
    body.facial_style_name,
    body.eyes_red,
    body.eyes_green,
    body.eyes_blue,
    body.underwear,
    body.backbag,
    body.b_type
FROM
    players
INNER JOIN
    limbs
ON
    (
        players.player_ckey = limbs.player_ckey)
AND (
        players.player_slot = limbs.player_slot)
INNER JOIN
    jobs
ON
    (
        limbs.player_ckey = jobs.player_ckey)
AND (
        limbs.player_slot = jobs.player_slot)
INNER JOIN
    body
ON
    (
        jobs.player_ckey = body.player_ckey)
AND (
        jobs.player_slot = body.player_slot)
WHERE
    players.player_ckey = ?
AND players.player_slot = ? ;"}, ckey, slot)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			for(var/a in row)
				preference_list[a] = row[a]
	else
		message_admins("load_save_sqlite Error #: [q.Error()] - [q.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	var/list/player_alt_list1 = new
	var/list/player_alt_list2 = new()
	player_alt_list1.Add(text2list(preference_list["player_alt_titles"], ";")) // we're getting the first part of the string for each job.
	for(var/item in player_alt_list1) // iterating through the list
		if(!findtext(item, ":"))
			continue
		var/delim_location = findtext(item, ":") // getting the second part of the string that will be handled for titles
		var/job = copytext(item, 1, delim_location) // getting where the job is, it's in the first slot so we want to get that position.
		var/title = copytext(item, delim_location + 1, 0) // getting where the job title is, it's in the second slot so we want to get that position.
		player_alt_list2[job] = title // we assign the alt_titles here to specific job titles and hope everything works.

	metadata 			= preference_list["ooc_notes"]
	real_name 			= preference_list["real_name"]
	be_random_name 		= text2num(preference_list["random_name"])
	gender 				= preference_list["gender"]
	age 				= text2num(preference_list["age"])
	species				= preference_list["species"]
	language			= preference_list["language"]
	flavor_text			= preference_list["flavor_text"]
	med_record			= preference_list["med_record"]
	sec_record			= preference_list["sec_record"]
	gen_record			= preference_list["gen_record"]
	player_alt_titles	= player_alt_list2
	disabilities		= text2num(preference_list["disabilities"])
	nanotrasen_relation	= preference_list["nanotrasen_relation"]

	r_hair				= text2num(preference_list["hair_red"])
	g_hair				= text2num(preference_list["hair_green"])
	b_hair				= text2num(preference_list["hair_blue"])
	h_style				= preference_list["hair_style_name"]

	r_facial			= text2num(preference_list["facial_red"])
	g_facial			= text2num(preference_list["facial_green"])
	b_facial			= text2num(preference_list["facial_blue"])
	f_style				= preference_list["facial_style_name"]

	r_eyes				= text2num(preference_list["eyes_red"])
	g_eyes				= text2num(preference_list["eyes_green"])
	b_eyes				= text2num(preference_list["eyes_blue"])

	s_tone				= text2num(preference_list["skin_tone"])

	underwear			= text2num(preference_list["underwear"])
	backbag				= text2num(preference_list["backbag"])
	b_type				= preference_list["b_type"]

	organ_data["l_arm"] = preference_list["l_arm"]
	organ_data["r_arm"] = preference_list["r_arm"]
	organ_data["l_leg"] = preference_list["l_leg"]
	organ_data["r_leg"] = preference_list["r_leg"]
	organ_data["l_foot"]= preference_list["l_foot"]
	organ_data["r_foot"]= preference_list["r_foot"]
	organ_data["l_hand"]= preference_list["l_hand"]
	organ_data["r_hand"]= preference_list["r_hand"]
	organ_data["heart"] = preference_list["heart"]
	organ_data["eyes"] 	= preference_list["eyes"]

	alternate_option	= text2num(preference_list["alternate_option"])
	job_civilian_high	= text2num(preference_list["job_civilian_high"])
	job_civilian_med	= text2num(preference_list["job_civilian_med"])
	job_civilian_low	= text2num(preference_list["job_civilian_low"])
	job_medsci_high		= text2num(preference_list["job_medsci_high"])
	job_medsci_med		= text2num(preference_list["job_medsci_med"])
	job_medsci_low		= text2num(preference_list["job_medsci_low"])
	job_engsec_high		= text2num(preference_list["job_engsec_high"])
	job_engsec_med		= text2num(preference_list["job_engsec_med"])
	job_engsec_low		= text2num(preference_list["job_engsec_low"])


	metadata			= sanitize_text(metadata, initial(metadata))
	real_name			= reject_bad_name(real_name)

	if(isnull(species)) species = "Human"
	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(!real_name) real_name = random_name(gender,species)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))

	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))

	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))

	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))

	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))

	underwear		= sanitize_integer(underwear, 1, underwear_m.len, initial(underwear))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	b_type			= sanitize_text(b_type, initial(b_type))
	//be_special      = sanitize_integer(be_special, 0, 65535, initial(be_special))

	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_civilian_high = sanitize_integer(job_civilian_high, 0, 65535, initial(job_civilian_high))
	job_civilian_med = sanitize_integer(job_civilian_med, 0, 65535, initial(job_civilian_med))
	job_civilian_low = sanitize_integer(job_civilian_low, 0, 65535, initial(job_civilian_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engsec_high = sanitize_integer(job_engsec_high, 0, 65535, initial(job_engsec_high))
	job_engsec_med = sanitize_integer(job_engsec_med, 0, 65535, initial(job_engsec_med))
	job_engsec_low = sanitize_integer(job_engsec_low, 0, 65535, initial(job_engsec_low))

	q = new
	q.Add("SELECT role, preference FROM client_roles WHERE ckey=? AND slot=?", ckey, slot)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			roles[row["role"]] = text2num(row["preference"]) | ROLEPREF_PERSIST
	else
		message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	if(!skills) skills = list()
	if(!used_skillpoints) used_skillpoints= 0
	if(isnull(disabilities)) disabilities = 0
	if(!player_alt_titles) player_alt_titles = new()
	if(!organ_data) src.organ_data = list()

	user << "Sucessfully loaded [real_name]."

	return 1


/datum/preferences/proc/load_save(dir)
	var/savefile/S = new /savefile(path)
	if(!S) return 0
	S.cd = dir

	//Character
	S["OOC_Notes"]			>> metadata
	S["real_name"]			>> real_name
	S["name_is_always_random"] >> be_random_name
	S["gender"]				>> gender
	S["age"]				>> age
	S["species"]			>> species
	S["language"]			>> language

	//colors to be consolidated into hex strings (requires some work with dna code)
	S["hair_red"]			>> r_hair
	S["hair_green"]			>> g_hair
	S["hair_blue"]			>> b_hair
	S["facial_red"]			>> r_facial
	S["facial_green"]		>> g_facial
	S["facial_blue"]		>> b_facial
	S["skin_tone"]			>> s_tone
	S["hair_style_name"]	>> h_style
	S["facial_style_name"]	>> f_style
	S["eyes_red"]			>> r_eyes
	S["eyes_green"]			>> g_eyes
	S["eyes_blue"]			>> b_eyes
	S["underwear"]			>> underwear
	S["backbag"]			>> backbag
	S["b_type"]				>> b_type

	//Jobs
	S["alternate_option"]	>> alternate_option
	S["job_civilian_high"]	>> job_civilian_high
	S["job_civilian_med"]	>> job_civilian_med
	S["job_civilian_low"]	>> job_civilian_low
	S["job_medsci_high"]	>> job_medsci_high
	S["job_medsci_med"]		>> job_medsci_med
	S["job_medsci_low"]		>> job_medsci_low
	S["job_engsec_high"]	>> job_engsec_high
	S["job_engsec_med"]		>> job_engsec_med
	S["job_engsec_low"]		>> job_engsec_low

	//Miscellaneous
	S["flavor_text"]		>> flavor_text
	S["med_record"]			>> med_record
	S["sec_record"]			>> sec_record
	S["gen_record"]			>> gen_record
	//S["be_special"]			>> be_special
	S["disabilities"]		>> disabilities
	S["player_alt_titles"]		>> player_alt_titles
	S["used_skillpoints"]	>> used_skillpoints
	S["skills"]				>> skills
	S["skill_specialization"] >> skill_specialization
	S["organ_data"]			>> organ_data

	S["nanotrasen_relation"] >> nanotrasen_relation
	//S["skin_style"]			>> skin_style

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)
	if(isnull(species)) species = "Human"
	if(isnull(language)) language = "None"
	if(isnull(nanotrasen_relation)) nanotrasen_relation = initial(nanotrasen_relation)
	if(!real_name) real_name = random_name(gender,species)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	h_style			= sanitize_inlist(h_style, hair_styles_list, initial(h_style))
	f_style			= sanitize_inlist(f_style, facial_hair_styles_list, initial(f_style))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	underwear		= sanitize_integer(underwear, 1, underwear_m.len, initial(underwear))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	b_type			= sanitize_text(b_type, initial(b_type))

	alternate_option = sanitize_integer(alternate_option, 0, 2, initial(alternate_option))
	job_civilian_high = sanitize_integer(job_civilian_high, 0, 65535, initial(job_civilian_high))
	job_civilian_med = sanitize_integer(job_civilian_med, 0, 65535, initial(job_civilian_med))
	job_civilian_low = sanitize_integer(job_civilian_low, 0, 65535, initial(job_civilian_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engsec_high = sanitize_integer(job_engsec_high, 0, 65535, initial(job_engsec_high))
	job_engsec_med = sanitize_integer(job_engsec_med, 0, 65535, initial(job_engsec_med))
	job_engsec_low = sanitize_integer(job_engsec_low, 0, 65535, initial(job_engsec_low))

	if(!skills) skills = list()
	if(!used_skillpoints) used_skillpoints= 0
	if(isnull(disabilities)) disabilities = 0
	if(!player_alt_titles) player_alt_titles = new()
	if(!organ_data) src.organ_data = list()
	//if(!skin_style) skin_style = "Default"


/datum/preferences/proc/random_character_sqlite(var/user, var/ckey)
	var/database/query/q = new
	var/list/slot_list = new
	q.Add("SELECT player_slot FROM players WHERE player_ckey=?", ckey)
	if(q.Execute(db))
		while(q.NextRow())
			slot_list.Add(q.GetColumn(1))
	else
		message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0
	var/random_slot = pick(slot_list)
	load_save_sqlite(ckey, user, random_slot)
	return 1

/datum/preferences/proc/random_character()
	if(!path)				return 0
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	var/list/saves = list()
	var/name
	for(var/i=1, i<=MAX_SAVE_SLOTS, i++)
		S.cd = "/character[i]"
		S["real_name"] >> name
		if(!name) continue
		saves.Add(S.cd)

	if(!saves.len)
		load_character()
		return 0
	S.cd = pick(saves)
	load_save(S.cd)
	return 1

/datum/preferences/proc/load_character(slot)
	if(!path)				return 0
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"
	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		S["default_slot"] << slot
	S.cd = "/character[slot]"
	load_save(S.cd)
	return 1

/datum/preferences/proc/save_character_sqlite(var/ckey, var/user, var/slot)

	if(slot > MAX_SAVE_SLOTS)
		user << "You are limited to 8 character slots."
		message_admins("[ckey] attempted to override character slot limit")
		return 0

	var/database/query/q = new
	var/database/query/check = new

	var/altTitles

	for(var/a in player_alt_titles)
		altTitles += "[a]:[player_alt_titles[a]];"

	check.Add("SELECT player_ckey FROM players WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())          //1           2           3         4         5           6      7   8       9        10          11         12         13         14                15           16
			q.Add("INSERT INTO players (player_ckey,player_slot,ooc_notes,real_name,random_name,gender,age,species,language,flavor_text,med_record,sec_record,gen_record,player_alt_titles,disabilities,nanotrasen_relation) \
				   VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
				                        ckey,       slot,       metadata, real_name, be_random_name, gender, age, species, language, flavor_text, med_record, sec_record, gen_record, altTitles, disabilities, nanotrasen_relation)
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Created Character"
		else
			q.Add("UPDATE players SET ooc_notes=?,real_name=?,random_name=?,gender=?,age=?,species=?,language=?,flavor_text=?,med_record=?,sec_record=?,gen_record=?,player_alt_titles=?,disabilities=?,nanotrasen_relation=? WHERE player_ckey = ? AND player_slot = ?",\
									  metadata, real_name, be_random_name, gender, age, species, language, flavor_text, med_record, sec_record, gen_record, altTitles, disabilities, nanotrasen_relation, ckey, slot)
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Updated Character"
	else
		message_admins("Error #:[check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	check.Add("SELECT player_ckey FROM body WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO body (player_ckey,player_slot,hair_red,hair_green,hair_blue,facial_red,facial_green,facial_blue,skin_tone,hair_style_name,facial_style_name,eyes_red,eyes_green,eyes_blue,underwear,backbag,b_type) \
					VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", ckey, slot, r_hair, g_hair, b_hair, r_facial, g_facial, b_facial, s_tone, h_style, f_style, r_eyes, g_eyes, b_eyes, underwear, backbag, b_type)
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Created Body"
		else
			q.Add("UPDATE body SET hair_red=?,hair_green=?,hair_blue=?,facial_red=?,facial_green=?,facial_blue=?,skin_tone=?,hair_style_name=?,facial_style_name=?,eyes_red=?,eyes_green=?,eyes_blue=?,underwear=?,backbag=?,b_type=? WHERE player_ckey = ? AND player_slot = ?",\
									r_hair, g_hair, b_hair, r_facial, g_facial, b_facial, s_tone, h_style, f_style, r_eyes, g_eyes, b_eyes, underwear, backbag, b_type, ckey, slot)
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Updated Body"
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	check.Add("SELECT player_ckey FROM jobs WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO jobs (player_ckey,player_slot,alternate_option,job_civilian_high,job_civilian_med,job_civilian_low,job_medsci_high,job_medsci_med,job_medsci_low,job_engsec_high,job_engsec_med,job_engsec_low) \
					VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", ckey, slot, alternate_option, job_civilian_high, job_civilian_med, job_civilian_low, job_medsci_high, job_medsci_med, job_medsci_low, job_engsec_high, job_engsec_med, job_engsec_low)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Created Job list"
		else
			q.Add("UPDATE jobs SET alternate_option=?,job_civilian_high=?,job_civilian_med=?,job_civilian_low=?,job_medsci_high=?,job_medsci_med=?,job_medsci_low=?,job_engsec_high=?,job_engsec_med=?,job_engsec_low=? WHERE player_ckey = ? AND player_slot = ?",\
									alternate_option, job_civilian_high, job_civilian_med, job_civilian_low, job_medsci_high, job_medsci_med, job_medsci_low, job_engsec_high, job_engsec_med, job_engsec_low, ckey, slot)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Updated Job List"
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	check.Add("SELECT player_ckey FROM limbs WHERE player_ckey = ? AND player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO limbs (player_ckey, player_slot) VALUES (?,?)", ckey, slot)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				warning("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			for(var/stuff in organ_data)
				q.Add("UPDATE limbs SET [stuff]=? WHERE player_ckey = ? AND player_slot = ?", organ_data[stuff], ckey, slot)
				if(!q.Execute(db))
					message_admins("Error #; [q.Error()] - [q.ErrorMsg()]")
					warning("Error #:[q.Error()] - [q.ErrorMsg()]")
					return 0
			user << "Created Limbs"
		else
			for(var/stuff in organ_data)
				q.Add("UPDATE limbs SET [stuff] = ? WHERE player_ckey = ? AND player_slot = ?", organ_data[stuff], ckey, slot)
				if(!q.Execute(db))
					message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
					warning("Error #:[q.Error()] - [q.ErrorMsg()]")
					return 0
			user << "Updated Limbs"
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	check.Add("DELETE FROM client_roles WHERE ckey=? AND slot=?", ckey, slot)
	if(!check.Execute(db))
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		warning("Error #:[q.Error()] - [q.ErrorMsg()]")
		return 0

	for(var/role_id in roles)
		if(!(roles[role_id] & ROLEPREF_PERSIST))
			continue
		q = new
		q.Add("INSERT INTO client_roles (ckey, slot, role, preference) VALUES (?,?,?,?)", ckey, slot, role_id, (roles[role_id] & ~ROLEPREF_PERSIST))
		if(!q.Execute(db))
			message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
			warning("Error #:[q.Error()] - [q.ErrorMsg()]")
			return 0

	return 1


/datum/preferences/proc/save_character()

	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/character[default_slot]"

	//Character + misc
	S["OOC_Notes"]			<< metadata
	S["real_name"]			<< real_name
	S["name_is_always_random"] << be_random_name
	S["gender"]				<< gender
	S["age"]				<< age
	S["species"]			<< species
	S["language"]			<< language
	S["flavor_text"]		<< flavor_text
	S["med_record"]			<< med_record
	S["sec_record"]			<< sec_record
	S["gen_record"]			<< gen_record
	S["player_alt_titles"]	<< player_alt_titles
	//S["be_special"]			<< be_special
	S["disabilities"]		<< disabilities
	S["used_skillpoints"]	<< used_skillpoints
	S["skills"]				<< skills
	S["skill_specialization"] << skill_specialization
	S["organ_data"]			<< organ_data
	S["nanotrasen_relation"] << nanotrasen_relation
	//Body
	S["hair_red"]			<< r_hair
	S["hair_green"]			<< g_hair
	S["hair_blue"]			<< b_hair
	S["facial_red"]			<< r_facial
	S["facial_green"]		<< g_facial
	S["facial_blue"]		<< b_facial
	S["skin_tone"]			<< s_tone
	S["hair_style_name"]	<< h_style
	S["facial_style_name"]	<< f_style
	S["eyes_red"]			<< r_eyes
	S["eyes_green"]			<< g_eyes
	S["eyes_blue"]			<< b_eyes
	S["underwear"]			<< underwear
	S["backbag"]			<< backbag
	S["b_type"]				<< b_type

	//Jobs
	S["alternate_option"]	<< alternate_option
	S["job_civilian_high"]	<< job_civilian_high
	S["job_civilian_med"]	<< job_civilian_med
	S["job_civilian_low"]	<< job_civilian_low
	S["job_medsci_high"]	<< job_medsci_high
	S["job_medsci_med"]		<< job_medsci_med
	S["job_medsci_low"]		<< job_medsci_low
	S["job_engsec_high"]	<< job_engsec_high
	S["job_engsec_med"]		<< job_engsec_med
	S["job_engsec_low"]		<< job_engsec_low
	//S["skin_style"]			<< skin_style

	return 1


#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
