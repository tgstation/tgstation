//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	8

//This is the current version, anything below this will attempt to update (if it's not obsolete)
#define SAVEFILE_VERSION_MAX	11
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

/datum/preferences/proc/update_preferences(current_version)
	if(current_version < 10)
		toggles |= MEMBER_PUBLIC
	if(current_version < 11)
		chat_toggles = TOGGLES_DEFAULT_CHAT
		toggles = TOGGLES_DEFAULT

//should this proc get fairly long (say 3 versions long),
//just increase SAVEFILE_VERSION_MIN so it's not as far behind
//SAVEFILE_VERSION_MAX and then delete any obsolete if clauses
//from this proc.
//It's only really meant to avoid annoying frequent players
//if your savefile is 3 months out of date, then 'tough shit'.
/datum/preferences/proc/update_character(current_version)
	if(current_version < 9)		//an example, underwear were an index for a hardcoded list, converting to a string
		if(gender == MALE)
			switch(underwear)
				if(1)	underwear = "Mens White"
				if(2)	underwear = "Mens Grey"
				if(3)	underwear = "Mens Green"
				if(4)	underwear = "Mens Blue"
				if(5)	underwear = "Mens Black"
				if(6)	underwear = "Mankini"
				if(7)	underwear = "Mens Hearts Boxer"
				if(8)	underwear = "Mens Black Boxer"
				if(9)	underwear = "Mens Grey Boxer"
				if(10)	underwear = "Mens Striped Boxer"
				if(11)	underwear = "Mens Kinky"
				if(12)	underwear = "Mens Red"
				if(13)	underwear = "Nude"
		else
			switch(underwear)
				if(1)	underwear = "Ladies Red"
				if(2)	underwear = "Ladies White"
				if(3)	underwear = "Ladies Yellow"
				if(4)	underwear = "Ladies Blue"
				if(5)	underwear = "Ladies Black"
				if(6)	underwear = "Ladies Thong"
				if(7)	underwear = "Babydoll"
				if(8)	underwear = "Ladies Baby-Blue"
				if(9)	underwear = "Ladies Green"
				if(10)	underwear = "Ladies Pink"
				if(11)	underwear = "Ladies Kinky"
				if(12)	underwear = "Tankini"
				if(13)	underwear = "Nude"
		if(!(pref_species in species_list))
			pref_species = new /datum/species/human()
	return

/datum/preferences/proc/load_path(ckey,filename="preferences.sav")
	if(!ckey)	return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/[filename]"

/datum/preferences/proc/load_preferences()
	if(!path)				return 0
	if(!fexists(path))		return 0

	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//general preferences
	S["ooccolor"]			>> ooccolor
	S["lastchangelog"]		>> lastchangelog
	S["UI_style"]			>> UI_style
	S["be_special"]			>> be_special
	S["default_slot"]		>> default_slot
	S["chat_toggles"]		>> chat_toggles
	S["toggles"]			>> toggles
	S["ghost_form"]			>> ghost_form

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update)		//needs_update = savefile_version if we need an update (positive integer)

	//Sanitize
	ooccolor		= sanitize_ooccolor(sanitize_hexcolor(ooccolor, 6, 1, initial(ooccolor)))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, list("Midnight", "Plasmafire", "Retro"), initial(UI_style))
	be_special		= sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= sanitize_integer(default_slot, 1, max_save_slots, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	ghost_form		= sanitize_inlist(ghost_form, ghost_forms, initial(ghost_form))

	return 1

/datum/preferences/proc/save_preferences()
	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"

	S["version"] << SAVEFILE_VERSION_MAX		//updates (or failing that the sanity checks) will ensure data is not invalid at load. Assume up-to-date

	//general preferences
	S["ooccolor"]			<< ooccolor
	S["lastchangelog"]		<< lastchangelog
	S["UI_style"]			<< UI_style
	S["be_special"]			<< be_special
	S["default_slot"]		<< default_slot
	S["toggles"]			<< toggles
	S["chat_toggles"]		<< chat_toggles
	S["ghost_form"]			<< ghost_form

	return 1

/datum/preferences/proc/load_character(slot)
	if(!path)				return 0
	if(!fexists(path))		return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
	S.cd = "/"
	if(!slot)	slot = default_slot
	slot = sanitize_integer(slot, 1, max_save_slots, initial(default_slot))
	if(slot != default_slot)
		default_slot = slot
		S["default_slot"] << slot

	S.cd = "/character[slot]"
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//Species
	var/species_name
	S["species"]			>> species_name
	if(config.mutant_races && species_name && (species_name in roundstart_species))
		var/newtype = roundstart_species[species_name]
		pref_species = new newtype()
	else
		pref_species = new /datum/species/human()

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
	S["feature_mcolor"]					>> features["mcolor"]
	S["feature_lizard_tail"]			>> features["tail_lizard"]
	S["feature_human_tail"]				>> features["tail_human"]
	S["feature_lizard_snout"]			>> features["snout"]
	S["feature_lizard_horns"]			>> features["horns"]
	S["feature_human_ears"]				>> features["ears"]
	S["feature_lizard_frills"]			>> features["frills"]
	S["feature_lizard_spines"]			>> features["spines"]
	S["feature_lizard_body_markings"]	>> features["body_markings"]
	S["clown_name"]			>> custom_names["clown"]
	S["mime_name"]			>> custom_names["mime"]
	S["ai_name"]			>> custom_names["ai"]
	S["cyborg_name"]		>> custom_names["cyborg"]
	S["religion_name"]		>> custom_names["religion"]
	S["deity_name"]			>> custom_names["deity"]

	//Jobs
	S["userandomjob"]		>> userandomjob
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
		update_character(needs_update)		//needs_update == savefile_version if we need an update (positive integer)

	//Sanitize
	metadata		= sanitize_text(metadata, initial(metadata))
	real_name		= reject_bad_name(real_name)
	if(!features["mcolor"] || features["mcolor"] == "#000")
		features["mcolor"] = pick("FFFFFF","7F7F7F", "7FFF7F", "7F7FFF", "FF7F7F", "7FFFFF", "FF7FFF", "FFFF7F")
	if(!real_name)	real_name = random_unique_name(gender)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	be_random_body	= sanitize_integer(be_random_body, 0, 1, initial(be_random_body))
	gender			= sanitize_gender(gender)
	if(gender == MALE)
		hair_style			= sanitize_inlist(hair_style, hair_styles_male_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, facial_hair_styles_male_list)
		underwear		= sanitize_inlist(underwear, underwear_m)
		undershirt 		= sanitize_inlist(undershirt, undershirt_m)
		socks			= sanitize_inlist(socks, socks_m)
	else
		hair_style			= sanitize_inlist(hair_style, hair_styles_female_list)
		facial_hair_style			= sanitize_inlist(facial_hair_style, facial_hair_styles_female_list)
		underwear		= sanitize_inlist(underwear, underwear_f)
		undershirt		= sanitize_inlist(undershirt, undershirt_f)
		socks			= sanitize_inlist(socks, socks_f)

	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	hair_color			= sanitize_hexcolor(hair_color, 3, 0)
	facial_hair_color			= sanitize_hexcolor(facial_hair_color, 3, 0)
	eye_color		= sanitize_hexcolor(eye_color, 3, 0)
	skin_tone		= sanitize_inlist(skin_tone, skin_tones)
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))
	features["mcolor"]	= sanitize_hexcolor(features["mcolor"], 3, 0)
	features["tail_lizard"]	= sanitize_inlist(features["tail_lizard"], tails_list_lizard)
	features["tail_human"] 	= sanitize_inlist(features["tail_human"], tails_list_human, "None")
	features["snout"]	= sanitize_inlist(features["snout"], snouts_list)
	features["horns"] 	= sanitize_inlist(features["horns"], horns_list)
	features["ears"]	= sanitize_inlist(features["ears"], ears_list, "None")
	features["frills"] 	= sanitize_inlist(features["frills"], frills_list)
	features["spines"] 	= sanitize_inlist(features["spines"], spines_list)
	features["body_markings"] 	= sanitize_inlist(features["body_markings"], body_markings_list)

	userandomjob	= sanitize_integer(userandomjob, 0, 1, initial(userandomjob))
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
	if(!path)				return 0
	var/savefile/S = new /savefile(path)
	if(!S)					return 0
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
	S["species"]			<< pref_species.name
	S["feature_mcolor"]					<< features["mcolor"]
	S["feature_lizard_tail"]			<< features["tail_lizard"]
	S["feature_human_tail"]				<< features["tail_human"]
	S["feature_lizard_snout"]			<< features["snout"]
	S["feature_lizard_horns"]			<< features["horns"]
	S["feature_human_ears"]				<< features["ears"]
	S["feature_lizard_frills"]			<< features["frills"]
	S["feature_lizard_spines"]			<< features["spines"]
	S["feature_lizard_body_markings"]	<< features["body_markings"]
	S["clown_name"]			<< custom_names["clown"]
	S["mime_name"]			<< custom_names["mime"]
	S["ai_name"]			<< custom_names["ai"]
	S["cyborg_name"]		<< custom_names["cyborg"]
	S["religion_name"]		<< custom_names["religion"]
	S["deity_name"]			<< custom_names["deity"]

	//Jobs
	S["userandomjob"]		<< userandomjob
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
/*
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
*/
