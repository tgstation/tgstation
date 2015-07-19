/datum/atom_hud/antag
	hud_icons = list(ANTAG_HUD)

/datum/atom_hud/antag/proc/join_hud(mob/living/M)
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a living mob!")
	if(M.mind.antag_hud)
		var/datum/atom_hud/antag/oldhud = M.mind.antag_hud
		oldhud.leave_hud(M)
	add_to_hud(M)
	add_hud_to(M)
	M.mind.antag_hud = src

/datum/atom_hud/antag/proc/leave_hud(mob/living/M)
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a living mob!")
	remove_from_hud(M)
	remove_hud_from(M)
	M.mind.antag_hud = null


//GAME_MODE PROCS
//called to set a mob's antag icon state
/datum/game_mode/proc/set_antag_hud(mob/living/M, new_icon_state)
	if(!istype(M))
		CRASH("set_antag_hud(): [M] ([M.type]) is not a living mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	holder.icon_state = new_icon_state
	M.mind.antag_hud_icon_state = new_icon_state


//MIND PROCS
//this is called by mind.transfer_to()
/datum/mind/proc/transfer_antag_huds(mob/living/M)
	for(var/datum/atom_hud/antag/hud in huds)
		if(M in hud.hudusers)
			hud.leave_hud(M)
	var/image/holder = M.hud_list[ANTAG_HUD]
	holder.icon_state = antag_hud_icon_state
	if(antag_hud)
		antag_hud.join_hud(M)
