/datum/team/dwarves
	name = "Dwarven Empire"
	show_roundend_report = TRUE

/datum/antagonist/dwarf
	name = "Ash Walker"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Dwarves"
	var/datum/team/dwarves/dwarf_team

/datum/antagonist/dwarf/create_team(datum/team/team)
	if(team)
		dwarf_team = team
		objectives |= dwarf_team.objectives
	else
		dwarf_team = new

/datum/antagonist/dwarf/get_team()
	return dwarf_team

/datum/antagonist/dwarf/greet()
	to_chat(owner.current, "<span class='warning'>As a dwarf you must follow these 5 tenats:</span><br>")
	to_chat(owner.current, "<span class='warning'>You may never kill or maim another dwarf intentionally outside of a duel!</span><br>")
	to_chat(owner.current, "<span class='warning'>Fortune is worth more than spilt blood!</span><br>")
	to_chat(owner.current, "<span class='warning'>Expand your emprire and crush anyone who resists!</span><br>")
	to_chat(owner.current, "<span class='warning'>Trade and barter with foreigners, force shall be applied only when they provoke you!</span><br>")
	to_chat(owner.current, "<span class='warning'>You may never leave this ashen land for it is your homeland!</span><br>")
