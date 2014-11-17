/* HUD DATUMS */

var/datum/hud/huds = list( \
	DATA_HUD_SECURITY_BASIC = new/datum/hud/data/security/basic(), \
	DATA_HUD_SECURITY_ADVANCED = new/datum/hud/data/security/advanced(), \
	DATA_HUD_MEDICAL_BASIC = new/datum/hud/data/medical/basic(), \
	DATA_HUD_MEDICAL_ADVANCED = new/datum/hud/data/medical/advanced() \
	)

/atom/proc/add_to_all_huds()
	for(var/datum/hud/hud in huds) hud.add_to_hud(src)

/atom/proc/remove_from_all_huds()
	for(var/datum/hud/hud in huds) hud.remove_from_hud(src)

/datum/hud
	var/list/atom/hudatoms = list() //list of all atoms which display this hud
	var/list/mob/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list

/datum/hud/proc/remove_hud_from(var/mob/M)
	for(var/atom/A in hudatoms)
		remove_from_single_hud(M, A)
	hudusers -= M

/datum/hud/proc/remove_from_hud(var/atom/A)
	for(var/mob/M in hudusers)
		remove_from_single_hud(M, A)
	hudatoms -= A

/datum/hud/proc/remove_from_single_hud(var/mob/M, var/atom/A) //unsafe, no sanity apart from client
	if(!M.client)
		return
	for(var/i in hud_icons)
		M.client.images -= A.hud_list[i]

/datum/hud/proc/add_hud_to(var/mob/M)
	hudusers |= M
	for(var/atom/A in hudatoms)
		add_to_single_hud(M, A)

/datum/hud/proc/add_to_hud(var/atom/A)
	hudatoms |= A
	for(var/mob/M in hudusers)
		add_to_single_hud(M, A)

/datum/hud/proc/add_to_single_hud(var/mob/M, var/atom/A) //unsafe, no sanity apart from client
	if(!M.client)
		return
	for(var/i in hud_icons)
		M.client.images |= A.hud_list[i]
