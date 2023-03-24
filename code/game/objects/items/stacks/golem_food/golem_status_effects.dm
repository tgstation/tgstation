/// Abstract holder for golem status effects, you should never have more than one of these active
/datum/status_effect/golem
	id = "golem_status"
	status_type = STATUS_EFFECT_REFRESH
	duration = 30 SECONDS
	/// Icon state prefix for overlay to display on golem limbs
	var/overlay_state_prefix
	/// Maximum time to extend buff for
	var/max_duration = 5 MINUTES
	/// Overlays we have applied to our mob
	var/list/active_overlays = list()

/datum/status_effect/golem/on_apply()
	. = ..()
	if (owner.has_status_effect(/datum/status_effect/golem) )
		return FALSE
	if (!overlay_state_prefix || !iscarbon(owner))
		return TRUE
	var/mob/living/carbon/golem_owner = owner
	for (var/obj/item/bodypart/part in golem_owner.bodyparts)
		if (part.limb_id != SPECIES_GOLEM)
			continue
		var/datum/bodypart_overlay/simple/golem_overlay/overlay = new()
		overlay.add_to_bodypart(overlay_state_prefix, part)
		active_overlays += overlay
	golem_owner.update_body_parts()
	return TRUE

// Add 30 seconds up until we reach 5 minutess
/datum/status_effect/golem/refresh(effect)
	duration = min(duration + initial(duration), world.time + max_duration)

/datum/status_effect/golem/on_remove()
	QDEL_LIST(active_overlays)
	return ..()

/// Body part overlays applied by golem status effects
/datum/bodypart_overlay/simple/golem_overlay
	icon = 'icons/mob/species/golems.dmi'
	layers = ALL_EXTERNAL_OVERLAYS
	///The bodypart that the overlay is currently applied to
	var/datum/weakref/attached_bodypart

/datum/bodypart_overlay/simple/golem_overlay/proc/add_to_bodypart(prefix, obj/item/bodypart/part)
	icon_state = "[prefix]_[part.body_zone]"
	attached_bodypart = WEAKREF(part)
	part.add_bodypart_overlay(src)

/datum/bodypart_overlay/simple/golem_overlay/Destroy(force)
	var/obj/item/bodypart/referenced_bodypart = attached_bodypart.resolve()
	if(!referenced_bodypart)
		return ..()
	referenced_bodypart.remove_bodypart_overlay(src)
	if(referenced_bodypart.owner) //Keep in mind that the bodypart could have been severed from the owner by now
		referenced_bodypart.owner.update_body_parts()
	else
		referenced_bodypart.update_icon_dropped()
	return ..()

/// Freezes hunger for the duration
/datum/status_effect/golem/uranium
	overlay_state_prefix = "uranium"

/datum/status_effect/golem/uranium/on_apply()
	. = ..()
	if (!.)
		return FALSE
	ADD_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/golem_hunger)
	owner.remove_status_effect(/datum/status_effect/golem_statued) // Instant fix!
	return TRUE

/datum/status_effect/golem/uranium/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	return ..()

/// Magic immunity
/datum/status_effect/golem/silver
	overlay_state_prefix = "silver"

/datum/status_effect/golem/silver/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.add_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem/silver/on_remove()
	owner.remove_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return ..()

/// Heat immunity, turns heat damage into local power
/datum/status_effect/golem/plasma
	overlay_state_prefix = "plasma"

/// Makes you spaceproof
/datum/status_effect/golem/plasteel
	overlay_state_prefix = "iron"

/// Makes you reflect projectiles
/datum/status_effect/golem/gold
	overlay_state_prefix = "gold"

/// Makes you hard to see
/datum/status_effect/golem/diamond
	overlay_state_prefix = "diamond"

/// Makes you tougher
/datum/status_effect/golem/titanium
	overlay_state_prefix = "platinum"
