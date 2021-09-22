///objects can only have one particle on them at a time, so we use these abstract effects to hold and display the effects. You know, so multiple particle effects can exist at once.
///also because some objects do not display particles due to how their visuals are built
/obj/effect/abstract/particle_holder
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	if(ismovable(loc))
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, .proc/on_move)
	RegisterSignal(loc, COMSIG_PARENT_QDELETING, .proc/on_qdel)
	reposition(loc)//we are now hooked to the thing we're trying to follow, we can move outside of it
	forceMove(loc.loc)
	particles = new particle_path

/obj/effect/abstract/particle_holder/Destroy(force)
	UnregisterSignal(loc)
	QDEL_NULL(particles)
	. = ..()

///signal called when parent is moved
/obj/effect/abstract/particle_holder/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER
	reposition(attached)

///signal called when parent is deleted
/obj/effect/abstract/particle_holder/proc/on_qdel(atom/attached, force)
	SIGNAL_HANDLER
	qdel(src)//our parent is gone and we need to be as well

///logic proc for particle holders, aka where they move.
///subtypes of particle holders can override this for particles that should always be turf level or do special things when repositioning.
///this base subtype has some logic for items, as the loc of items becomes mobs very often hiding the particles
/obj/effect/abstract/particle_holder/proc/reposition(atom/attached_to)
	if(isitem(attached_to) && ismob(attached_to.loc))
		forceMove(attached_to.loc.loc) //we need to go deeper!
		return
	forceMove(attached_to.loc)
