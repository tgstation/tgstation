#define SAVEFILE_VERSION_MIN	2
#define SAVEFILE_VERSION_MAX	3

datum/preferences/proc/savefile_path(mob/user)
	return "data/player_saves/[copytext(user.ckey, 1, 2)]/[user.ckey]/preferences.sav"

datum/preferences/proc/savefile_save(mob/user)
	if (IsGuestKey(user.key))
		return 0

	var/savefile/F = new /savefile(src.savefile_path(user))
	var/version
	F["version"] >> version

	if (!isnull(version) && version<=2)
		F["be_syndicate"] << null
		F["be_alien"] << null
		F["UI"] << null

	F["version"] << SAVEFILE_VERSION_MAX

	F["real_name"] << src.real_name
	F["gender"] << src.gender
	F["age"] << src.age
	F["occupation_1"] << src.occupation[1]
	F["occupation_2"] << src.occupation[2]
	F["occupation_3"] << src.occupation[3]
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
	//F["be_syndicate"] << src.be_syndicate
	F["be_special"] << src.be_special
	F["underwear"] << src.underwear
	F["name_is_always_random"] << src.be_random_name
	F["UI"] << src.UI // Skie
	//world << "DEBUG: saving UI as [UI]"
	//F["be_alien"] << src.be_alien // Urist
	F["midis"] << src.midis // Urist
	F["bubbles"] << src.bubbles // Doohl
	F["ooccolor"] << src.ooccolor // Urist
	F["lastchangelog"] << src.lastchangelog // rastaf0


	return 1

// loads the savefile corresponding to the mob's ckey
// if silent=true, report incompatible savefiles
// returns 1 if loaded (or file was incompatible)
// returns 0 if savefile did not exist

datum/preferences/proc/savefile_load(mob/user, var/silent = 1)
	if (IsGuestKey(user.key))
		return 0

	var/path = savefile_path(user)

	if (!fexists(path))
		return 0

	var/savefile/F = new /savefile(path)

	var/version = null
	F["version"] >> version

	if (isnull(version) || version < SAVEFILE_VERSION_MIN || version > SAVEFILE_VERSION_MAX)
		fdel(path)

//		if (!silent)
//			alert(user, "Your savefile was incompatible with this version and was deleted.")

		return 0

	F["real_name"] >> src.real_name
	F["gender"] >> src.gender
	F["age"] >> src.age
	F["occupation_1"] >> src.occupation[1]
	F["occupation_2"] >> src.occupation[2]
	F["occupation_3"] >> src.occupation[3]
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
	F["name_is_always_random"] >> src.be_random_name
	//F["be_alien"] >> src.be_alien // Urist
	F["midis"] >> src.midis // Urist
	F["bubbles"] >> src.bubbles // Doohl
	F["ooccolor"] >> src.ooccolor // Urist
	F["lastchangelog"] >> src.lastchangelog // rastaf0


	if (version<=2) // migration from old preferences file format --rastaf0
		src.UI = 0 // swithing from storing an image file to storing boolean value --rastaf0
		//world << "DEBUG: loading legacy UI as [UI]"
		var/tmp
		F["be_syndicate"] >> tmp
		if (tmp)
			be_special |= BE_TRAITOR
			be_special |= BE_OPERATIVE
			be_special |= BE_CHANGELING
			be_special |= BE_WIZARD
			be_special |= BE_MALF
			be_special |= BE_REV
		F["be_alien"] >> tmp
		F["be_pai"] >> tmp
		if (tmp)
			be_special |= BE_ALIEN
			be_special |= BE_PAI
		del(F)
		fdel(path)
		savefile_save(user)
	else // /migration end
		F["UI"] >> src.UI
		F["be_special"] >> src.be_special
		//world << "DEBUG: loading new UI as [UI]"

	return 1

#undef SAVEFILE_VERSION_MAX
#undef SAVEFILE_VERSION_MIN
