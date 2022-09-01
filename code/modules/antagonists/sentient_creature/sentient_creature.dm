/datum/antagonist/sentient_creature
	name = "\improper Sentient Creature"
	show_in_antagpanel = FALSE
	show_in_roundend = FALSE
	silent = TRUE

/datum/antagonist/sentient_creature/get_preview_icon()
	var/icon/corgi = icon('icons/mob/pets.dmi', "corgi")
	corgi.Blend(COLOR_LIGHT_PINK, ICON_MULTIPLY)
	return corgi
