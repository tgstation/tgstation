//This is the lowest supported version, anything below this is completely obsolete and the entire savefile will be wiped.
#define SAVEFILE_VERSION_MIN	8

//This is the current version, anything below this will attempt to update (if it's not obsolete)
#define SAVEFILE_VERSION_MAX	9
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
	return

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
	
	/*
	if(current_version < 10)	//would be the step to upgrade 9 to 10
		//do stuff
	if(current_version < 11)	//and so on...
		//more stuff
	*/

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
	S["toggles"]			>> toggles

	//try to fix any outdated data if necessary
	if(needs_update >= 0)
		update_preferences(needs_update)		//needs_update = savefile_version if we need an update (positive integer)
	
	//Sanitize
	ooccolor		= sanitize_hexcolor(ooccolor, initial(ooccolor))
	lastchangelog	= sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= sanitize_inlist(UI_style, list("Midnight", "Plasmafire", "Retro"), initial(UI_style))
	be_special		= sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))

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
	var/needs_update = savefile_needs_update(S)
	if(needs_update == -2)		//fatal, can't load any data
		return 0

	//Character
	S["OOC_Notes"]			>> metadata
	S["real_name"]			>> real_name
	S["name_is_always_random"] >> be_random_name
	S["gender"]				>> gender
	S["age"]				>> age
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
	if(!real_name)	real_name = random_name(gender)
	be_random_name	= sanitize_integer(be_random_name, 0, 1, initial(be_random_name))
	gender			= sanitize_gender(gender)
	if(gender == MALE)
		h_style			= sanitize_inlist(h_style, hair_styles_male_list)
		f_style			= sanitize_inlist(f_style, facial_hair_styles_male_list)
		underwear		= sanitize_inlist(underwear, underwear_m)
	else
		h_style			= sanitize_inlist(h_style, hair_styles_female_list)
		f_style			= sanitize_inlist(f_style, facial_hair_styles_female_list)
		underwear		= sanitize_inlist(underwear, underwear_f)
	age				= sanitize_integer(age, AGE_MIN, AGE_MAX, initial(age))
	r_hair			= sanitize_integer(r_hair, 0, 255, initial(r_hair))
	g_hair			= sanitize_integer(g_hair, 0, 255, initial(g_hair))
	b_hair			= sanitize_integer(b_hair, 0, 255, initial(b_hair))
	r_facial		= sanitize_integer(r_facial, 0, 255, initial(r_facial))
	g_facial		= sanitize_integer(g_facial, 0, 255, initial(g_facial))
	b_facial		= sanitize_integer(b_facial, 0, 255, initial(b_facial))
	s_tone			= sanitize_integer(s_tone, -185, 34, initial(s_tone))
	r_eyes			= sanitize_integer(r_eyes, 0, 255, initial(r_eyes))
	g_eyes			= sanitize_integer(g_eyes, 0, 255, initial(g_eyes))
	b_eyes			= sanitize_integer(b_eyes, 0, 255, initial(b_eyes))
	backbag			= sanitize_integer(backbag, 1, backbaglist.len, initial(backbag))

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
	S["gender"]				<< gender
	S["age"]				<< age
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