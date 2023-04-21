///objects can only have one particle on them at a time, so we use these abstract effects to hold and display the effects. You know, so multiple particle effects can exist at once.
///also because some objects do not display particles due to how their visuals are built
/obj/effect/abstract/particle_holder
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE
	/// Holds info about how this particle emitter works
	/// See \code\__DEFINES\particles.dm
	var/particle_flags = NONE

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = /particles/smoke, particle_flags = NONE)
	. = ..()
	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	// We assert this isn't an /area

	src.particle_flags = particle_flags
	particles = new particle_path
	// /atom doesn't have vis_contents, /turf and /atom/movable do
	var/atom/movable/lie_about_areas = loc
	lie_about_areas.vis_contents += src
	if(!ismovable(loc))
		RegisterSignal(loc, COMSIG_PARENT_QDELETING, PROC_REF(immovable_deleted))

	if(particle_flags & PARTICLE_ATTACH_MOB)
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	on_move(loc, null, NORTH)

/obj/effect/abstract/particle_holder/Destroy(force)
	QDEL_NULL(particles)
	return ..()

/// Non movables don't delete contents on destroy, so we gotta do this
/obj/effect/abstract/particle_holder/proc/immovable_deleted(datum/source)
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

///Stores an index of particles and their instances for reusing : list(particle_type = list(INSTANCES BABEEYYYY))
GLOBAL_LIST_EMPTY(shared_particle_holders)

///Give a particle effect to an atom from a global list. Use this if you have a lot of particle holders on someones
///screen and client performance is a problem. This way it's only calculated x amount of times and you can replicate it without putting too much extra burden on clients
/proc/get_shared_particle_effect(atom/atom, obj/effect/abstract/particle_holder_shared/holder_type)
	var/list/effect_pool = GLOB.shared_particle_holders[holder_type]
	if(!effect_pool) //no particles yet so make them
		var/list/particles = list()
		for(var/i in 1 to initial(holder_type.pool_size))
			particles += new holder_type()

		GLOB.shared_particle_holders[holder_type] = particles
		effect_pool = particles

	var/obj/effect/abstract/particle_holder_shared/holder_instance = pick(effect_pool)
	holder_instance.apply_particles_to(atom)

///Many particle slow? Have one or two particle and copy paste everywhere. Similair to particle_holder but meant for having multiple vis_locs
///If using: make a subtype with a set particle and pool_size for the amount of instances you want to randomly pick from
/obj/effect/abstract/particle_holder_shared
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	vis_flags = VIS_INHERIT_PLANE

	///Amount of instances we can pick instances of us from
	var/pool_size = 1

///Apply the particle effect to x obj. Turfs are also fine ignore the typecasting HAHAHHAHAHAHAH i hate byond
/obj/effect/abstract/particle_holder_shared/proc/apply_particles_to(atom/movable/add_to)
	add_to.vis_contents += src

///Particle holder used for the lavaland lava turfs
/obj/effect/abstract/particle_holder_shared/lava
	particles = new /particles/lava ()
	pool_size = 1
