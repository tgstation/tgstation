/atom/movable/screen/perk
	icon = 'icons/hud/perks.dmi'
	name = "blank"
	icon_state = "blank"

/atom/movable/screen/perk/more
	name = "more"
	icon_state = "more"
	// When compact we don't show our perk huds in ui.
	var/compact = FALSE

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
	for (var/perk_id in 1 to length(wizard_datum.perks))
		var/atom/movable/screen/perk/perk = user_hud.screen_objects[HUD_WIZARD_PERK(perk_id)]
		if (!perk) // ??
			continue
		if (compact)
			perk.SetInvisibility(INVISIBILITY_ABSTRACT, type)
		else
			perk.RemoveInvisibility(type)
