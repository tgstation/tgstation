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
	check.Add("select ckey from client")
	if(check.Execute(db))
		if(!check.NextRow())
			if(!save_preferences_sqlite(ckey))
				world << " An error has occured."
				return 0
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		return 0
	q.Add("SELECT * FROM client where ckey = ?", ckey)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			for(var/a in row)
				//world << "[a] = [row[a]]"
				preference_list_client[a] = row[a]
	else
		message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
		return 0

	ooccolor 		=	preference_list_client["ooc_color"]
	lastchangelog 	= 	preference_list_client["lastchangelog"]
	UI_style 		=	preference_list_client["UI_style"]
	default_slot 	=	preference_list_client["default_slot"]
	toggles 		=	preference_list_client["toggles"]
	UI_style_color	= 	preference_list_client["UI_style_color"]
	UI_style_alpha 	= 	preference_list_client["UI_style_alpha"]
	warns			=	preference_list_client["warns"]
	warnbans		=	preference_list_client["warnsbans"]
	volume			=	preference_list_client["volume"]
	special_popup	=	preference_list_client["special"]
	randomslot		=	preference_list_client["randomslot"]

	ooccolor		= 	sanitize_hexcolor(ooccolor, initial(ooccolor))
	lastchangelog	= 	sanitize_text(lastchangelog, initial(lastchangelog))
	UI_style		= 	sanitize_inlist(UI_style, list("White", "Midnight","Orange","old"), initial(UI_style))
	be_special		= 	sanitize_integer(be_special, 0, 65535, initial(be_special))
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
	S["be_special"]			>> be_special
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
	be_special		= sanitize_integer(be_special, 0, 65535, initial(be_special))
	default_slot	= sanitize_integer(default_slot, 1, MAX_SAVE_SLOTS, initial(default_slot))
	toggles			= sanitize_integer(toggles, 0, 65535, initial(toggles))
	UI_style_color	= sanitize_hexcolor(UI_style_color, initial(UI_style_color))
	UI_style_alpha	= sanitize_integer(UI_style_alpha, 0, 255, initial(UI_style_alpha))
	randomslot		= sanitize_integer(randomslot, 0, 1, initial(randomslot))
	volume			= sanitize_integer(volume, 0, 100, initial(volume))
	special_popup	= sanitize_integer(special_popup, 0, 1, initial(special_popup))
	return 1


/datum/preferences/proc/save_preferences_sqlite(var/user, var/ckey)
	var/database/query/check = new
	var/database/query/q = new
	check.Add("select ckey from client")
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT into client (ckey, ooc_color, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, special) VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?)",\
			ckey, ooccolor, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, special_popup)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				return 0
		else
			q.Add("UPDATE client SET ooc_color=?,lastchangelog=?,UI_style=?,default_slot=?,toggles=?,UI_style_color=?,UI_style_alpha=?,warns=?,warnbans=?,randomslot=?,volume=?,special=? WHERE ckey = ?",\
			ooccolor, lastchangelog, UI_style, default_slot, toggles, UI_style_color, UI_style_alpha, warns, warnbans, randomslot, volume, special_popup, ckey)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				return 0
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		return 0
	user << "Preferences Updated."
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
	S["be_special"]			<< be_special
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
	var/database/query/q = new
	var/database/query/check = new

	check.Add("select ckey from players where ckey = ? and slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			user << "You have no character file to load, please save one first."
			return 0
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		return 0

	q.Add("select * from players, body, limbs, jobs WHERE players.ckey = ? AND players.slot = ?", ckey, slot)
	if(q.Execute(db))
		while(q.NextRow())
			var/list/row = q.GetRowData()
			for(var/a in row)
				//world << "[a] = [row[a]]"
				preference_list[a] = row[a]
	else
		message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
		return 0

	metadata = preference_list["ooc_notes"]
	real_name = preference_list["real_name"]
	be_random_name = preference_list["random_name"]
	gender = preference_list["gender"]
	age = preference_list["age"]
	species = preference_list["species"]
	language = preference_list["language"]
	flavor_text = preference_list["flavor_text"]
	med_record = preference_list["med_record"]
	sec_record = preference_list["sec_record"]
	gen_record = preference_list["gen_record"]
	player_alt_titles = preference_list["player_alt_titles"]
	be_special = preference_list["be_special"]
	disabilities = preference_list["disabilities"]
	nanotrasen_relation = preference_list["nanotrasen_relation"]

	r_hair = preference_list["hair_red"]
	g_hair = preference_list["hair_green"]
	b_hair = preference_list["hair_blue"]
	r_facial = preference_list["facial_red"]
	g_facial = preference_list["facial_green"]
	b_facial = preference_list["facial_blue"]
	underwear = preference_list["underwear"]
	backbag = preference_list["backbag"]
	b_type = preference_list["b_type"]

	organ_data["l_arm"] = preference_list["l_arm"]
	organ_data["r_arm"] = preference_list["r_arm"]
	organ_data["l_leg"] = preference_list["l_leg"]
	organ_data["r_leg"] = preference_list["r_leg"]
	organ_data["l_foot"] = preference_list["l_foot"]
	organ_data["r_foot"] = preference_list["r_foot"]
	organ_data["l_hand"] = preference_list["l_hand"]
	organ_data["r_hand"] = preference_list["r_hand"]
	organ_data["heart"] = preference_list["heart"]
	organ_data["eyes"] = preference_list["eyes"]

	alternate_option = preference_list["alternate_option"]
	job_civilian_high = preference_list["job_civilian_high"]
	job_civilian_med = preference_list["job_civilian_med"]
	job_civilian_low = preference_list["job_civilian_low"]
	job_medsci_high = preference_list["job_medsci_high"]
	job_medsci_med = preference_list["job_medsci_med"]
	job_medsci_low = preference_list["job_medsci_low"]
	job_engsec_high = preference_list["job_engsec_high"]
	job_engsec_med = preference_list["job_engsec_med"]
	job_engsec_low = preference_list["job_engsec_low"]


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
	be_special      = sanitize_integer(be_special, 0, 65535, initial(be_special))

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
	S["be_special"]			>> be_special
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
	var/i = 0
	q.Add("SELECT slot FROM players WHERE ckey=?", ckey)
	if(q.Execute(db))
		while(q.NextRow())
			i++
	else
		message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
		return 0
	var/random_slot = rand(1,i)
	world << "This is random_slot : [random_slot]"
	load_save_sqlite(user, ckey, random_slot)
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

	check.Add("select ckey from players where ckey = ? and slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())            //1       2         3         4           5      6   7       8        9           10         11         12         13                14         15           16
			q.Add("INSERT INTO players (ckey,slot,ooc_notes,real_name,random_name,gender,age,species,language,flavor_text,med_record,sec_record,gen_record,player_alt_titles,be_special,disabilities,nanotrasen_relation) \
				   VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", ckey, slot, metadata, real_name, be_random_name, gender, age, species, language, flavor_text, med_record, sec_record, gen_record, player_alt_titles, be_special, disabilities, nanotrasen_relation)
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Created Character"
		else
			q.Add("UPDATE players SET ooc_notes=?,real_name=?,random_name=?,gender=?,age=?,species=?,language=?,flavor_text=?,med_record=?,sec_record=?,gen_record=?,player_alt_titles=?,be_special=?,disabilities=?,nanotrasen_relation=? WHERE ckey = ? AND slot = ?",\
									  metadata, real_name, be_random_name, gender, age, species, language, flavor_text, med_record, sec_record, gen_record, player_alt_titles, be_special, disabilities, nanotrasen_relation, ckey, slot)
			world << "Players Query : [q]"
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Updated Character"
	else
		message_admins("Error #:[check.Error()] - [check.ErrorMsg()]")
		return 0

	check.Add("select player_ckey from body where player_ckey = ? and player_slot = ?", ckey, slot)
	world << "Check Query : [check]"
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO body (player_ckey,player_slot,hair_red,hair_green,hair_blue,facial_red,facial_green,facial_blue,skin_tone,hair_style_name,facial_style_name,eyes_red,eyes_green,eyes_blue,underwear,backbag,b_type) \
					VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)", ckey, slot, r_hair, g_hair, b_hair, r_facial, g_facial, b_facial, s_tone, h_style, f_style, r_eyes, g_eyes, b_eyes, underwear, backbag, b_type)
			world << "Body Query : [q]"
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Created Body"
		else
			q.Add("UPDATE body SET hair_red=?,hair_green=?,hair_blue=?,facial_red=?,facial_green=?,facial_blue=?,skin_tone=?,hair_style_name=?,facial_style_name=?,eyes_red=?,eyes_green=?,eyes_blue=?,underwear=?,backbag=?,b_type=? WHERE player_ckey = ? AND player_slot = ?",\
									r_hair, g_hair, b_hair, r_facial, g_facial, b_facial, s_tone, h_style, f_style, r_eyes, g_eyes, b_eyes, underwear, backbag, b_type, ckey, slot)
			if(!q.Execute(db))
				message_admins("Error #:[q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Updated Body"
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		return 0

	check.Add("select player_ckey from jobs where player_ckey = ? and player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO jobs (player_ckey,player_slot,alternate_option,job_civilian_high,job_civilian_med,job_civilian_low,job_medsci_high,job_medsci_med,job_medsci_low,job_engsec_high,job_engsec_med,job_engsec_low) \
					VALUES (?,?,?,?,?,?,?,?,?,?,?,?)", ckey, slot, alternate_option, job_civilian_high, job_civilian_med, job_civilian_low, job_medsci_high, job_medsci_med, job_medsci_low, job_engsec_high, job_engsec_med, job_engsec_low)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Created Job list"
		else
			q.Add("UPDATE jobs SET job_civilian_high=?,job_civilian_med=?,job_civilian_low=?,job_medsci_high=?,job_medsci_med=?,job_medsci_low=?,job_engsec_high=?,job_engsec_med=?,job_engsec_low=? WHERE player_ckey = ? AND player_slot / ?",\
									job_civilian_high, job_civilian_med, job_civilian_low, job_medsci_high, job_medsci_med, job_medsci_low, job_engsec_high, job_engsec_med, job_engsec_low, ckey, slot)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				return 0
			user << "Updated Job List"
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
		return 0

	check.Add("select player_ckey from limbs where player_ckey = ? and player_slot = ?", ckey, slot)
	if(check.Execute(db))
		if(!check.NextRow())
			q.Add("INSERT INTO limbs (player_ckey, player_slot) VALUES (?,?)", ckey, slot)
			if(!q.Execute(db))
				message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
				return 0
			for(var/stuff in organ_data)
				q.Add("UPDATE limbs SET [stuff]=? WHERE player_ckey = ? AND player_slot = ?", organ_data[stuff], ckey, slot)
				if(!q.Execute(db))
					message_admins("Error #; [q.Error()] - [q.ErrorMsg()]")
					return 0
			user << "Created Limbs"
		else
			for(var/stuff in organ_data)
				q.Add("UPDATE limbs SET [stuff] = ? WHERE player_ckey = ? AND player_slot = ?", organ_data[stuff], ckey, slot)
				if(!q.Execute(db))
					message_admins("Error #: [q.Error()] - [q.ErrorMsg()]")
					return 0
			user << "Updated Limbs"
	else
		message_admins("Error #: [check.Error()] - [check.ErrorMsg()]")
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
	S["be_special"]			<< be_special
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
