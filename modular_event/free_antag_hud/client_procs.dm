/client/verb/toggle_team_huds() //shameless copy from admin verbs
	set name = "Toggle Team/Antag HUD"
	set desc = "Toggles whether you see Arena Team and Antagonist HUDs"
	set category = "Special"

	var/adding_hud = !has_antag_hud()

	for(var/datum/atom_hud/antag/H in GLOB.huds)
		adding_hud ? H.add_hud_to(usr) : H.remove_hud_from(usr)

	to_chat(usr, "Team HUDs [adding_hud ? "enabled" : "disabled"].")
