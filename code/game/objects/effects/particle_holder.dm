///objects can only have one particle on them at a time, so we use these abstract effects to hold and display the effects. You know, so multiple particle effects can exist at once.
///also because some objects do not display particles due to how their visuals are built
/obj/effect/abstract/particle_holder
	name = "particle holder"
	desc = "How are you reading this? Please make a bug report :)"
	appearance_flags = KEEP_APART|KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE //movable appearance_flags plus KEEP_APART and KEEP_TOGETHER
	vis_flags = VIS_INHERIT_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	/// Holds info about how this particle emitter works
	/// See \code\__DEFINES\particles.dm
	var/particle_flags = NONE

	var/atom/parent

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = /particles/smoke, particle_flags = NONE)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	// We nullspace ourselves because some objects use their contents (e.g. storage) and some items may drop everything in their contents on deconstruct.
	parent = loc
	loc = null

	// Mouse opacity can get set to opaque by some objects when placed into the object's contents (storage containers).
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	src.particle_flags = particle_flags
	particles = new particle_path()
	// /atom doesn't have vis_contents, /turf and /atom/movable do
	var/atom/movable/lie_about_areas = parent
	lie_about_areas.vis_contents += src
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(parent_deleted))

	if(particle_flags & PARTICLE_ATTACH_MOB)
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	on_move(parent, null, NORTH)

/obj/effect/abstract/particle_holder/Destroy(force)
	QDEL_NULL(particles)
	return ..()

/// Non movables don't delete contents on destroy, so we gotta do this
/obj/effect/abstract/particle_holder/proc/parent_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// signal called when a parent that's been hooked into this moves
/// does a variety of checks to ensure overrides work out properly
/obj/effect/abstract/particle_holder/proc/on_move(atom/movable/attached, atom/oldloc, direction)
	SIGNAL_HANDLER

	if(!(particle_flags & PARTICLE_ATTACH_MOB))
		return

	//remove old
	if(ismob(oldloc))
		var/mob/particle_mob = oldloc
		particle_mob.vis_contents -= src

	// If we're sitting in a mob, we want to emit from it too, for vibes and shit
	if(ismob(attached.loc))
		var/mob/particle_mob = attached.loc
		particle_mob.vis_contents += src

/// Sets the particles position to the passed coordinate list (X, Y, Z)
/// See [https://www.byond.com/docs/ref/#/{notes}/particles] for position documentation
/obj/effect/abstract/particle_holder/proc/set_particle_position(list/pos)
	particles.position = pos
