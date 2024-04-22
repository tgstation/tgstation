///////
/// SLIME CLEANING ABILITY
/// Makes it so slimes clean themselves.

/datum/action/cooldown/spell/slime_washing
	name = "Toggle Slime Cleaning"
	desc = "Filter grime through your outer membrane, cleaning yourself and your equipment for sustenance. Also cleans the floor, providing your feet are uncovered. For sustenance."
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "activate_wash"

	cooldown_time = 1 SECONDS
	spell_requirements = NONE

/datum/action/cooldown/spell/slime_washing/cast(mob/living/carbon/human/user = usr)
	. = ..()

	if(user.has_status_effect(/datum/status_effect/slime_washing))
		slime_washing_deactivate(user)
		return

	user.apply_status_effect(/datum/status_effect/slime_washing)
	user.visible_message(span_purple("[user]'s outer membrane starts to develop a roiling film on the outside, absorbing grime into their inner layer!"), span_purple("Your outer membrane develops a roiling film on the outside, absorbing grime off yourself and your clothes; as well as the floor beneath you."))

/datum/action/cooldown/spell/slime_washing/proc/slime_washing_deactivate(mob/living/carbon/human/user) //Called when you activate it again after casting the ability-- turning them off, so to say.
	if(!user.has_status_effect(/datum/status_effect/slime_washing))
		return

	user.remove_status_effect(/datum/status_effect/slime_washing)
	user.visible_message(span_notice("[user]'s outer membrane returns to normal, no longer cleaning [user.p_their()] surroundings."), span_notice("Your outer membrane returns to normal, filth no longer being cleansed."))

/datum/status_effect/slime_washing
	id = "slime_washing"
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/slime_washing/tick(seconds_between_ticks, seconds_per_tick)
	if(ishuman(owner))
		var/mob/living/carbon/human/slime = owner
		for(var/obj/item/slime_items in slime.get_equipped_items(include_pockets = FALSE))
			slime_items.wash(CLEAN_WASH)
			slime.wash(CLEAN_WASH)
		if((slime.wear_suit?.body_parts_covered | slime.w_uniform?.body_parts_covered | slime.shoes?.body_parts_covered) & FEET)
			return
		else
			var/turf/open/open_turf = get_turf(slime)
			if(istype(open_turf))
				open_turf.wash(CLEAN_WASH)
				return TRUE
			if (SPT_PROB(5, seconds_per_tick))
				slime.adjust_nutrition((rand(5,25)))

/datum/status_effect/slime_washing/get_examine_text()
	return span_notice("[owner.p_Their()] outer layer is pulling in grime, filth sinking inside of their body and vanishing.")

///////
/// HYDROPHOBIA SPELL
/// Makes it so that slimes are waterproof, but slower, and they don't regenerate.

/datum/action/cooldown/spell/slime_hydrophobia
	name = "Toggle Hydrophobia"
	desc = "Develop an oily layer on your outer membrane, repelling water at the cost of lower viscosity."
	button_icon = 'icons/mob/actions/actions_items.dmi'
	button_icon_state = "nanite_shield"

	cooldown_time = 1 MINUTES
	spell_requirements = NONE

/datum/action/cooldown/spell/slime_hydrophobia/cast(mob/living/carbon/human/user = usr)
	. = ..()

	if(user.has_status_effect(/datum/status_effect/slime_hydrophobia))
		slime_hydrophobia_deactivate(user)
		return

	ADD_TRAIT(user, TRAIT_SLIME_HYDROPHOBIA, ACTION_TRAIT)
	user.apply_status_effect(/datum/status_effect/slime_hydrophobia)
	user.visible_message(span_purple("[user]'s outer membrane starts to ooze out an oily coating, [owner.p_their()] body becoming more viscous!"), span_purple("Your outer membrane starts to ooze out an oily coating, protecting you from water but making your body more viscous."))

/datum/action/cooldown/spell/slime_hydrophobia/proc/slime_hydrophobia_deactivate(mob/living/carbon/human/user)
	if(!user.has_status_effect(/datum/status_effect/slime_hydrophobia))
		return

	REMOVE_TRAIT(user, TRAIT_SLIME_HYDROPHOBIA, ACTION_TRAIT)
	user.remove_status_effect(/datum/status_effect/slime_hydrophobia)
	user.visible_message(span_purple("[user]'s outer membrane returns to normal, [owner.p_their()] body drawing the oily coat back inside!"), span_purple("Your outer membrane returns to normal, water being dangerous to you again."))

/datum/movespeed_modifier/status_effect/slime_hydrophobia
	multiplicative_slowdown = 1.5

/datum/status_effect/slime_hydrophobia
	id = "slime_hydrophobia"
	alert_type = null
	status_type = STATUS_EFFECT_UNIQUE

/datum/status_effect/slime_hydrophobia/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/slime_hydrophobia, update=TRUE)

/datum/status_effect/slime_hydrophobia/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/slime_hydrophobia, update=TRUE)

/datum/status_effect/slime_hydrophobia/get_examine_text()
	return span_notice("[owner.p_They()] is oozing out an oily coating onto [owner.p_their()] outer membrane, water rolling right off.")


/// REGENERATE LIMBS
/datum/action/innate/regenerate_limbs
	name = "Regenerate Limbs"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "slimeheal"
	button_icon = 'icons/mob/actions/actions_slime.dmi'
	background_icon_state = "bg_alien"
	overlay_icon_state = "bg_alien_border"

/datum/action/innate/regenerate_limbs/IsAvailable(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		return FALSE
	if(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
		return TRUE

/datum/action/innate/regenerate_limbs/Activate()
	var/mob/living/carbon/human/H = owner
	var/list/limbs_to_heal = H.get_missing_limbs()
	if(!length(limbs_to_heal))
		to_chat(H, span_notice("You feel intact enough as it is."))
		return
	to_chat(H, span_notice("You focus intently on your missing [length(limbs_to_heal) >= 2 ? "limbs" : "limb"]..."))
	if(H.blood_volume >= 40*length(limbs_to_heal)+BLOOD_VOLUME_OKAY)
		H.regenerate_limbs()
		H.blood_volume -= 40*length(limbs_to_heal)
		to_chat(H, span_notice("...and after a moment you finish reforming!"))
		return
	else if(H.blood_volume >= 40)//We can partially heal some limbs
		while(H.blood_volume >= BLOOD_VOLUME_OKAY+40)
			var/healed_limb = pick(limbs_to_heal)
			H.regenerate_limb(healed_limb)
			var/obj/item/bodypart/limb = H.get_bodypart(healed_limb)
			limb.update_disabled() // we toggle these
			limbs_to_heal -= healed_limb
			H.blood_volume -= 40
		to_chat(H, span_warning("...but there is not enough of you to fix everything! You must attain more mass to heal completely!"))
		return
	to_chat(H, span_warning("...but there is not enough of you to go around! You must attain more mass to heal!"))

/**
 * Toggle Death Signal simply adds and removes the trait required for slimepeople to transmit a GPS signal upon core ejection.
 */
/datum/action/innate/core_signal
	name = "Toggle Core Signal"
	check_flags = AB_CHECK_CONSCIOUS
	button_icon_state = "alter_form"
	button_icon = SLIME_ACTIONS_ICON_FILE
	background_icon_state = "bg_alien"
	/// Do you need to be a slime-person to use this ability?
	var/slime_restricted = TRUE

/datum/action/innate/core_signal/Activate()
	var/mob/living/carbon/human/slime = owner
	var/obj/item/organ/internal/brain/slime/core = slime.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(slime_restricted && !isoozeling(slime))
		return
	if(core.gps_active)
		to_chat(owner,span_notice("You tune out the electromagnetic signals from your core so they are ignored by GPS receivers upon it's rejection."))
		core.gps_active = FALSE
	else
		to_chat(owner, span_notice("You fine-tune the electromagnetic signals from your core to be picked up by GPS receivers upon it's rejection."))
		core.gps_active = TRUE
