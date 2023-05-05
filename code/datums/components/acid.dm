GLOBAL_DATUM_INIT(acid_overlay, /mutable_appearance, mutable_appearance('icons/effects/acid.dmi', "default"))

/**
 * Component representing acid applied to an object.
 * Must be attached to an atom.
 * Processes, repeatedly damaging whatever it is attached to.
 * If the parent atom is a turf it applies acid to the contents of the turf.
 * If not being applied to a mob or turf, the atom must use the integrity system.
 */
/datum/component/acid
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// The strength of the acid on the parent [/atom].
	var/acid_power
	/// The volume of acid on the parent [/atom].
	var/acid_volume
	/// The maximum volume of acid on the parent [/atom].
	var/max_volume = INFINITY
	/// Acid overlay appearance we apply
	var/acid_overlay
	/// The ambiant sound of acid eating away at the parent [/atom].
	var/datum/looping_sound/acid/sizzle
	/// Used exclusively for melting turfs. TODO: Move integrity to the atom level so that this can be dealt with there.
	var/parent_integrity = 30
	/// How far the acid melting of turfs has progressed
	var/stage = 0
	/// The proc used to handle the parent [/atom] when processing. TODO: Unify damage and resistance flags so that this doesn't need to exist!
	var/datum/callback/process_effect

/datum/component/acid/Initialize(acid_power = ACID_POWER_MELT_TURF, acid_volume = 50, acid_overlay = GLOB.acid_overlay)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	//not incompatible, but pointless
	var/atom/atom_parent = parent
	if((acid_power) <= 0 || (acid_volume <= 0))
		stack_trace("Acid component added to an atom ([atom_parent.type]) with insufficient acid power ([acid_power]) or acid volume ([acid_volume]).")
		qdel(src)
		return


	if(isliving(parent))
		max_volume = MOB_ACID_VOLUME_MAX
		process_effect = CALLBACK(src, PROC_REF(process_mob), parent)
	else if(isturf(parent))
		max_volume = TURF_ACID_VOLUME_MAX
		process_effect = CALLBACK(src, PROC_REF(process_turf), parent)
	//if we failed all other checks, we must be an /atom/movable that uses integrity
	else if(atom_parent.uses_integrity)
		// The parent object cannot have acid. Not incompatible, but should not really happen.
		if(atom_parent.resistance_flags & UNACIDABLE)
			qdel(src)
			return

		max_volume = MOVABLE_ACID_VOLUME_MAX
		process_effect = CALLBACK(src, PROC_REF(process_movable), parent)
	//or not...
	else
		stack_trace("Tried to add /datum/component/acid to an atom ([atom_parent.type]) which does not use atom_integrity!")
		return COMPONENT_INCOMPATIBLE

	src.acid_power = acid_power
	set_volume(acid_volume)
	src.acid_overlay = acid_overlay

	sizzle = new(parent, TRUE)
	START_PROCESSING(SSacid, src)

/datum/component/acid/Destroy(force, silent)
	STOP_PROCESSING(SSacid, src)
	if(sizzle)
		QDEL_NULL(sizzle)
	if(process_effect)
		QDEL_NULL(process_effect)
	return ..()

/datum/component/acid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(on_expose_reagent))
	if(isturf(parent))
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	var/atom/atom_parent = parent
	atom_parent.update_appearance()

/datum/component/acid/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_COMPONENT_CLEAN_ACT,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_EXPOSE_REAGENT))
	if(isturf(parent))
		UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	var/atom/atom_parent = parent
	if(!QDELETED(atom_parent))
		atom_parent.update_appearance()

/// Averages corrosive power and sums volume.
/datum/component/acid/InheritComponent(datum/component/new_comp, i_am_original, acid_power, acid_volume)
	acid_power = ((src.acid_power * src.acid_volume) + (acid_power * acid_volume)) / (src.acid_volume + acid_volume)
	set_volume(src.acid_volume + acid_volume)

/// Sets the acid volume to a new value. Limits the acid volume by the amount allowed to exist on the parent atom.
/datum/component/acid/proc/set_volume(new_volume)
	acid_volume = clamp(new_volume, 0, max_volume)
	if(!acid_volume)
		qdel(src)

/// Handles the slow corrosion of the parent [/atom].
/datum/component/acid/process(seconds_per_tick)
	process_effect?.InvokeAsync(seconds_per_tick)
	if(QDELING(src)) //The process effect deals damage, and on turfs diminishes the acid volume, potentially destroying the component. Let's not destroy it twice.
		return
	set_volume(acid_volume - (ACID_DECAY_BASE + (ACID_DECAY_SCALING*round(sqrt(acid_volume)))) * seconds_per_tick)

/// Handles processing on an [/atom/movable] (that uses atom_integrity).
/datum/component/acid/proc/process_movable(atom/movable/target, seconds_per_tick)
	if(target.resistance_flags & ACID_PROOF)
		return
	target.take_damage(min(1 + round(sqrt(acid_power * acid_volume)*0.3), MOVABLE_ACID_DAMAGE_MAX) * seconds_per_tick, BURN, ACID, 0)

/// Handles processing on a [/mob/living].
/datum/component/acid/proc/process_mob(mob/living/target, seconds_per_tick)
	target.acid_act(acid_power, acid_volume * seconds_per_tick)

/// Handles processing on a [/turf].
/datum/component/acid/proc/process_turf(turf/target_turf, seconds_per_tick)
	var/acid_used = min(acid_volume * 0.05, 20) * seconds_per_tick
	var/applied_targets = 0
	for(var/atom/movable/target_movable as anything in target_turf)
		if(target_movable.acid_act(acid_power, acid_used))
			applied_targets++

	if(applied_targets)
		set_volume(acid_volume - (acid_used * applied_targets))

	// Snowflake code for handling acid melting walls. TODO: Move integrity handling to the atom level so this can be desnowflaked.
	if(acid_power < ACID_POWER_MELT_TURF)
		return

	parent_integrity -= seconds_per_tick
	if(parent_integrity <= 0)
		target_turf.visible_message(span_warning("[target_turf] collapses under its own weight into a puddle of goop and undigested debris!"))
		target_turf.acid_melt()
	else if(parent_integrity <= 4 && stage <= 3)
		target_turf.visible_message(span_warning("[target_turf] begins to crumble under the acid!"))
		stage = 4
	else if(parent_integrity <= 8 && stage <= 2)
		target_turf.visible_message(span_warning("[target_turf] is struggling to withstand the acid!"))
		stage = 3
	else if(parent_integrity <= 16 && stage <= 1)
		target_turf.visible_message(span_warning("[target_turf] is being melted by the acid!"))
		stage = 2
	else if(parent_integrity <= 24 && stage == 0)
		target_turf.visible_message(span_warning("[target_turf] is holding up against the acid!"))
		stage = 1

/// Used to maintain the acid overlay on the parent [/atom].
/datum/component/acid/proc/on_update_overlays(atom/parent_atom, list/overlays)
	SIGNAL_HANDLER

	if(acid_overlay)
		overlays += acid_overlay

/// Alerts any examiners to the acid on the parent atom.
/datum/component/acid/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_danger("[source.p_theyre(TRUE)] covered in a corrosive liquid!")

/// Makes it possible to clean acid off of objects.
/datum/component/acid/proc/on_clean(atom/source, clean_types)
	SIGNAL_HANDLER

	if(!(clean_types & CLEAN_TYPE_ACID))
		return NONE
	qdel(src)
	return COMPONENT_CLEANED

/// Handles water diluting the acid on the object.
/datum/component/acid/proc/on_expose_reagent(atom/parent_atom, datum/reagent/exposing_reagent, reac_volume)
	SIGNAL_HANDLER

	if(!istype(exposing_reagent, /datum/reagent/water))
		return NONE

	acid_power /= (acid_volume / (acid_volume + reac_volume))
	set_volume(acid_volume + reac_volume)
	return NONE

/// Handles searing the hand of anyone who tries to touch this without protection.
/datum/component/acid/proc/on_attack_hand(atom/parent_atom, mob/living/carbon/user)
	SIGNAL_HANDLER

	if(!istype(user))
		return NONE
	if((parent_atom == user) || (parent_atom.loc == user))
		return NONE // So people can take their own clothes off.
	if((acid_power * acid_volume) < ACID_LEVEL_HANDBURN)
		return NONE
	if(user.gloves?.resistance_flags & (UNACIDABLE|ACID_PROOF))
		return NONE

	var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	if(!affecting?.receive_damage(0, 5))
		return NONE

	to_chat(user, span_warning("The acid on \the [parent_atom] burns your hand!"))
	playsound(parent_atom, 'sound/weapons/sear.ogg', 50, TRUE)
	user.update_damage_overlays()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Handles searing the feet of whoever walks over this without protection. Only active if the parent is a turf.
/datum/component/acid/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!isliving(arrived))
		return
	var/mob/living/crosser = arrived
	if(crosser.movement_type & FLYING)
		return
	if(crosser.m_intent == MOVE_INTENT_WALK)
		return
	if(prob(60))
		return

	var/acid_used = min(acid_volume * 0.05, 20)
	if(crosser.acid_act(acid_power, acid_used, FEET))
		playsound(crosser, 'sound/weapons/sear.ogg', 50, TRUE)
		to_chat(crosser, span_userdanger("The acid on the [parent] burns you!"))
		set_volume(max(acid_volume - acid_used, 10))
