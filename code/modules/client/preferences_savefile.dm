//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	15

//This is the current version, anything below this will attempt to update (if it's not obsolete)
#define SAVEFILE_VERSION_MAX	18
/*
SAVEFILE UPDATING/VERSIONING - 'Simplified', or rather, more coder-friendly ~Carn
	This proc checks if the current directory of the savefile S needs updating
	It is to be used by the load_character and load_preferences procs.
	(S.cd=="/" is preferences, S.cd=="/character[integer]" is a character slot, etc)

	if the current directory's version is below SAVEFILE_VERSION_MIN it will simply wipe everything in that directory
	(if we're at root "/" then it'll just wipe the entire savefile, for instance.)

	if its version is below SAVEFILE_VERSION_MAX but above the minimum, it will load data but later call the
	respective update_preferences() or update_character() proc.
	Those procs allow coders to specify format changes so users do not lose their setups and have to redo them again.

	Failing all that, the standard sanity checks are performed. They simply check the data is suitable, reverting to
	initial() values if necessary.
*/
/datum/preferences/proc/savefile_needs_update(savefile/S)
	var/savefile_version
	S["version"] >> savefile_version

	if(savefile_version < SAVEFILE_VERSION_MIN)
		S.dir.Cut()
		return -2
	if(savefile_version < SAVEFILE_VERSION_MAX)
		return savefile_version
	return -1


/datum/preferences/proc/update_antagchoices(current_version, savefile/S)
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
		var/B_abductor = 16384

		var/list/archived = list(B_traitor,B_operative,B_changeling,B_wizard,B_malf,B_rev,B_alien,B_pai,B_cultist,B_blob,B_ninja,B_monkey,B_gang,B_abductor)

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
					if(4096)
						be_special += ROLE_GANG
					if(16384)
						be_special += ROLE_ABDUCTOR


/datum/preferences/proc/update_preferences(current_version, savefile/S)


//should this proc get fairly long (say 3 versions long),
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from this proc.
//It's only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.
/datum/preferences/proc/update_character(current_version, savefile/S)
	if(current_version < 16)
		var/berandom
		S["userandomjob"] >> berandom
		if (berandom)
			joblessrole = BERANDOMJOB
		else
			joblessrole = BEASSISTANT
	if(current_version < 17)
		features["legs"] = "Normal Legs"



/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)
		return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"

/datum/preferences/proc/load_preferences()
	if(!path)
		return 0
	if(!fexists(path))
		return 0

	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//general preferences
	S["ooccolor"]			>> ooccolor
	S["lastchangelog"]		>> lastchangelog
	S["UI_style"]			>> UI_style
	S["hotkeys"]			>> hotkeys
	S["tgui_fancy"]			>> tgui_fancy
	S["tgui_lock"]			>> tgui_lock
	S["windowflash"]		>> windowflashing
	S["be_special"] 		>> be_special


	S["default_slot"]		>> default_slot
	S["chat_toggles"]		>> chat_toggles
	S["toggles"]			>> toggles
	S["ghost_form"]			>> ghost_form
	S["ghost_orbit"]		>> ghost_orbit
	S["ghost_accs"]			>> ghost_accs
	S["ghost_others"]		>> ghost_others
	S["preferred_map"]		>> preferred_map
	S["ignoring"]			>> ignoring
	S["ghost_hud"]			>> ghost_hud
	S["inquisitive_ghost"]	>> inquisitive_ghost
	S["uses_glasses_colour"]>> uses_glasses_colour
	S["clientfps"]			>> clientfps
	S["parallax"]			>> parallax
	S["menuoptions"]		>> menuoptions
	S["enable_tips"]		>> enable_tips
	S["tip_delay"]			>> tip_delay

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update, S)		//needs_update = savefile_version if we need an update (positive integer)
		update_antagchoices(needs_update, S)

	//Sanitize
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, 1, initial(ooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, list("Midnight", "Plasmafire", "Retro", "Slimecore", "Operative", "Clockwork"), initial(UI_style))
	hotkeys			= sanitize_integer(hotkeys, 0, 1, initial(hotkeys))
	tgui_fancy		= sanitize_integer(tgui_fancy, 0, 1, initial(tgui_fancy))
	tgui_lock		= sanitize_integer(tgui_lock, 0, 1, initial(tgui_lock))
	windowflashing		= sanitize_integer(windowflashing, 0, 1, initial(windowflashing))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	clientfps		= sanitize_integer(clientfps, 0, 1000, 0)
	parallax		= sanitize_integer(parallax, PARALLAX_INSANE, PARALLAX_DISABLE, null)
	ghost_form		= sanitize_inlist(ghost_form, GLOB.ghost_forms, initial(ghost_form))
	ghost_orbit 	= sanitize_inlist(ghost_orbit, GLOB.ghost_orbits, initial(ghost_orbit))
	ghost_accs		= sanitize_inlist(ghost_accs, GLOB.ghost_accs_options, GHOST_ACCS_DEFAULT_OPTION)
	ghost_others	= sanitize_inlist(ghost_others, GLOB.ghost_others_options, GHOST_OTHERS_DEFAULT_OPTION)
	menuoptions		= SANITIZE_LIST(menuoptions)
	be_special		= SANITIZE_LIST(be_special)


	return 1

/datum/preferences/proc/save_preferences()
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"

	S["version"] << SAVEFILE_VERSION_MAX		//updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	//general preferences
	S["ooccolor"]			<< ooccolor
	S["lastchangelog"]		<< lastchangelog
	S["UI_style"]			<< UI_style
	S["hotkeys"]			<< hotkeys
	S["tgui_fancy"]			<< tgui_fancy
	S["tgui_lock"]			<< tgui_lock
	S["windowflash"]		<< windowflashing
	S["be_special"]			<< be_special
	S["default_slot"]		<< default_slot
	S["toggles"]			<< toggles
	S["chat_toggles"]		<< chat_toggles
	S["ghost_form"]			<< ghost_form
	S["ghost_orbit"]		<< ghost_orbit
	S["ghost_accs"]			<< ghost_accs
	S["ghost_others"]		<< ghost_others
	S["preferred_map"]		<< preferred_map
	S["ignoring"]			<< ignoring
	S["ghost_hud"]			<< ghost_hud
	S["inquisitive_ghost"]	<< inquisitive_ghost
	S["uses_glasses_colour"]<< uses_glasses_colour
	S["clientfps"]			<< clientfps
	S["parallax"]			<< parallax
	S["menuoptions"]		<< menuoptions
	S["enable_tips"]		<< enable_tips
	S["tip_delay"]			<< tip_delay

	return 1

/datum/preferences/proc/load_character(slot)
	if(!path)
		return 0
	if(!fexists(path))
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/"
	if(!slot)
		slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		S["default_slot"] << slot

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//Species
	var/species_id
	S["species"]			>> species_id
	if(config.mutant_races && species_id && (species_id in GLOB.roundstart_species))
		var/newtype = GLOB.roundstart_species[species_id]
		pref_species = new newtype()
	else if (config.roundstart_races.len)
		var/rando_race = pick(config.roundstart_races)
		if (rando_race)
			pref_species = new rando_race()

	if(!S["features["mcolor"]"] || S["features["mcolor"]"] == "#000")
		S["features["mcolor"]"]	<< "#FFF"

	//Character
	S["OOC_Notes"]			>> metadata
	S["real_name"]			>> real_name
	S["name_is_always_random"] >> be_random_name
	S["body_is_always_random"] >> be_random_body
	S["gender"]				>> gender
	S["age"]				>> age
	S["hair_color"]			>> hair_color
	S["facial_hair_color"]	>> facial_hair_color
	S["eye_color"]			>> eye_color
	S["skin_tone"]			>> skin_tone
	S["hair_style_name"]	>> hair_style
	S["facial_style_name"]	>> facial_hair_style
	S["underwear"]			>> underwear
	S["undershirt"]			>> undershirt
	S["socks"]				>> socks
	S["backbag"]			>> backbag
	S["uplink_loc"]			>> uplink_spawn_loc
	S["feature_mcolor"]					>> features["mcolor"]
	S["feature_lizard_tail"]			>> features["tail_lizard"]
	S["feature_lizard_snout"]			>> features["snout"]
	S["feature_lizard_horns"]			>> features["horns"]
	S["feature_lizard_frills"]			>> features["frills"]
	S["feature_lizard_spines"]			>> features["spines"]
	S["feature_lizard_body_markings"]	>> features["body_markings"]
	S["feature_lizard_legs"]			>> features["legs"]
	if(!config.mutant_humans)
		features["tail_human"] = "none"
		features["ears"] = "none"
	else
		S["feature_human_tail"]				>> features["tail_human"]
		S["feature_human_ears"]				>> features["ears"]
	S["clown_name"]			>> custom_names["clown"]
	S["mime_name"]			>> custom_names["mime"]
	S["ai_name"]			>> custom_names["ai"]
	S["cyborg_name"]		>> custom_names["cyborg"]
	S["religion_name"]		>> custom_names["religion"]
	S["deity_name"]			>> custom_names["deity"]
	S["prefered_security_department"] >> prefered_security_department

	//Jobs
	S["joblessrole"]		>> joblessrole
	S["job_civilian_high"]	>> job_civilian_high
	S["job_civilian_med"]	>> job_civilian_med
	S["job_civilian_low"]	>> job_civilian_low
	S["job_medsci_high"]	>> job_medsci_high
	S["job_medsci_med"]		>> job_medsci_med
	S["job_medsci_low"]		>> job_medsci_low
	S["job_engsec_high"]	>> job_engsec_high
	S["job_engsec_med"]		>> job_engsec_med
	S["job_engsec_low"]		>> job_engsec_low

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_character(needs_update, S)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)
	if(!features["mcolor"] || features["mcolor"] == "#000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	if(!real_name)
		real_name = random_unique_name(gender)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))
	gender			= sanitize_gender(gender)
	if(gender == MALE)
		hair_style			= sanitize_inlist(hair_style, GLOB.hair_styles_male_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_male_list)
		underwear		= sanitize_inlist(underwear, GLOB.underwear_m)
		undershirt 		= sanitize_inlist(undershirt, GLOB.undershirt_m)
	else
		hair_style			= sanitize_inlist(hair_style, GLOB.hair_styles_female_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, GLOB.facial_hair_styles_female_list)
		underwear		= sanitize_inlist(underwear, GLOB.underwear_f)
		undershirt		= sanitize_inlist(undershirt, GLOB.undershirt_f)
	socks			= sanitize_inlist(socks, GLOB.socks_list)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color			= sanitize_hexcolor(hair_color, 3, 0)
	facial_hair_color			= sanitize_hexcolor(facial_hair_color, 3, 0)
	eye_color		= sanitize_hexcolor(eye_color, 3, 0)
	skin_tone		= sanitize_inlist(skin_tone, GLOB.skin_tones)
	backbag			= sanitize_inlist(backbag, GLOB.backbaglist, initial(backbag))
	uplink_spawn_loc = sanitize_inlist(uplink_spawn_loc, GLOB.uplink_spawn_loc_list, initial(uplink_spawn_loc))
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], 3, 0)
	features["tail_lizard"]	= sanitize_inlist(features["tail_lizard"], GLOB.tails_list_lizard)
	features["tail_human"] 	= sanitize_inlist(features["tail_human"], GLOB.tails_list_human, "None")
	features["snout"]	= sanitize_inlist(features["snout"], GLOB.snouts_list)
	features["horns"] 	= sanitize_inlist(features["horns"], GLOB.horns_list)
	features["ears"]	= sanitize_inlist(features["ears"], GLOB.ears_list, "None")
	features["frills"] 	= sanitize_inlist(features["frills"], GLOB.frills_list)
	features["spines"] 	= sanitize_inlist(features["spines"], GLOB.spines_list)
	features["body_markings"] 	= sanitize_inlist(features["body_markings"], GLOB.body_markings_list)
	features["feature_lizard_legs"]	= sanitize_inlist(features["legs"], GLOB.legs_list, "Normal Legs")

	joblessrole	= sanitize_integer(joblessrole, 1, 3, initial(joblessrole))
	job_civilian_high = sanitize_integer(job_civilian_high, 0, 65535, initial(job_civilian_high))
	job_civilian_med = sanitize_integer(job_civilian_med, 0, 65535, initial(job_civilian_med))
	job_civilian_low = sanitize_integer(job_civilian_low, 0, 65535, initial(job_civilian_low))
	job_medsci_high = sanitize_integer(job_medsci_high, 0, 65535, initial(job_medsci_high))
	job_medsci_med = sanitize_integer(job_medsci_med, 0, 65535, initial(job_medsci_med))
	job_medsci_low = sanitize_integer(job_medsci_low, 0, 65535, initial(job_medsci_low))
	job_engsec_high = sanitize_integer(job_engsec_high, 0, 65535, initial(job_engsec_high))
	job_engsec_med = sanitize_integer(job_engsec_med, 0, 65535, initial(job_engsec_med))
	job_engsec_low = sanitize_integer(job_engsec_low, 0, 65535, initial(job_engsec_low))

	return 1

/datum/preferences/proc/save_character()
	if(!path)
		return 0
	var/savefile/S = new /savefile(path)
	if(!S)
		return 0
	S.cd = "/character[default_slot]"

	S["version"]			<< SAVEFILE_VERSION_MAX	//load_character will sanitize any bad data, so assume up-to-date.

	//Character
	S["OOC_Notes"]			<< metadata
	S["real_name"]			<< real_name
	S["name_is_always_random"] << be_random_name
	S["body_is_always_random"] << be_random_body
	S["gender"]				<< gender
	S["age"]				<< age
	S["hair_color"]			<< hair_color
	S["facial_hair_color"]	<< facial_hair_color
	S["eye_color"]			<< eye_color
	S["skin_tone"]			<< skin_tone
	S["hair_style_name"]	<< hair_style
	S["facial_style_name"]	<< facial_hair_style
	S["underwear"]			<< underwear
	S["undershirt"]			<< undershirt
	S["socks"]				<< socks
	S["backbag"]			<< backbag
	S["uplink_loc"]			<< uplink_spawn_loc
	S["species"]			<< pref_species.id
	S["feature_mcolor"]					<< features["mcolor"]
	S["feature_lizard_tail"]			<< features["tail_lizard"]
	S["feature_human_tail"]				<< features["tail_human"]
	S["feature_lizard_snout"]			<< features["snout"]
	S["feature_lizard_horns"]			<< features["horns"]
	S["feature_human_ears"]				<< features["ears"]
	S["feature_lizard_frills"]			<< features["frills"]
	S["feature_lizard_spines"]			<< features["spines"]
	S["feature_lizard_body_markings"]	<< features["body_markings"]
	S["feature_lizard_legs"]			<< features["legs"]
	S["clown_name"]			<< custom_names["clown"]
	S["mime_name"]			<< custom_names["mime"]
	S["ai_name"]			<< custom_names["ai"]
	S["cyborg_name"]		<< custom_names["cyborg"]
	S["religion_name"]		<< custom_names["religion"]
	S["deity_name"]			<< custom_names["deity"]
	S["prefered_security_department"] << prefered_security_department

	//Jobs
	S["joblessrole"]		<< joblessrole
	S["job_civilian_high"]	<< job_civilian_high
	S["job_civilian_med"]	<< job_civilian_med
	S["job_civilian_low"]	<< job_civilian_low
	S["job_medsci_high"]	<< job_medsci_high
	S["job_medsci_med"]		<< job_medsci_med
	S["job_medsci_low"]		<< job_medsci_low
	S["job_engsec_high"]	<< job_engsec_high
	S["job_engsec_med"]		<< job_engsec_med
	S["job_engsec_low"]		<< job_engsec_low

	return 1


#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN

#ifdef TESTING
//DEBUG
//Some crude tools for testing savefiles
//path is the savefile path
/client/verb/savefile_export(path as text)
	var/savefile/S = new /savefile(path)
	S.ExportText("/",file("[path].txt"))
//path is the savefile path
/client/verb/savefile_import(path as text)
	var/savefile/S = new /savefile(path)
	S.ImportText("/",file("[path].txt"))

#endif