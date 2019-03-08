/datum/action/innate/gem/miningscan
	name = "Scan Ores"
	desc = "Vital for Kindergartening, you can find what ores are in the soil."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "healingtears"
	background_icon_state = "bg_spell"
	var/cooldown = 35
	var/current_cooldown = 0

/datum/action/innate/gem/miningscan/Activate()
	if(istype(owner, /mob/living/carbon))
		var/mob/living/carbon/C = owner
		if(current_cooldown <= world.time)
			current_cooldown = world.time + cooldown
			mineral_scan_pulse(get_turf(C))