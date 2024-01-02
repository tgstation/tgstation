/datum/antagonist/crew
	name = "\improper Ship Crewmember"
	hud_icon = 'voidcrew/icons/mob/huds/faction_hud.dmi'
	antag_hud_name = "NEU"
	show_in_roundend = FALSE
	show_in_antagpanel = FALSE
	silent = TRUE

/datum/antagonist/crew/apply_innate_effects(mob/living/mob_override)
	if(owner.ship_team && owner.ship_team.faction_prefix)
		antag_hud_name = owner.ship_team.faction_prefix
	add_team_hud(mob_override || owner.current)

