GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/effects/fire.dmi', "fire", appearance_flags = RESET_COLOR))

/**
 * Component representing an atom being on fire.
 * Should not be used on mobs, they use the fire stacks status effects.
 * Can only be used on atoms that use the integrity system.
 */
/datum/component/burning
	/// Fire overlay appearance we apply
	var/fire_overlay
	/// Particle holder for fire particles, if any
	var/obj/effect/abstract/particle_holder/particle_effect

/datum/component/burning/Initialize(fire_overlay = GLOB.fire_overlay, fire_particles = /particles/smoke/burning)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	if(!atom_parent.uses_integrity)
		stack_trace("Tried to add /datum/component/burning to an atom ([atom_parent.type]) that does not use atom_integrity!")
		return COMPONENT_INCOMPATIBLE
	// only flammable atoms should have this component, but it's not really an error if we try to apply this to a non flammable one
	if(!(atom_parent.resistance_flags & FLAMMABLE) || (atom_parent.resistance_flags & FIRE_PROOF))
		qdel(src)
		return
	src.fire_overlay = fire_overlay
	if(fire_particles)
		// burning particles look pretty bad when they stack on mobs, so that behavior is not wanted for items
		particle_effect = new(atom_parent, fire_particles, isitem(atom_parent) ? NONE : PARTICLE_ATTACH_MOB)
	START_PROCESSING(SSburning, src)

/datum/component/burning/Destroy(force, silent)
	STOP_PROCESSING(SSburning, src)
	if(particle_effect)
		QDEL_NULL(particle_effect)
	return ..()

/datum/component/burning/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_EXTINGUISH, PROC_REF(on_extinguish))
	var/atom/atom_parent = parent
	atom_parent.resistance_flags |= ON_FIRE
	atom_parent.update_appearance()

/datum/component/burning/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_EXTINGUISH))
	var/atom/atom_parent = parent
	if(!QDELETED(atom_parent))
		atom_parent.resistance_flags &= ~ON_FIRE
		atom_parent.update_appearance()

/datum/component/burning/process(seconds_per_tick)
	var/atom/atom_parent = parent
	// Check if the parent somehow became fireproof
	if(atom_parent.resistance_flags & FIRE_PROOF)
		atom_parent.extinguish()
		return
	atom_parent.take_damage(10 * seconds_per_tick, BURN, FIRE, FALSE)

/// Alerts any examiners that the parent is on fire (even though it should be rather obvious)
/datum/component/burning/proc/on_examine(atom/source, mob/user, list/examine_list)
	SIGNAL_HANDLER

	examine_list += span_danger("[source.p_theyre(TRUE)] burning!")

/// Maintains the burning overlay on the parent atom
/datum/component/burning/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER

	//most likely means the component is being removed
	if(!(source.resistance_flags & ON_FIRE))
		return

	if(fire_overlay)
		overlays += fire_overlay

/// Deletes the component when the atom gets extinguished
/datum/component/burning/proc/on_extinguish(atom/source, list/overlays)
	SIGNAL_HANDLER

	qdel(src)
