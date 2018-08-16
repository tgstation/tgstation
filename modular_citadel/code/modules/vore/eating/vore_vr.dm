
/*
VVVVVVVV           VVVVVVVV     OOOOOOOOO     RRRRRRRRRRRRRRRRR   EEEEEEEEEEEEEEEEEEEEEE
V::::::V           V::::::V   OO:::::::::OO   R::::::::::::::::R  E::::::::::::::::::::E
V::::::V           V::::::V OO:::::::::::::OO R::::::RRRRRR:::::R E::::::::::::::::::::E
V::::::V           V::::::VO:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEEE::::E
 V:::::V           V:::::V O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
  V:::::V         V:::::V  O:::::O     O:::::O  R::::R     R:::::R  E:::::E
   V:::::V       V:::::V   O:::::O     O:::::O  R::::RRRRRR:::::R   E::::::EEEEEEEEEE
    V:::::V     V:::::V    O:::::O     O:::::O  R:::::::::::::RR    E:::::::::::::::E
     V:::::V   V:::::V     O:::::O     O:::::O  R::::RRRRRR:::::R   E:::::::::::::::E
      V:::::V V:::::V      O:::::O     O:::::O  R::::R     R:::::R  E::::::EEEEEEEEEE
       V:::::V:::::V       O:::::O     O:::::O  R::::R     R:::::R  E:::::E
        V:::::::::V        O::::::O   O::::::O  R::::R     R:::::R  E:::::E       EEEEEE
         V:::::::V         O:::::::OOO:::::::ORR:::::R     R:::::REE::::::EEEEEEEE:::::E
          V:::::V           OO:::::::::::::OO R::::::R     R:::::RE::::::::::::::::::::E
           V:::V              OO:::::::::OO   R::::::R     R:::::RE::::::::::::::::::::E
            VVV                 OOOOOOOOO     RRRRRRRR     RRRRRRREEEEEEEEEEEEEEEEEEEEEE

-Aro <3 */

//
// Overrides/additions to stock defines go here, as well as hooks. Sort them by
// the object they are overriding. So all /mob/living together, etc.
//

//
// The datum type bolted onto normal preferences datums for storing Vore stuff
//
/client
	var/datum/vore_preferences/prefs_vr

/hook/client_new/proc/add_prefs_vr(client/C)
	C.prefs_vr = new/datum/vore_preferences(C)
	if(C.prefs_vr)
		return TRUE

	return FALSE

/datum/vore_preferences
	//Actual preferences
	var/digestable = TRUE
	var/devourable = FALSE
//	var/allowmobvore = TRUE
	var/list/belly_prefs = list()
	var/vore_taste = "nothing in particular"
//	var/can_be_drop_prey = FALSE
//	var/can_be_drop_pred = FALSE

	//Mechanically required
	var/path
	var/slot
	var/client/client
	var/client_ckey

/datum/vore_preferences/New(client/C)
	if(istype(C))
		client = C
		client_ckey = C.ckey
		load_vore()

//
//	Check if an object is capable of eating things, based on vore_organs
//
/proc/is_vore_predator(var/mob/living/O)
	if(istype(O,/mob/living))
		if(O.vore_organs.len > 0)
			return TRUE

	return FALSE

//
//	Belly searching for simplifying other procs
//  Mostly redundant now with belly-objects and isbelly(loc)
//
/proc/check_belly(atom/movable/A)
	return isbelly(A.loc)

//
// Save/Load Vore Preferences
//
/datum/vore_preferences/proc/load_path(ckey,slot,filename="character",ext="json")
	if(!ckey || !slot)	return
	path = "data/player_saves/[copytext(ckey,1,2)]/[ckey]/vore/[filename][slot].[ext]"


/datum/vore_preferences/proc/load_vore()
	if(!client || !client_ckey)
		return FALSE //No client, how can we save?
	if(!client.prefs || !client.prefs.default_slot)
		return FALSE //Need to know what character to load!

	slot = client.prefs.default_slot

	load_path(client_ckey,slot)

	if(!path) return FALSE //Path couldn't be set?
	if(!fexists(path)) //Never saved before
		save_vore() //Make the file first
		return TRUE

	var/list/json_from_file = json_decode(file2text(path))
	if(!json_from_file)
		return FALSE //My concern grows

	var/version = json_from_file["version"]
	json_from_file = patch_version(json_from_file,version)

	digestable = json_from_file["digestable"]
	devourable = json_from_file["devourable"]
	vore_taste = json_from_file["vore_taste"]
	belly_prefs = json_from_file["belly_prefs"]

	//Quick sanitize
	if(isnull(digestable))
		digestable = TRUE
	if(isnull(devourable))
		devourable = FALSE
	if(isnull(belly_prefs))
		belly_prefs = list()

	return TRUE
/*
	allowmobvore = json_from_file["allowmobvore"]
	can_be_drop_prey = json_from_file["can_be_drop_prey"]
	can_be_drop_prey = json_from_file["can_be_drop_pred"]

	if(isnull(allowmobvore))
		allowmobvore = TRUE
	if(isnull(can_be_drop_prey))
		allowmobvore = FALSE
	if(isnull(can_be_drop_pred))
		allowmobvore = FALSE */

/datum/vore_preferences/proc/save_vore()
	if(!path)				return FALSE

	var/version = 1	//For "good times" use in the future
	var/list/settings_list = list(
			"version"				= version,
			"digestable"			= digestable,
			"devourable"			= devourable,
			"vore_taste"			= vore_taste,
			"belly_prefs"			= belly_prefs,
		)

	//List to JSON
	var/json_to_file = json_encode(settings_list)
	if(!json_to_file)
		testing("Saving: [path] failed jsonencode")
		return FALSE

	//Write it out
	if(fexists(path))
		fdel(path) //Byond only supports APPENDING to files, not replacing.
	text2file(json_to_file,path)
	if(!fexists(path))
		testing("Saving: [path] failed file write")
		return FALSE

	return TRUE

/* commented out list things
	"allowmobvore"			= allowmobvore,
	"can_be_drop_prey"		= can_be_drop_prey,
	"can_be_drop_pred"		= can_be_drop_pred, */

//Can do conversions here
/datum/vore_preferences/proc/patch_version(var/list/json_from_file,var/version)
	return json_from_file