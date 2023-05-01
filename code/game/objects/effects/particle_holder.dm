///objects can only have one particle on them at a time, so we use these abstract effects to hold and display the effects. You know, so multiple particle effects can exist at once.
///also because some objects do not display particles due to how their visuals are built
/obj/effect/abstract/particle_holder
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	layer = ABOVE_ALL_MOB_LAYER
	plane = PARTICLE_PLANE
	/// Holds info about how this particle emitter works
	/// See \code\__DEFINES\particles.dm
	var/particle_flags = NONE

/obj/effect/abstract/particle_holder/Initialize(mapload, particle_path = /particles/smoke, particle_flags = NONE)
	. = ..()

	particles = new particle_path
	src.particle_flags = particle_flags

/obj/effect/abstract/particle_holder/Destroy(force)
	QDEL_NULL(particles)
	return ..()

///Particle holders that are unique per objects, for simple or complicated particle effects that dont appear with 100 instances at once on your screen
/obj/effect/abstract/particle_holder/solo

/obj/effect/abstract/particle_holder/solo/Initialize(mapload, particle_path = /particles/smoke)
	. = ..()

	if(!loc)
		stack_trace("particle holder was created with no loc!")
		return INITIALIZE_HINT_QDEL
	// We assert this isn't an /area
	// /atom doesn't have vis_contents, /turf and /atom/movable do
	var/atom/movable/lie_about_areas = loc
	lie_about_areas.vis_contents += src
	if(!ismovable(loc))
		RegisterSignal(loc, COMSIG_PARENT_QDELETING, PROC_REF(immovable_deleted))

	if(particle_flags & PARTICLE_ATTACH_MOB)
		RegisterSignal(loc, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	on_move(loc, null, NORTH)

/// Non movables don't delete contents on destroy, so we gotta do this
/obj/effect/abstract/particle_holder/solo/proc/immovable_deleted(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/// signal called when a parent that's been hooked into this moves
/// does a variety of checks to ensure overrides work out properly
/obj/effect/abstract/particle_holder/solo/proc/on_move(atom/movable/attached, atom/oldloc, direction)
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
/obj/effect/abstract/particle_holder/solo/proc/set_particle_position(list/pos)
	particles.position = pos

///Stores an index of particles and their instances for reusing : list(particle_type = list(INSTANCES BABEEYYYY))
GLOBAL_LIST_EMPTY(shared_particle_holders)

///Give a particle effect to an atom from a global list. Use this if you have a lot of particle holders on someones
///screen and client performance is a problem. This way it's only calculated x amount of times and you can replicate it without putting too much extra burden on clients
///particle_flags : holder behaviour. holder_type: defines whether we are shared or use our own. pool_size: if shared, how many do we share? (only first pool_size counts)
/proc/apply_particles_to(atom/particlee, particle_type, particle_flags = NONE, holder_type = PARTICLES_SINGULAR, pool_size)
	switch(holder_type) //yes this definitely asuredly needs to be a switch because uhhhhhhhhh looks nice
		if(PARTICLES_SINGULAR)
			return new /obj/effect/abstract/particle_holder/solo (particlee, particle_type, particle_flags)

		if(PARTICLES_SHARED)
			var/list/effect_pool = GLOB.shared_particle_holders["[particle_type][pool_size]"]
			if(!LAZYLEN(effect_pool)) //no particles yet so make a pool of instances to pick from
				effect_pool = list()
				for(var/i in 1 to pool_size)
					effect_pool += new /obj/effect/abstract/particle_holder/shared(null, particle_type)

				GLOB.shared_particle_holders["[particle_type][pool_size]"] = effect_pool

			var/obj/effect/abstract/particle_holder/shared/holder_instance = pick(effect_pool)
			holder_instance.apply_particles_to(particlee)
			return holder_instance

///Many particles slow? Have one or two particle and copy paste it everywhere.
/obj/effect/abstract/particle_holder/shared

///Apply the particle effect to x obj. Turfs are also fine ignore the typecasting :)
/obj/effect/abstract/particle_holder/shared/proc/apply_particles_to(atom/movable/add_to)
	add_to.vis_contents += src

