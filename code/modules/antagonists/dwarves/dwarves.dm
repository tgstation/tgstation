GLOBAL_DATUM_INIT(dwarven_empire,/datum/team/dwarves,new) //All dorfs are one big family

/datum/team/dwarves
	name = "Dwarven Empire"
	show_roundend_report = FALSE // FALSE until i figure out the multiple dwarven empires bug

/datum/antagonist/dwarf
	name = "Dwarf"
	job_rank = ROLE_LAVALAND
	show_in_antagpanel = FALSE
	prevent_roundtype_conversion = FALSE
	antagpanel_category = "Dwarves"
	var/datum/team/dwarves/dwarf_team

/datum/antagonist/dwarf/create_team(datum/team/team)
	if(team)
		dwarf_team = team
	else
		dwarf_team = new

/datum/antagonist/dwarf/get_team()
	return dwarf_team

/datum/antagonist/dwarf/greet()
	var/message = CONFIG_GET(string/dwarves_tenants)
	to_chat(owner.current, message)
