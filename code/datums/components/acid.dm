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
	/// Used exclusively for melting turfs. TODO: Move integrity to the atom level so that this can be dealt with there.
	var/parent_integrity = 30
	/// How far the acid melting of turfs has progressed
	var/stage = 0
	/// Acid overlay appearance we apply
	var/acid_overlay
	/// Boolean for if we ignore mobs when applying acid to turf contents
	var/turf_acid_ignores_mobs = FALSE
	/// The ambient sound of acid eating away at the parent [/atom].
	var/datum/looping_sound/acid/sizzle
	/// Particle holder for acid particles (sick). Still utilized over shared holders because they're movable-only
	var/obj/effect/abstract/particle_holder/particle_effect
	/// Particle type we're using for cleaning up our shared holder
	var/particle_type
	/// The proc used to handle the parent [/atom] when processing. TODO: Unify damage and resistance flags so that this doesn't need to exist!
	var/datum/callback/process_effect

/datum/component/acid/Initialize(acid_power = ACID_POWER_MELT_TURF, acid_volume = 50, acid_overlay = GLOB.acid_overlay, acid_particles = /particles/acid, turf_acid_ignores_mobs = FALSE)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	// The parent object cannot have acid. Not incompatible, but should not really happen.
	var/atom/atom_parent = parent
	if(atom_parent.resistance_flags & UNACIDABLE)
		qdel(src)
		return

	//Not incompatible, but pointless
	if((acid_power <= 0) || (acid_volume <= 0))
		qdel(src)
		stack_trace("Tried to add /datum/component/acid to an atom ([atom_parent.type]) with insufficient acid power ([acid_power]) or acid volume ([acid_volume]).")
		return

	if(isliving(parent))
		src.max_volume = MOB_ACID_VOLUME_MAX
		src.process_effect = CALLBACK(src, PROC_REF(process_mob), parent)
	else if(isturf(parent))
		src.turf_acid_ignores_mobs = turf_acid_ignores_mobs
		src.max_volume = TURF_ACID_VOLUME_MAX
		src.process_effect = CALLBACK(src, PROC_REF(process_turf), parent)
	//if we failed all other checks, we must be an /atom/movable that uses integrity
	else if(atom_parent.uses_integrity)
		src.max_volume = MOVABLE_ACID_VOLUME_MAX
		src.process_effect = CALLBACK(src, PROC_REF(process_movable), parent)
	//or not...
	else
		stack_trace("Tried to add /datum/component/acid to an atom ([atom_parent.type]) which does not use atom_integrity!")
		return COMPONENT_INCOMPATIBLE

	src.acid_power = acid_power
	set_volume(acid_volume)
	src.acid_overlay = acid_overlay

	sizzle = new(atom_parent, TRUE)
	if(acid_particles)
		if (ismovable(parent))
			var/atom/movable/movable_parent = parent
			movable_parent.add_shared_particles(acid_particles, "[acid_particles]_[isitem(parent)]", isitem(parent) ? NONE : PARTICLE_ATTACH_MOB)
			particle_type = acid_particles
		else
			// acid particles look pretty bad when they stack on mobs, so that behavior is not wanted for items
			particle_effect = new(atom_parent, acid_particles, isitem(atom_parent) ? NONE : PARTICLE_ATTACH_MOB)
	START_PROCESSING(SSacid, src)

/datum/component/acid/Destroy(force)
	STOP_PROCESSING(SSacid, src)
	if(sizzle)
		QDEL_NULL(sizzle)
	if(particle_effect)
		QDEL_NULL(particle_effect)
	if (ismovable(parent) && particle_type)
		var/atom/movable/movable_parent = parent
		movable_parent.remove_shared_particles("[particle_type]_[isitem(parent)]")
	process_effect = null
	return ..()

/datum/component/acid/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_EXPOSE_REAGENT, PROC_REF(on_expose_reagent))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	if(isturf(parent))
		RegisterSignal(parent, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	var/atom/atom_parent = parent
	atom_parent.update_appearance()

/datum/component/acid/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_EXAMINE,
		COMSIG_ATOM_EXPOSE_REAGENT,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_COMPONENT_CLEAN_ACT,
	))
	if(isturf(parent))
		UnregisterSignal(parent, COMSIG_ATOM_ENTERED)
	var/atom/atom_parent = parent
	if(!QDELETED(atom_parent))
		atom_parent.update_appearance()

/// Averages corrosive power and sums volume.
/datum/component/acid/InheritComponent(datum/component/new_comp, i_am_original, acid_power, acid_volume)
	if(!i_am_original)
		return
	acid_power = ((src.acid_power * src.acid_volume) + (acid_power * acid_volume)) / (src.acid_volume + acid_volume)
	set_volume(src.acid_volume + acid_volume)

/// Sets the acid volume to a new value. Limits the acid volume by the amount allowed to exist on the parent atom.
/datum/component/acid/proc/set_volume(new_volume)
	acid_volume = clamp(new_volume, 0, max_volume)
	if(!acid_volume)
		qdel(src)

/// Handles the slow corrosion of the parent [/atom].
/datum/component/acid/process(seconds_per_tick)
	// If we somehow got unacidable, we need to bail out
	var/atom/parent_atom = parent
	if(parent_atom.resistance_flags & UNACIDABLE)
		qdel(src)
		return
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
	if(target.resistance_flags & ACID_PROOF)
		return
	target.acid_act(acid_power, acid_volume * seconds_per_tick)

/// Handles processing on a [/turf].
/datum/component/acid/proc/process_turf(turf/target_turf, seconds_per_tick)
	var/acid_used = min(acid_volume * 0.05, 20) * seconds_per_tick
	var/applied_targets = 0
	for(var/atom/movable/target_movable as anything in target_turf)
		// Don't apply acid to things under the turf
		if(target_turf.underfloor_accessibility < UNDERFLOOR_INTERACTABLE && HAS_TRAIT(target_movable, TRAIT_T_RAY_VISIBLE))
			continue
		// Ignore mobs if turf_acid_ignores_mobs is TRUE
		if(turf_acid_ignores_mobs && ismob(target_movable))
			continue
		// Apply the acid
		if(target_movable.acid_act(acid_power, acid_used))
			applied_targets++

	if(applied_targets)
		set_volume(acid_volume - (acid_used * applied_targets))

	if(target_turf.resistance_flags & ACID_PROOF)
		return

	// Snowflake code for handling acid melting walls.
	// We really should consider making turfs use atom_integrity, but for now this is just for acids.

	//Strong walls will never get melted
	if(target_turf.get_explosive_block() >= 2)
		return
	//Reinforced floors never get melted
	if(istype(target_turf, /turf/open/floor/engine))
		return
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

	examine_list += span_danger("[source.p_Theyre()] covered in a corrosive liquid!")

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

/// Handles searing the hand of anyone who tries to touch parent without protection.
/datum/component/acid/proc/on_attack_hand(atom/source, mob/living/carbon/user)
	SIGNAL_HANDLER

	if(!iscarbon(user) || user.can_touch_acid(source, acid_power, acid_volume))
		return NONE

	var/obj/item/bodypart/affecting = user.get_active_hand()
	//Should not happen!
	if(!affecting)
		return NONE

	affecting.receive_damage(burn = 5)
	to_chat(user, span_userdanger("The acid on \the [source] burns your hand!"))
	INVOKE_ASYNC(user, TYPE_PROC_REF(/mob, emote), "scream")
	playsound(source, SFX_SEAR, 50, TRUE)
	user.update_damage_overlays()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/// Handles searing the feet of whoever walks over this without protection. Only active if the parent is a turf.
/datum/component/acid/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(turf_acid_ignores_mobs)
		return
	if(!isliving(arrived))
		return
	var/mob/living/crosser = arrived
	if(crosser.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		return
	if(crosser.move_intent == MOVE_INTENT_WALK)
		return
	if(prob(60))
		return

	var/acid_used = min(acid_volume * 0.05, 20)
	if(!crosser.acid_act(acid_power, acid_used, FEET))
		return
	playsound(crosser, SFX_SEAR, 50, TRUE)
	to_chat(crosser, span_userdanger("The acid on the [parent] burns you!"))
	set_volume(max(acid_volume - acid_used, 10))
