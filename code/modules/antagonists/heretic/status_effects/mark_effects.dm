/datum/status_effect/eldritch
	id = "heretic_mark"
	duration = 15 SECONDS
	status_type = STATUS_EFFECT_REPLACE
	alert_type = null
	on_remove_on_mob_delete = TRUE
	///underlay used to indicate that someone is marked
	var/mutable_appearance/marked_underlay
	/// icon file for the underlay
	var/effect_icon = 'icons/effects/eldritch.dmi'
	/// icon state for the underlay
	var/effect_icon_state = ""

/datum/status_effect/eldritch/on_creation(mob/living/new_owner, ...)
	marked_underlay = mutable_appearance(effect_icon, effect_icon_state, BELOW_MOB_LAYER)
	return ..()

/datum/status_effect/eldritch/Destroy()
	QDEL_NULL(marked_underlay)
	return ..()

/datum/status_effect/eldritch/on_apply()
	if(owner.mob_size >= MOB_SIZE_HUMAN)
		RegisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(update_owner_underlay))
		owner.update_icon(UPDATE_OVERLAYS)
		return TRUE
	return FALSE

/datum/status_effect/eldritch/on_remove()
	UnregisterSignal(owner, COMSIG_ATOM_UPDATE_OVERLAYS)
	owner.update_icon(UPDATE_OVERLAYS)
	return ..()

/**
 * Signal proc for [COMSIG_ATOM_UPDATE_OVERLAYS].
 *
 * Adds the generated mark overlay to the afflicted.
 */
/datum/status_effect/eldritch/proc/update_owner_underlay(atom/source, list/overlays)
	SIGNAL_HANDLER

	overlays += marked_underlay

/**
 * Called when the mark is activated by the heretic.
 */
/datum/status_effect/eldritch/proc/on_effect()
	SHOULD_CALL_PARENT(TRUE)

	playsound(owner, 'sound/magic/repulse.ogg', 75, TRUE)
	qdel(src) //what happens when this is procced.

//Each mark has diffrent effects when it is destroyed that combine with the mansus grasp effect.

// MARK OF FLESH

/datum/status_effect/eldritch/flesh
	effect_icon_state = "emark1"

/datum/status_effect/eldritch/flesh/on_effect()
	if(ishuman(owner))
		var/mob/living/carbon/human/human_owner = owner
		var/obj/item/bodypart/bodypart = pick(human_owner.bodyparts)
		var/datum/wound/slash/severe/crit_wound = new()
		crit_wound.apply_wound(bodypart)

	return ..()

// MARK OF ASH

/datum/status_effect/eldritch/ash
	effect_icon_state = "emark2"
	/// Dictates how much stamina and burn damage the mark will cause on trigger.
	var/repetitions = 1

/datum/status_effect/eldritch/ash/on_creation(mob/living/new_owner, repetition = 5)
	. = ..()
	src.repetitions = max(1, repetition)

/datum/status_effect/eldritch/ash/on_effect()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.adjustStaminaLoss(6 * repetitions) // first one = 30 stam
		carbon_owner.adjustFireLoss(3 * repetitions) // first one = 15 burn
		for(var/mob/living/carbon/victim in shuffle(range(1, carbon_owner)))
			if(IS_HERETIC(victim) || victim == carbon_owner)
				continue
			victim.apply_status_effect(type, repetitions - 1)
			break

	return ..()

// MARK OF RUST

/datum/status_effect/eldritch/rust
	effect_icon_state = "emark3"

/datum/status_effect/eldritch/rust/on_effect()
	if(iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		var/static/list/organs_to_damage = list(
			ORGAN_SLOT_BRAIN,
			ORGAN_SLOT_EARS,
			ORGAN_SLOT_EYES,
			ORGAN_SLOT_LIVER,
			ORGAN_SLOT_LUNGS,
			ORGAN_SLOT_STOMACH,
			ORGAN_SLOT_HEART,
		)

		// Roughly 75% of their organs will take a bit of damage
		for(var/organ_slot in organs_to_damage)
			if(prob(75))
				carbon_owner.adjustOrganLoss(organ_slot, 20)

		// And roughly 75% of their items will take a smack, too
		for(var/obj/item/thing in carbon_owner.get_all_gear())
			if(!QDELETED(thing) && prob(75))
				thing.take_damage(100)

	return ..()

// MARK OF VOID

/datum/status_effect/eldritch/void
	effect_icon_state = "emark4"

/datum/status_effect/eldritch/void/on_effect()
	owner.apply_status_effect(/datum/status_effect/void_chill/major)
	owner.adjust_silence(10 SECONDS)
	return ..()

// MARK OF BLADES

/datum/status_effect/eldritch/blade
	effect_icon_state = "emark5"
	/// If set, the owner of the status effect will not be able to leave this area.
	var/area/locked_to

/datum/status_effect/eldritch/blade/Destroy()
	locked_to = null
	return ..()

/datum/status_effect/eldritch/blade/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOVABLE_PRE_THROW, PROC_REF(on_pre_throw))
	RegisterSignal(owner, COMSIG_MOVABLE_TELEPORTED, PROC_REF(on_teleport))
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

/datum/status_effect/eldritch/blade/on_remove()
	UnregisterSignal(owner, list(
		COMSIG_MOVABLE_PRE_THROW,
		COMSIG_MOVABLE_TELEPORTED,
		COMSIG_MOVABLE_MOVED,
	))

	return ..()

/// Checks if the movement from moving_from to going_to leaves our [var/locked_to] area. Returns TRUE if so.
/datum/status_effect/eldritch/blade/proc/is_escaping_locked_area(atom/moving_from, atom/going_to)
	if(!locked_to)
		return FALSE

	// If moving_from isn't in our locked area, it means they've
	// somehow completely escaped, so we'll opt not to act on them.
	if(get_area(moving_from) != locked_to)
		return FALSE

	// If going_to is in our locked area,
	// they're just moving within the area like normal.
	if(get_area(going_to) == locked_to)
		return FALSE

	return TRUE

/// Signal proc for [COMSIG_MOVABLE_PRE_THROW] that prevents people from escaping our locked area via throw.
/datum/status_effect/eldritch/blade/proc/on_pre_throw(mob/living/source, list/throw_args)
	SIGNAL_HANDLER

	var/atom/throw_dest = throw_args[1]
	if(!is_escaping_locked_area(source, throw_dest))
		return

	var/mob/thrower = throw_args[4]
	if(istype(thrower))
		to_chat(thrower, span_hypnophrase("An otherworldly force prevents you from throwing [source] out of [get_area_name(locked_to)]!"))

	to_chat(source, span_hypnophrase("An otherworldly force prevents you from being thrown out of [get_area_name(locked_to)]!"))

	return COMPONENT_CANCEL_THROW

/// Signal proc for [COMSIG_MOVABLE_TELEPORTED] that blocks any teleports from our locked area.
/datum/status_effect/eldritch/blade/proc/on_teleport(mob/living/source, atom/destination, channel)
	SIGNAL_HANDLER

	if(!is_escaping_locked_area(source, destination))
		return

	to_chat(source, span_hypnophrase("An otherworldly force prevents your escape from [get_area_name(locked_to)]!"))

	source.Stun(1 SECONDS)
	return COMPONENT_BLOCK_TELEPORT

/// Signal proc for [COMSIG_MOVABLE_MOVED] that blocks any movement out of our locked area
/datum/status_effect/eldritch/blade/proc/on_move(mob/living/source, turf/old_loc, movement_dir, forced)
	SIGNAL_HANDLER

	// Let's not mess with heretics dragging a potential victim.
	if(ismob(source.pulledby) && IS_HERETIC(source.pulledby))
		return

	// If the movement's forced, just let it happen regardless.
	if(forced || !is_escaping_locked_area(old_loc, source))
		return

	to_chat(source, span_hypnophrase("An otherworldly force prevents your escape from [get_area_name(locked_to)]!"))

	var/turf/further_behind_old_loc = get_edge_target_turf(old_loc, REVERSE_DIR(movement_dir))

	source.Stun(1 SECONDS)
	source.throw_at(further_behind_old_loc, 3, 1, gentle = TRUE) // Keeping this gentle so they don't smack into the heretic max speed
