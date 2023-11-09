
/obj/effect/abstract/particle
	name = ""
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	icon = 'monkestation/code/modules/trading/icons/particles.dmi'
	icon_state = "none"

/datum/component/particle_spewer
	var/atom/source_object
	///the duration we last
	var/duration = 0
	///the spawn intervals in game ticks
	var/spawn_interval = 1
	///particles still in the process of animating
	var/list/living_particles = list()
	///list of particles that finished (added only as a failsafe)
	var/list/dead_particles = list()
	///x offset for source_object
	var/offset_x = 0
	///y offset for source_object
	var/offset_y = 0	
	///the dmi location of the particle
	var/icon_file = 'monkestation/code/modules/trading/icons/particles.dmi'
	///the icon_state given to the objects
	var/particle_state = "none"
	///current process count
	var/count = 0
	///equipped offset ie hats go to 32 if set to 32 will also reset to height changes
	var/equipped_offset = 32
	///per burst spawn amount
	var/burst_amount = 1
	///the actual lifetime of this component before we die [ 0 = infinite]
	var/lifetime = 0


/datum/component/particle_spewer/Initialize(duration = 0, spawn_interval = 1, offset_x = 0, offset_y = 0, icon_file = 'monkestation/code/modules/trading/icons/particles.dmi', particle_state = "none", equipped_offset = 32, burst_amount = 1, lifetime = 0)
	. = ..()
	src.icon_file = icon_file
	src.particle_state = particle_state
	src.offset_x = offset_x + rand(-8, 8)
	src.offset_y = offset_y + rand(-4, 4)
	src.spawn_interval = spawn_interval
	src.duration = duration
	src.equipped_offset = equipped_offset
	src.burst_amount = burst_amount
	src.lifetime = lifetime
	source_object = parent

	START_PROCESSING(SSfastprocess, src)

	if(lifetime)
		addtimer(CALLBACK(src, PROC_REF(kill_it_with_fire)), lifetime)

/datum/component/particle_spewer/Destroy(force, silent)
	. = ..()
	STOP_PROCESSING(SSfastprocess, src)
	for(var/atom/listed_atom as anything in living_particles + dead_particles)
		qdel(listed_atom)
	living_particles = null
	dead_particles = null
	source_object = null

/datum/component/particle_spewer/process(seconds_per_tick)
	if(spawn_interval != 1)
		count++
		if(count < spawn_interval)
			return
	
	for(var/i = 0 to burst_amount)
		//create and assign particle its stuff
		var/obj/effect/abstract/particle/spawned = new(source_object.loc)
		spawned.pixel_x = offset_x
		spawned.pixel_y = offset_y 
		spawned.icon = icon_file  
		spawned.icon_state = particle_state

		living_particles |= spawned

		animate_particle(spawned)

///this is the proc that gets overridden when we create new particle spewers that control its movements
//example is animating upwards over duration and deleting
/datum/component/particle_spewer/proc/animate_particle(obj/effect/abstract/particle/spawned)
	animate(spawned, alpha = 75, time = duration)
	animate(spawned, pixel_y = offset_y + 64, time = duration)
	addtimer(CALLBACK(src, PROC_REF(delete_particle), spawned), duration)

/datum/component/particle_spewer/proc/delete_particle(obj/effect/abstract/particle/spawned)
	living_particles -= spawned
	qdel(spawned)

/datum/component/particle_spewer/proc/kill_it_with_fire()
	qdel(src)

/obj/item/debug_particle_holder/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/particle_spewer, 2 SECONDS)
