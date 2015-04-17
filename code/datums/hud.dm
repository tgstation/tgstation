/* HUD DATUMS */

//GLOBAL HUD LIST
var/datum/atom_hud/huds = list( \
	DATA_HUD_SECURITY_BASIC = new/datum/atom_hud/data/security/basic(), \
	DATA_HUD_SECURITY_ADVANCED = new/datum/atom_hud/data/security/advanced(), \
	DATA_HUD_MEDICAL_BASIC = new/datum/atom_hud/data/medical/basic(), \
	DATA_HUD_MEDICAL_ADVANCED = new/datum/atom_hud/data/medical/advanced(), \
	ANTAG_HUD_CULT = new/datum/atom_hud/antag(), \
	ANTAG_HUD_REV = new/datum/atom_hud/antag(), \
	ANTAG_HUD_OPS = new/datum/atom_hud/antag(), \
	ANTAG_HUD_GANG_A = new/datum/atom_hud/antag(), \
	ANTAG_HUD_GANG_B = new/datum/atom_hud/antag(), \
	ANTAG_HUD_WIZ = new/datum/atom_hud/antag(), \
	ANTAG_HUD_SHADOW = new/datum/atom_hud/antag(), \
	)

/datum/atom_hud
	var/list/atom/hudatoms = list() //list of all atoms which display this hud
	var/list/mob/hudusers = list() //list with all mobs who can see the hud
	var/list/hud_icons = list() //these will be the indexes for the atom's hud_list

/datum/atom_hud/proc/remove_hud_from(var/mob/M)
	if(src in M.permanent_huds)
		return
	for(var/atom/A in hudatoms)
		remove_from_single_hud(M, A)
	hudusers -= M

/datum/atom_hud/proc/remove_from_hud(var/atom/A)
	for(var/mob/M in hudusers)
		remove_from_single_hud(M, A)
	hudatoms -= A

/datum/atom_hud/proc/remove_from_single_hud(var/mob/M, var/atom/A) //unsafe, no sanity apart from client
	if(!M.client)
		return
	for(var/i in hud_icons)
		M.client.images -= A.hud_list[i]

/datum/atom_hud/proc/add_hud_to(var/mob/M)
	hudusers |= M
	for(var/atom/A in hudatoms)
		add_to_single_hud(M, A)

/datum/atom_hud/proc/add_to_hud(var/atom/A)
	hudatoms |= A
	for(var/mob/M in hudusers)
		add_to_single_hud(M, A)

/datum/atom_hud/proc/add_to_single_hud(var/mob/M, var/atom/A) //unsafe, no sanity apart from client
	if(!M.client)
		return
	for(var/i in hud_icons)
		M.client.images |= A.hud_list[i]

//MOB PROCS
/mob/proc/reload_huds()
	for(var/datum/atom_hud/hud in huds)
		if(src in hud.hudusers)
			hud.add_hud_to(src)
