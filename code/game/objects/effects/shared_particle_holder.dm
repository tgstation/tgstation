#define SHARED_PARTICLE_HOLDER_INDEX 1
#define SHARED_PARTICLE_USER_NUM_INDEX 2
// Assoc list of particle type/key -> list(particle holder, number of particle users)
GLOBAL_LIST_EMPTY(shared_particles)

//A more abstract version of particle holder not bound to a specific object
/obj/effect/abstract/shared_particle_holder
	name = "shared particle holder"
	desc = "How are you reading this? Please make a bug report :)"
	appearance_flags = KEEP_APART|KEEP_TOGETHER|TILE_BOUND|PIXEL_SCALE|LONG_GLIDE
	vis_flags = VIS_INHERIT_PLANE
	layer = ABOVE_ALL_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	/// Holds info about how this particle emitter works
	/// See \code\__DEFINES\particles.dm
	var/particle_flags = NONE

/obj/effect/abstract/shared_particle_holder/Initialize(mapload, particle_path = /particles/smoke, particle_flags = NONE)
	. = ..()
	// Shouldn't exist outside of nullspace
	loc = null
	src.particle_flags = particle_flags
	particles = new particle_path()

/obj/effect/abstract/shared_particle_holder/Destroy(force)
	QDEL_NULL(particles)
	return ..()

/atom/movable/proc/add_shared_particles(particle_type, custom_key = null, particle_flags = NONE)
	var/particle_key = custom_key || "[particle_type]"
	if (GLOB.shared_particles[particle_key])
		if (GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX] in vis_contents)
			return
		vis_contents += GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX]
		GLOB.shared_particles[particle_key][SHARED_PARTICLE_USER_NUM_INDEX] += 1
		return GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX]

	GLOB.shared_particles[particle_key] = list(new /obj/effect/abstract/shared_particle_holder(null, particle_type, particle_flags), 1)
	vis_contents += GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX]
	return GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX]

/atom/movable/proc/remove_shared_particles(particle_key, delete_on_empty = TRUE)
	if (!particle_key)
		return

	if (ispath(particle_key))
		particle_key = "[particle_key]"

	if (!GLOB.shared_particles[particle_key])
		return

	if (!(GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX] in vis_contents))
		return

	vis_contents -= GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX]
	GLOB.shared_particles[particle_key][SHARED_PARTICLE_USER_NUM_INDEX] -= 1

	if (delete_on_empty && !GLOB.shared_particles[particle_key][SHARED_PARTICLE_USER_NUM_INDEX])
		QDEL_NULL(GLOB.shared_particles[particle_key][SHARED_PARTICLE_HOLDER_INDEX])
		GLOB.shared_particles -= particle_key

#undef SHARED_PARTICLE_HOLDER_INDEX
#undef SHARED_PARTICLE_USER_NUM_INDEX
