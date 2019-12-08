/datum/atom_hud/antag/gang
	var/color = null

/datum/atom_hud/antag/gang/add_to_hud(atom/A)
	if(!A)
		return
	var/image/holder = A.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = color
	..()

/datum/atom_hud/antag/gang/remove_from_hud(atom/A)
	if(!A)
		return
	var/image/holder = A.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = null
	..()

/datum/atom_hud/antag/gang/join_hud(mob/M)
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = color
	..()

/datum/atom_hud/antag/gang/leave_hud(mob/M)
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = null
	..()
