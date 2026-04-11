/// Sends a signal to the owner material whenever something enters its objects' turf and steps onto said object
/datum/component/material_turf_tracking
	dupe_mode = COMPONENT_DUPE_ALLOWED
	/// Material we're linked to
	var/datum/material/owner_material = null
	/// Does our parent require the target to be elevated for us to trigger?
	var/requires_elevation = FALSE

	/// Typecache of things we should ignore
	var/static/list/interaction_blacklist = typecacheof(list(
		/obj/docking_port,
		/obj/effect/abstract,
		/obj/effect/atmos_shield,
		/obj/effect/collapse,
		/obj/effect/constructing_effect,
		/obj/effect/dummy/phased_mob,
		/obj/effect/ebeam,
		/obj/effect/fishing_float,
		/obj/effect/hotspot,
		/obj/effect/landmark,
		/obj/effect/light_emitter/tendril,
		/obj/effect/mapping_helpers,
		/obj/effect/particle_effect/ion_trails,
		/obj/effect/particle_effect/sparks,
		/obj/effect/portal,
		/obj/effect/projectile,
		/obj/effect/spectre_of_resurrection,
		/obj/effect/temp_visual,
		/obj/effect/wisp,
		/obj/energy_ball,
		/obj/narsie,
		/obj/singularity,
	))

	/// Typecache of objects which we only consider "touched" when they elevate the mob, or the mob is buckled to them
	/// Easy way to keep track of snowflake behavior like flipped tables
	var/static/list/elevation_interactions = typecacheof(list(
		/obj/structure/platform,
		/obj/structure/table,
		/obj/structure/rack,
		/obj/structure/bed,
		/obj/structure/closet/crate,
		/obj/structure/reagent_dispensers,
		/obj/structure/altar,
	))

/datum/component/material_turf_tracking/Initialize(datum/material/owner_material)
	if (!isopenturf(parent) && !isobj(parent))
		return COMPONENT_INCOMPATIBLE
	src.owner_material = owner_material
	if (is_type_in_typecache(parent, elevation_interactions))
		requires_elevation = TRUE

/datum/component/material_turf_tracking/Destroy(force)
	owner_material = null
	return ..()

/datum/component/material_turf_tracking/RegisterWithParent()
	var/turf/target_turf = parent
	if (ismovable(parent))
		var/atom/movable/as_movable = parent
		RegisterSignal(as_movable, COMSIG_ATOM_ENTERING, PROC_REF(on_source_entering))
		RegisterSignal(as_movable, COMSIG_ATOM_EXITING, PROC_REF(on_source_exiting))
		target_turf = as_movable.loc

	if (!isopenturf(target_turf))
		return

	if (!requires_elevation)
		RegisterSignal(target_turf, SIGNAL_ADDTRAIT(TRAIT_ELEVATED_TURF), PROC_REF(on_turf_lost))
		RegisterSignal(target_turf, SIGNAL_REMOVETRAIT(TRAIT_ELEVATED_TURF), PROC_REF(on_turf_gained))
		if (HAS_TRAIT(target_turf, TRAIT_ELEVATED_TURF))
			return

	// Not tracking initializations or existing objects as this would allow you to TP someone from plating by placing a tile underneath
	RegisterSignal(target_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(target_turf, COMSIG_TURF_MOVABLE_THROW_LANDED, PROC_REF(on_entered)) // Need this as shoves are 1 tile throws, and COMSIG_ATOM_ENTERED runs before the throw ends
	RegisterSignal(target_turf, COMSIG_ATOM_EXITED, PROC_REF(on_exited))

/datum/component/material_turf_tracking/UnregisterFromParent()
	. = ..()
	if (isturf(parent))
		on_source_exiting(parent)
		return

	var/atom/movable/as_movable = parent
	UnregisterSignal(as_movable, list(COMSIG_ATOM_ENTERING, COMSIG_ATOM_EXITING))
	on_source_exiting(as_movable.loc)

/datum/component/material_turf_tracking/proc/on_source_entering(atom/movable/source, atom/entering, atom/old_loc)
	SIGNAL_HANDLER

	if (!isopenturf(entering))
		return

	if (!requires_elevation)
		RegisterSignal(entering, SIGNAL_ADDTRAIT(TRAIT_ELEVATED_TURF), PROC_REF(on_turf_lost))
		RegisterSignal(entering, SIGNAL_REMOVETRAIT(TRAIT_ELEVATED_TURF), PROC_REF(on_turf_gained))
		if (HAS_TRAIT(entering, TRAIT_ELEVATED_TURF))
			return
	on_turf_gained(entering)

/datum/component/material_turf_tracking/proc/on_source_exiting(atom/movable/source, atom/exiting)
	SIGNAL_HANDLER

	if (!isturf(exiting))
		return

	UnregisterSignal(exiting, list(SIGNAL_ADDTRAIT(TRAIT_ELEVATED_TURF), SIGNAL_REMOVETRAIT(TRAIT_ELEVATED_TURF)))
	on_turf_lost(exiting)

/datum/component/material_turf_tracking/proc/on_turf_gained(turf/source)
	SIGNAL_HANDLER

	RegisterSignal(source, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	RegisterSignal(source, COMSIG_TURF_MOVABLE_THROW_LANDED, PROC_REF(on_entered))
	RegisterSignal(source, COMSIG_ATOM_EXITED, PROC_REF(on_exited))
	for (var/atom/movable/thing in source)
		on_entered(source, thing)

/datum/component/material_turf_tracking/proc/on_turf_lost(turf/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_TURF_MOVABLE_THROW_LANDED, COMSIG_ATOM_EXITED))
	for (var/atom/movable/thing in source)
		UnregisterSignal(thing, list(SIGNAL_ADDTRAIT(TRAIT_MOB_ELEVATED), COMSIG_MOVETYPE_FLAG_DISABLED))

/datum/component/material_turf_tracking/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if (arrived.throwing || arrived.invisibility >= INVISIBILITY_ABSTRACT || arrived == parent)
		return

	if (is_type_in_typecache(arrived, interaction_blacklist))
		return

	if (!isliving(arrived) && requires_elevation)
		return

	// Its floating but it may touch down
	if (arrived.movement_type & MOVETYPES_NOT_TOUCHING_GROUND)
		RegisterSignal(arrived, COMSIG_MOVETYPE_FLAG_DISABLED, PROC_REF(on_move_flag_disabled))
		return

	if (!isliving(arrived))
		trigger_effect(arrived)
		return

	if (requires_elevation)
		// We want to know when they touch down so we can interact with them
		RegisterSignal(arrived, SIGNAL_ADDTRAIT(TRAIT_MOB_ELEVATED), PROC_REF(on_mob_elevated))
		// The trait is kept even if the mob is buckled which is weird but plays into our hand here
		if (!HAS_TRAIT(arrived, TRAIT_MOB_ELEVATED))
			return

	trigger_effect(arrived)

/datum/component/material_turf_tracking/proc/on_exited(datum/source, atom/movable/gone)
	SIGNAL_HANDLER

	UnregisterSignal(gone, list(SIGNAL_ADDTRAIT(TRAIT_MOB_ELEVATED), COMSIG_MOVETYPE_FLAG_DISABLED))

/datum/component/material_turf_tracking/proc/trigger_effect(atom/movable/arrived)
	if (!isliving(arrived))
		SEND_SIGNAL(owner_material, COMSIG_MATERIAL_EFFECT_STEP, parent, arrived, null, null, FALSE)
		return

	var/mob/living/victim = arrived
	var/skin_contact = FEET
	if (victim.body_position == LYING_DOWN)
		skin_contact = CHEST|GROIN|LEGS|FEET|ARMS|HANDS

	for (var/obj/item/worn_item in victim.get_equipped_items(INCLUDE_ABSTRACT))
		skin_contact &= ~worn_item.body_parts_covered
		if (!skin_contact)
			break

	SEND_SIGNAL(owner_material, COMSIG_MATERIAL_EFFECT_STEP, parent, arrived, null, pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG), !!skin_contact)

/datum/component/material_turf_tracking/proc/on_mob_elevated(mob/living/source, trait)
	if (source.throwing || source.invisibility >= INVISIBILITY_ABSTRACT || (source.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if (is_type_in_typecache(source, interaction_blacklist))
		return

	trigger_effect(source)

/datum/component/material_turf_tracking/proc/on_move_flag_disabled(atom/movable/source, flag, old_state)
	if (source.throwing || source.invisibility >= INVISIBILITY_ABSTRACT || (source.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return

	if (is_type_in_typecache(source, interaction_blacklist))
		return

	if (requires_elevation)
		if (!isliving(source))
			return
		RegisterSignal(source, SIGNAL_ADDTRAIT(TRAIT_MOB_ELEVATED), PROC_REF(on_mob_elevated))
		if (!HAS_TRAIT(source, TRAIT_MOB_ELEVATED))
			return

	trigger_effect(source)
