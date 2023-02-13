///objects can only have one particle on them at a time, so we use these abstract effects to hold and display the effects. You know, so multiple particle effects can exist at once.
///also because some objects do not display particles due to how their visuals are built
/obj/effect/abstract/particle_holder
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	///typepath of the last location we're in, if it's different when moved then we need to update vis contents
	var/last_attached_location_type
	///the main item we're attached to at the moment, particle holders hold particles for something
	var/datum/weakref/weak_attached
	///besides the item we're also sometimes attached to other stuff! (items held emitting particles on a mob)
	var/datum/weakref/weak_additional

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = /particles/smoke)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	if(ismovable(loc))
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(loc, COMSIG_PARENT_QDELETING, PROC_REF(on_qdel))
	weak_attached = WEAKREF(loc)
	particles = new particle_path
	update_visual_contents(loc)

/obj/effect/abstract/particle_holder/Destroy(force)
	var/atom/movable/attached = weak_attached.resolve()
	var/atom/movable/additional_attached
	if(weak_additional)
		additional_attached = weak_additional.resolve()
	if(attached)
		attached.vis_contents -= src
		UnregisterSignal(loc, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	if(additional_attached)
		additional_attached.vis_contents -= src
	QDEL_NULL(particles)
	return ..()

///signal called when parent is moved
/obj/effect/abstract/particle_holder/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	if(attached.loc.type != last_attached_location_type)
		update_visual_contents(attached)

///signal called when parent is deleted
/obj/effect/abstract/particle_holder/proc/on_qdel(atom/movable/attached, force)
	SIGNAL_HANDLER
	qdel(src)//our parent is gone and we need to be as well

///logic proc for particle holders, aka where they move.
///subtypes of particle holders can override this for particles that should always be turf level or do special things when repositioning.
///this base subtype has some logic for items, as the loc of items becomes mobs very often hiding the particles
/obj/effect/abstract/particle_holder/proc/update_visual_contents(atom/movable/attached_to)
	//remove old
	if(weak_additional)
		var/atom/movable/resolved_location = weak_additional.resolve()
		if(resolved_location)
			resolved_location.vis_contents -= src
	//add to new
	if(isitem(attached_to) && ismob(attached_to.loc)) //special case we want to also be emitting from the mob
		var/mob/particle_mob = attached_to.loc
		last_attached_location_type = attached_to.loc
		weak_additional = WEAKREF(particle_mob)
		particle_mob.vis_contents += src
	//readd to ourselves
	attached_to.vis_contents |= src
