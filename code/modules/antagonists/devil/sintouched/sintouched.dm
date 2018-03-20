#define SIN_ACEDIA "acedia"
#define SIN_GLUTTONY "gluttony"
#define SIN_GREED "greed"
#define SIN_SLOTH "sloth"
#define SIN_WRATH "wrath"
#define SIN_ENVY "envy"
#defien SIN_PRIDE "pride"

/datum/antagonist/sintouched
	name = "Soulless"
	roundend_category = "soulless"
	antagpanel_category = "soulless"
	var/sin

/datum/antagonist/sintouched/New()
	. = ..()
	sin = pick(SIN_ACEDIA,SIN_GLUTTONY,SIN_GREED,SIN_SLOTH,SIN_WRATH,SIN_ENVY,SIN_PRIDE)

/datum/antagonist/sintouched/proc/forge_objectives()
	var/datum/objective/sintouched/O
	switch(sin)//traditional seven deadly sins... except lust.
		if(1) // acedia
			O = new /datum/objective/sintouched/acedia
		if(2) // Gluttony
			O = new /datum/objective/sintouched/gluttony
		if(3) // Greed
			O = new /datum/objective/sintouched/greed
		if(4) // sloth
			O = new /datum/objective/sintouched/sloth
		if(5) // Wrath
			O = new /datum/objective/sintouched/wrath
		if(6) // Envy
			O = new /datum/objective/sintouched/envy
		if(7) // Pride
			O = new /datum/objective/sintouched/pride
	objectives += O

/datum/antagonist/sintouched/on_gain()
	forge_objectives()
	. = ..()

/datum/antagonist/sintouched/greet()
	owner.announce_objectives()

/datum/antagonist/sintouched/roundend_report()
	return

/datum/game_mode/proc/update_sintouched_icons_added(datum/mind/sintouched_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_SINTOUCHED]
	hud.join_hud(sintouched_mind.current)
	set_antag_hud(sintouched_mind.current, "sintouched")

/datum/game_mode/proc/update_sintouched_icons_removed(datum/mind/sintouched_mind)
	var/datum/atom_hud/antag/hud = GLOB.huds[ANTAG_HUD_SINTOUCHED]
	hud.leave_hud(sintouched_mind.current)
	set_antag_hud(sintouched_mind.current, null)