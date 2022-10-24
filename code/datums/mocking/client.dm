/// This should match the interface of /client wherever necessary.
/datum/client_interface
	/// Player preferences datum for the client
	var/datum/preferences/prefs

	/// The view of the client, similar to /client/var/view.
	var/view = "15x15"

	/// Objects on the screen of the client
	var/list/screen = list()

	/// The mob the client controls
	var/mob/mob

	/// The ckey for this mock interface
	var/ckey = "mockclient"

	/// The key for this mock interface
	var/key = "mockclient"

/datum/client_interface/proc/IsByondMember()
	return FALSE

/datum/client_interface/New(key)
	..()
	if(key)
		src.key = key
		ckey = ckey(key)

/datum/client_interface/proc/set_macros()
	return
