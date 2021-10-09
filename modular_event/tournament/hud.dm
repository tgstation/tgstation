/obj/machinery/computer/tournament_controller/proc/setup_team_huds()
	var/list/team_huds = list()
	team_huds[ARENA_RED_TEAM] = setup_team_hud("red")
	team_huds[ARENA_GREEN_TEAM] = setup_team_hud("green")
	return team_huds

/obj/machinery/computer/tournament_controller/proc/setup_team_hud(color)
	var/datum/atom_hud/antag/team_hud = new
	team_hud.icon_color = color
	GLOB.huds += team_hud
	return GLOB.huds.len

/obj/machinery/computer/tournament_controller/proc/assign_team_hud(mob/mob, team_id)
	var/index = team_hud_ids[team_id]
	var/datum/atom_hud/antag/team_hud = GLOB.huds[index]
	team_hud.join_hud(mob)
	set_antag_hud(mob, "arena", index)
