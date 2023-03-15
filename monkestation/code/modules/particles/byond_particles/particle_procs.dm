///ATOM PROCS

/*
These are for byonds native particle system as they are limited to a single object instance
this creates dummy objects to store the particles in useful for objects that have multiple
particles like bonfires.
*/

/atom
	var/obj/effect/abstract/particle_holder/master_holder

/// priority is in descending order so 10 is the highest 1 is the lowest
/atom/proc/add_emitter(obj/emitter/updatee, particle_key, priority = 10, var/lifespan = null, burst_mode = FALSE, force = FALSE)

	priority = clamp(priority, 1, 10)

	if(!particle_key)
		CRASH("add_emitter called without a key ref.")

	if(!src.loc)
		CRASH("add_emitter called on a turf without a loc, avoid this!.")

	if(!master_holder)
		master_holder = new(src)
	var/obj/emitter/current_emitter = master_holder.emitters[particle_key]

	var/obj/emitter/new_emitter = new updatee

	if(current_emitter)
		if(!force && current_emitter.type == new_emitter.type)
			return
		current_emitter.vis_locs -= src
		qdel(current_emitter)

	new_emitter.layer += (priority / 100)
	new_emitter.vis_locs |= src
	master_holder.emitters[particle_key] = new_emitter
	if(lifespan || burst_mode)
		if(burst_mode)
			remove_emitter(particle_key, TRUE)
		else
			addtimer(CALLBACK(src, .proc/remove_emitter, particle_key), lifespan)

/atom/proc/remove_emitter(particle_key, burst_mode = FALSE)
	if(!particle_key)
		CRASH("remove_emitter called without a key ref.")

	if(!master_holder || !master_holder.emitters[particle_key])
		return
	var/obj/emitter/removed_emitter = master_holder.emitters[particle_key]
	if(!burst_mode)
		removed_emitter.particles.spawning = 0 //this way it gracefully dies out instead
	addtimer(CALLBACK(src, .proc/handle_deletion, particle_key), removed_emitter.particles.lifespan)

/atom/proc/handle_deletion(particle_key)
	var/obj/emitter/removed_emitter = master_holder.emitters[particle_key]

	if(!removed_emitter)
		return
	removed_emitter.vis_locs -= src

	master_holder.emitters -= particle_key
	qdel(removed_emitter)

///checks if it has the specific particle key
/atom/proc/has_particle(particle_key)
	if(!master_holder || !master_holder.emitters.len) /// does the holder exist, or does the holder list hold nothing? Return False
		return FALSE

	if(!master_holder.emitters[particle_key]) /// does it have a particle with the correct key?  if not return
		return FALSE

	return TRUE

///checks for a matching particle type from a given particle key
/atom/proc/matching_particle(particle_key, obj/emitter/particle_type)
	if(!master_holder || !master_holder.emitters.len) /// does the holder exist, or does the holder list hold nothing? Return False
		return FALSE

	if(!master_holder.emitters[particle_key]) /// does it have a particle with the correct key?  if not return
		return FALSE

	if(!istype(master_holder.emitters[particle_key], particle_type))
		return FALSE

	return TRUE

///Returns the particle with the correct key
/atom/proc/return_particle(particle_key)
	if(!particle_key) ///this should never happen but just incase
		return

	if(!master_holder || !master_holder.emitters.len) /// does the holder exist, or does the holder list hold nothing? Return False
		return FALSE

	if(!master_holder.emitters[particle_key]) /// does it have a particle with the correct key?  if not return
		return FALSE

	return master_holder.emitters[particle_key]
