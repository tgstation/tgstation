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

	if(PLANE_TO_TRUE(loc.plane) == FLOOR_PLANE)
		vis_flags &= ~VIS_INHERIT_PLANE // don't yoink the floor plane. we'll just sit on game plane, it's fine

	// We nullspace ourselves because some objects use their contents (e.g. storage) and some items may drop everything in their contents on deconstruct.
	parent = loc
	loc = null

	// Mouse opacity can get set to opaque by some objects when placed into the object's contents (storage containers).
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	src.particle_flags = particle_flags
	particles = get_particle_effect(particle_path)
	// /atom doesn't have vis_contents, /turf and /atom/movable do
	var/atom/movable/lie_about_areas = parent
	lie_about_areas.vis_contents += src
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(parent_deleted))

	if(particle_flags & PARTICLE_ATTACH_MOB)
		RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	on_move(parent, null, NORTH)

/obj/effect/abstract/particle_holder/proc/get_particle_effect(particle_path)
	return new particle_path()

/obj/effect/abstract/particle_holder/Destroy(force)
	QDEL_NULL(particles)
	parent = null
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

/// Sets the particles position to the passed coordinates
/obj/effect/abstract/particle_holder/proc/set_particle_position(x = 0, y = 0, z = 0)
	particles.position = list(x, y, z)

/**
 * A subtype of particle holder that reuses the same particles to reduce client lag
 * when rendering certain atoms, usually found in large quantities and close together.
 * Since it reuses the same instances, modifying an instance of particles will affect all atoms
 * that show it, therefore procs like set_particle_position() shouldn't be used here.
 */
/obj/effect/abstract/particle_holder/cached
	///A static list meant to contain the availables instances of a particle path to use.
	var/static/list/particles_by_type
	/**
	 * The length of the pool of particles from which the chosen instance will be picked
	 * This provides an ever-so-lightly variety to the particles, so they don't all jarringly look EXACTLY the same
	 */
	var/max_particle_index = 4

/obj/effect/abstract/particle_holder/cached/Initialize(mapload, particle_path = /particles/smoke, particle_flags = NONE, max_particle_index)
	src.max_particle_index = max_particle_index
	return ..()

/obj/effect/abstract/particle_holder/cached/Destroy(force)
	particles = null
	return ..()

/obj/effect/abstract/particle_holder/cached/get_particle_effect(particle_path)
	LAZYINITLIST(particles_by_type)
	LAZYINITLIST(particles_by_type[particle_path])

	var/list/particles_list = particles_by_type[particle_path]
	var/index = rand(1, max_particle_index)
	var/particles/chosen
	if(length(particles_list) < index)
		chosen = new particle_path()
		particles_list += chosen
	else
		chosen = particles_list[index]

	return chosen

/obj/effect/abstract/particle_holder/cached/set_particle_position(x = 0, y = 0, z = 0)
	CRASH("[type] doesn't support set_particle_position()")
