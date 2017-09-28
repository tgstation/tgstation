/datum/atom_hud/antag
	hud_icons = list(ANTAG_HUD)
	var/self_visible = TRUE

/datum/atom_hud/antag/hidden
	self_visible = FALSE

/datum/atom_hud/antag/proc/join_hud(mob/M)
	//sees_hud should be set to 0 if the mob does not get to see it's own hud type.
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	if(M.mind.antag_hud) //note: please let this runtime if a mob has no mind, as mindless mobs shouldn't be getting antagged
		M.mind.antag_hud.leave_hud(M)
	add_to_hud(M)
	if(self_visible)
		add_hud_to(M)
	M.mind.antag_hud = src

/datum/atom_hud/antag/proc/leave_hud(mob/M)
	if(!M)
		return
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	remove_from_hud(M)
	remove_hud_from(M)
	if(M.mind)
		M.mind.antag_hud = null


//GAME_MODE PROCS
//called to set a mob's antag icon state
/datum/game_mode/proc/set_antag_hud(mob/M, new_icon_state)
	if(!istype(M))
		CRASH("set_antag_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.icon_state = new_icon_state
	if(M.mind || new_icon_state) //in mindless mobs, only null is acceptable, otherwise we're antagging a mindless mob, meaning we should runtime
		M.mind.antag_hud_icon_state = new_icon_state


//MIND PROCS
//these are called by mind.transfer_to()
/datum/mind/proc/transfer_antag_huds(datum/atom_hud/antag/newhud)
	leave_all_antag_huds()
	SSticker.mode.set_antag_hud(current, antag_hud_icon_state)
	if(newhud)
		newhud.join_hud(current)

/datum/mind/proc/leave_all_antag_huds()
	for(var/datum/atom_hud/antag/hud in GLOB.huds)
		if(hud.hudusers[current])
			hud.leave_hud(current)