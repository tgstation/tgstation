/datum/atom_hud/antag
	hud_icons = list(ANTAG_HUD)

/datum/atom_hud/antag/proc/join_hud(var/mob/M)
	add_to_hud(M)
	add_hud_to(M)

/datum/atom_hud/antag/proc/leave_hud(var/mob/M)
	remove_from_hud(M)
	remove_hud_from(M)

/datum/atom_hud/antag/readd_hud(var/mob/M)
	join_hud(M)

/datum/game_mode/proc/set_antag_hud(var/mob/M, var/new_icon_state)
	var/image/holder = M.hud_list[ANTAG_HUD]
	holder.icon_state = new_icon_state
