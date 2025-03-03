/// This should match the interface of /client wherever necessary.
/datum/client_interface
	/// Player preferences datum for the client
	var/datum/preferences/prefs

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

	/// client prefs
	var/fps
	var/hotkeys
	var/tgui_say
	var/typing_indicators

/datum/client_interface/New()
	..()
	var/static/mock_client_uid = 0
	mock_client_uid++

	src.key = "[key]_[mock_client_uid]"
	ckey = ckey(key)

#ifdef UNIT_TESTS // otherwise this shit can leak into production servers which is drather bad
	GLOB.directory[ckey] = src
#endif

/datum/client_interface/Destroy(force)
	GLOB.directory -= ckey
	return ..()

/datum/client_interface/proc/IsByondMember()
	return FALSE

/datum/client_interface/proc/set_macros()
	return

/datum/client_interface/proc/update_ambience_pref()
	return

/datum/client_interface/proc/get_award_status(achievement_type, mob/user, value = 1)
	return FALSE
