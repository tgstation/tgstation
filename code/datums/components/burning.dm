GLOBAL_DATUM_INIT(fire_overlay, /mutable_appearance, mutable_appearance('icons/effects/fire.dmi', "fire", appearance_flags = RESET_COLOR))

/**
 * Component representing an atom being on fire.
 * Should not be used on mobs, they use the fire stacks system.
 */
/datum/component/burning
	/// Fire overlay appearance we apply
	var/fire_overlay
	/// Particle holder for fire particles, if any
	var/obj/effect/abstract/particle_holder/particle_effect

/datum/component/burning/Initialize(fire_overlay, fire_particles)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/atom_parent = parent
	if(!atom_parent.uses_integrity)
		stack_trace("Tried to add /datum/component/burning to an atom ([atom_parent]) that does not use atom_integrity!")
		return COMPONENT_INCOMPATIBLE
	// only flammable atoms should have this component, but it's not really an error if we try to apply this to a non flammable one
	if(!(atom_parent.resistance_flags & FLAMMABLE) || (atom_parent.resistance_flags & FIRE_PROOF))
		qdel(src)
		return
	src.fire_overlay = fire_overlay
	if(fire_particles)
		particle_effect = new(atom_parent, fire_particles)
	atom_parent.resistance_flags |= ON_FIRE
	START_PROCESSING(SSfire_burning, src)

/datum/component/burning/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_EXTINGUISH, PROC_REF(on_extinguish))
	var/atom/atom_parent = parent
	atom_parent.update_appearance(UPDATE_ICON)

/datum/component/burning/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_ATOM_EXTINGUISH))

/datum/component/burning/Destroy(force, silent)
	STOP_PROCESSING(SSfire_burning, src)
	if(particle_effect)
		QDEL_NULL(particle_effect)
	var/atom/atom_parent = parent
	if(!QDELING(atom_parent) && (atom_parent.resistance_flags & ON_FIRE))
		atom_parent.resistance_flags &= ~ON_FIRE
		atom_parent.update_appearance(UPDATE_ICON)
	return ..()

/datum/component/burning/process(seconds_per_tick)
	var/atom/atom_parent = parent
	// Check if the parent somehow became fireproof
	if(atom_parent.resistance_flags & FIRE_PROOF)
		atom_parent.extinguish()
		return
	atom_parent.take_damage(10 * seconds_per_tick, BURN, FIRE, FALSE)

/// Maintains the burning overlay on the parent atom
/datum/component/burning/proc/on_update_overlays(atom/source, list/overlays)
	SIGNAL_HANDLER

	if(fire_overlay)
		overlays += fire_overlay

/// Deletes the component when the atom gets extinguished
/datum/component/burning/proc/on_extinguish(atom/source, list/overlays)
	SIGNAL_HANDLER

	qdel(src)
