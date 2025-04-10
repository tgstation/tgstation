/**
 *	# Auspex
 *
 *	Level 1 - Cloak of Darkness until clicking an area, teleports the user to the selected area (max 2 tile)
 *	Level 2 - Cloak of Darkness until clicking an area, teleports the user to the selected area (max 3 tiles)
 *	Level 3 - Cloak of Darkness until clicking an area, teleports the user to the selected area
 *	Level 4 - Cloak of Darkness until clicking an area, teleports the user to the selected area, causes nearby people to bleed.
 *	Level 5 - Cloak of Darkness until clicking an area, teleports the user to the selected area, causes nearby people to fall asleep.
 */

// Look to /datum/action/cooldown/spell/pointed/void_phase for help.

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex
	name = "Level 1: Auspex"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/auspex/two
	level_current = 1
	desc = "Hide yourself within a Cloak of Darkness, click on an area to teleport up to 2 tiles away."
	button_icon_state = "power_auspex"
	power_explanation = "Level 1: Auspex:\n\
		When activated you will be hidden in a Cloak of Darkness.\n\
		Click any area up to 2 tiles away to teleport there, ending the power."
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	bloodcost = 5
	constant_bloodcost = 2
	cooldown_time = 12 SECONDS
	target_range = 2
	prefire_message = "Where do you wish to teleport to?"

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/two
	name = "Level 2: Auspex"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/auspex/three
	level_current = 2
	desc = "Hide yourself within a Cloak of Darkness, click on an area to teleport up to 3 tiles away."
	power_explanation = "Level 2: Auspex:\n\
		When activated you will be hidden in a Cloak of Darkness.\n\
		Click any area up to 3 tiles away to teleport there, ending the power."
	bloodcost = 10
	cooldown_time = 10 SECONDS
	target_range = 3

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/three
	name = "Level 3: Auspex"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/auspex/advanced
	level_current = 3
	desc = "Hide yourself within a Cloak of Darkness, click on an area to teleport."
	power_explanation = "Level 3: Auspex:\n\
		When activated you will be hidden in a Cloak of Darkness.\n\
		Click any area to teleport there, ending the power."
	bloodcost = 15
	cooldown_time = 8 SECONDS
	target_range = null

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/advanced
	name = "Level 4: Auspex"
	upgraded_power = /datum/action/cooldown/bloodsucker/targeted/tremere/auspex/advanced/two
	level_current = 4
	desc = "Hide yourself within a Cloak of Darkness, click on an area to teleport, leaving nearby people bleeding."
	power_explanation = "Level 4: Auspex:\n\
		When activated you will be hidden in a Cloak of Darkness.\n\
		Click any area to teleport there, ending the power and causing people at your end location to start bleeding."
	background_icon_state = "tremere_power_gold_off"
	active_background_icon_state = "tremere_power_gold_on"
	base_background_icon_state = "tremere_power_gold_off"
	bloodcost = 20
	cooldown_time = 6 SECONDS
	target_range = null

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/advanced/two
	name = "Level 5: Auspex"
	upgraded_power = null
	level_current = 5
	desc = "Hide yourself within a Cloak of Darkness, click on an area to teleport, leaving nearby people bleeding and asleep."
	power_explanation = "Level 5: Auspex:\n\
		When activated you will be hidden in a Cloak of Darkness.\n\
		Click any area up to teleport there, ending the power and causing people at your end location to fall over in pain."
	bloodcost = 25
	cooldown_time = 8 SECONDS

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isturf(target_atom)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/ActivatePower(trigger_flags)
	. = ..()
	owner.AddElement(/datum/element/digitalcamo)
	animate(owner, alpha = 15, time = 1 SECONDS)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/DeactivatePower()
	animate(owner, alpha = 255, time = 1 SECONDS)
	owner.RemoveElement(/datum/element/digitalcamo)
	return ..()

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	var/turf/targeted_turf = get_turf(target_atom)
	auspex_blink(user, targeted_turf)

/datum/action/cooldown/bloodsucker/targeted/tremere/auspex/proc/auspex_blink(mob/living/user, turf/targeted_turf)
	playsound(user, 'sound/effects/magic/summon_karp.ogg', 60)
	playsound(targeted_turf, 'sound/effects/magic/summon_karp.ogg', 60)

	new /obj/effect/particle_effect/fluid/smoke/vampsmoke(user.drop_location())
	new /obj/effect/particle_effect/fluid/smoke/vampsmoke(targeted_turf)

	for(var/mob/living/carbon/living_mob in range(1, targeted_turf)-user)
		if(IS_BLOODSUCKER(living_mob) || IS_VASSAL(living_mob))
			continue
		if(level_current >= 4)
			var/obj/item/bodypart/bodypart = pick(living_mob.bodyparts)
			bodypart.force_wound_upwards(/datum/wound/slash/flesh/critical)
			living_mob.adjustBruteLoss(15)
		if(level_current >= 5)
			living_mob.Knockdown(10 SECONDS, ignore_canstun = TRUE)

	do_teleport(owner, targeted_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_QUANTUM)
	power_activated_sucessfully()
