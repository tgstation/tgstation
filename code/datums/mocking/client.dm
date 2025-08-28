/// This should match the interface of /client wherever necessary.
/datum/client_interface
	/// Player preferences datum for the client
	var/datum/preferences/prefs

	/// These persist between logins/logouts during the same round.
	var/datum/persistent_client/persistent_client

	/// The view of the client, similar to /client/var/view.
	var/view = "15x15"

	/// View data of the client, similar to /client/var/view_size.
	var/datum/view_data/view_size

	/// Objects on the screen of the client
	var/list/screen = list()

	/// The mob the client controls
	var/mob/mob

	/// The ckey for this mock interface
	var/ckey = "mockclient"

	/// The key for this mock interface
	var/key = "mockclient"

	/// Mock ban cache to avoid runtimes when testing bans
	var/ban_cache = null
	var/ban_cache_start = 0

	// Mock BYOND version will always be the same as the server's BYOND version.
	var/byond_version
	var/byond_build

	/// client prefs
	var/fps
	var/hotkeys
	var/tgui_say
	var/typing_indicators
	var/window_scaling

	var/fully_created = FALSE

	var/static/mock_client_uid = 0

/datum/client_interface/New()
	..()

	byond_version = world.byond_version
	byond_build = world.byond_build

	src.key = "[key]_[mock_client_uid++]"
	ckey = ckey(key)

#ifdef UNIT_TESTS // otherwise this shit can leak into production servers which is drather dbad
	GLOB.directory[ckey] = src

	if(GLOB.persistent_clients_by_ckey[ckey])
		persistent_client = GLOB.persistent_clients_by_ckey[ckey]
	else
		persistent_client = new(ckey)
	persistent_client.set_client(src)
#endif

	fully_created = TRUE

/datum/client_interface/Destroy(force)
	GLOB.directory -= ckey
	if(persistent_client?.client == src)
		persistent_client.set_client(null)
	persistent_client = null
	return ..()

/datum/client_interface/proc/IsByondMember()
	return FALSE

/datum/client_interface/proc/set_macros()
	return

/datum/client_interface/proc/update_ambience_pref()
	return

/datum/client_interface/proc/get_award_status(achievement_type, mob/user, value = 1)
	return FALSE

/datum/client_interface/proc/set_fullscreen(logging_in = FALSE)
	return TRUE
