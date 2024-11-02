/atom/movable/screen/perk
	icon = 'icons/hud/perks.dmi'
	name = "blank"
	icon_state = "blank"

/atom/movable/screen/perk/more
	name = "more"
	icon_state = "more"
	// When compact we don't show our perk huds in ui.
	var/compact = FALSE
	// List of all perks that we see on hud.
	var/list/perks_on_hud = list()
	// List to remember all perks we hide when compact it.
	var/list/perks_compacted = list()

/atom/movable/screen/perk/more/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return
	var/mob/living/usr_is_living = usr
	var/datum/antagonist/wizard/wizard_datum = usr_is_living.mind.has_antag_datum(/datum/antagonist/wizard)
	if(!wizard_datum)
		return
	compact = !compact
	var/datum/hud/user_hud = usr_is_living.hud_used
	if(compact)
		for(var/atom/movable/screen/perk/perk_on_hud as anything in perks_on_hud)
			perks_compacted += perk_on_hud
			user_hud.infodisplay -= perk_on_hud
		user_hud.show_hud(user_hud.hud_version)
	else
		for(var/atom/movable/screen/perk/perk_compacted as anything in perks_compacted)
			user_hud.infodisplay += perk_compacted
			perks_compacted -= perk_compacted
		user_hud.show_hud(user_hud.hud_version)
