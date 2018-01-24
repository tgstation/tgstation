#define RHYTHMFIELD_MOB_INDEX_OLD_KEYMOVE_DISABLE 1
#define RHYTHMFIELD_MOB_INDEX_CLICKCD_EFFECT 2
#define RHYTHMFIELD_MOB_INDEX_TOTAL 2

#define RHYTHMFIELD_COLOR_FLOOR_OSCILLATE 1
#define RHYTHMFIELD_COLOR_FLOOR_INCREMENT 2

/datum/proximity_monitor/advanced/rhythm
	name = "Chrono-Kinetic Pulse-Regulation Field"
	setup_field_turfs = TRUE
	setup_edge_turfs = TRUE
	requires_processing = TRUE
	field_shape = FIELD_SHAPE_RADIUS_SQUARE
	priority_process = TRUE
	var/tick_max = 1000000							//MUST BE LCM OF ALL OTHER TICK RATES! 20 ticks per second on processing subsystem, 10 means 0.5s by default. LARGER THE BETTER.
	var/tick_current = 0
	var/list/immune = list()
	var/list/staging = list()
	var/list/captured = list()

	//Staging stuff
	var/stage_active = FALSE
	var/stage_sound_file
	var/stage_beatmap_file
	var/stage_beatmap_position = 0
	var/stage_start_time = 0
	var/list/stage_beatmap_processed = list()

	//Dance floors
	var/tick_rate_color_floors = 5
	var/control_color_floors = TRUE				//:^)
	var/color_floor_mode = RHYTHMFIELD_COLOR_FLOOR_OSCILLATE
	var/color_floor_current = 0

	//MOB CONTROL
	var/tick_rate_simple_animal = 20
	var/tick_rate_player_movement = 10
	var/tick_rate_player_attack = 10
	var/control_mobs = TRUE
	var/control_mobs_click_delay = TRUE
	var/list/mob/controlled_mobs = list()	//mob = list(old-key_movement_disabled, clickcd effect applied)

	//THROW CONTROL
	var/tick_rate_thrown_objects = 10
	var/control_thrownthings = TRUE
	var/list/atom/movable/controlled_thrownthings = list()

	//PROJECTILE CONTROL
	var/tick_rate_projectiles = 10
	var/control_projectiles = TRUE
	var/list/obj/item/projectile/controlled_projectiles = list()

/datum/proximity_monitor/advanced/rhythm/Destroy()
	release_all()
	return ..()

/datum/proximity_monitor/advanced/rhythm/process()
	if(stage_active)
		stage_process()
		return
	if(++tick_current > tick_max)
		tick_current = 0
	tick_field()

////////////////////////////STAGING
/datum/proximity_monitor/advanced/rhythm/proc/stage_sound(new_sound)
	stage_sound_file = new_sound

/datum/proximity_monitor/advanced/rhythm/proc/stage_beatmap(new_beatmap)
	stage_beatmap_file = new_beatmap
	generate_beatmap()

/datum/proximity_monitor/advanced/rhythm/proc/generate_beatmap()
	var/list/lines = world.file2list(stage_beatmap_file)
	if(!length(lines))
		return
	for(var/i in 1 to lines.len)
		var/n = text2num(lines[i])
		if(isnull(n))
			return
		lines[i] = n * 10			//Seconds --> deciseconds
	stage_beatmap_processed = lines

/datum/proximity_monitor/advanced/rhythm/proc/begin_stage()
	stage_active = TRUE
	stage_beatmap_position = 1
	stage_start_time = world.time
	send_sound_to_mobs(stage_sound_file)

/datum/proximity_monitor/advanced/rhythm/proc/send_sound_to_mobs(sound_file)
	var/sound/sending = new
	sending.file = sound_file
	sending.priority = 235
	sending.channel = CHANNEL_RHYTHMFIELD
	sending.frequency = 1
	sending.wait = FALSE
	sending.repeat = FALSE
	sending.status = SOUND_STREAM
	sending.volume = 100
	for(var/i in controlled_mobs)
		var/mob/M = i
		SEND_SOUND(M, sending)

/datum/proximity_monitor/advanced/rhythm/proc/end_stage()
	stage_active = FALSE
	stop_field_sounds()

/datum/proximity_monitor/advanced/rhythm/proc/stop_field_sounds()
	var/sound/sending = new(null)
	sending.channel = CHANNEL_RHYTHMFIELD
	for(var/i in controlled_mobs)
		var/mob/M = i
		SEND_SOUND(M, sending)

/datum/proximity_monitor/advanced/rhythm/proc/stage_process()
	if(stage_beatmap_position < 1 || stage_beatmap_position > length(stage_beatmap_processed))
		end_stage()
		return
	if(world.time < stage_start_time + stage_beatmap_processed[stage_beatmap_position])
		return
	stage_beatmap_position++
	tick_field()

////////////////////////////

/datum/proximity_monitor/advanced/rhythm/proc/capture_atom(atom/movable/AM)
	if(captured[AM])
		return
	captured[AM] = TRUE
	if(isliving(AM))
		capture_mob(AM)
	else if(istype(AM, /obj/item/projectile))
		capture_projectile(AM)
	else if(AM.throwing)
		capture_thrownthing(AM)

/datum/proximity_monitor/advanced/rhythm/proc/release_atom(atom/movable/AM)
	captured -= AM
	release_mob(AM)
	release_projectile(AM)
	release_thrownthing(AM)

/datum/proximity_monitor/advanced/rhythm/proc/tick_field()
	tick_projectiles()
	tick_thrownthings()
	tick_mobs()
	tick_colorswitch_floors()

/datum/proximity_monitor/advanced/rhythm/proc/release_all()
	for(var/i in controlled_projectiles)
		release_projectile(i)
	for(var/i in controlled_thrownthings)
		release_thrownthing(i)
	for(var/i in controlled_mobs)
		release_mob(i)
	captured = list()

//COLORSWITCHING FLOOR HANDLING
/datum/proximity_monitor/advanced/rhythm/proc/tick_colorswitch_floors()
	if(tick_current % tick_rate_color_floors)
		return
	if(!control_color_floors)
		return
	if(color_floor_mode == RHYTHMFIELD_COLOR_FLOOR_INCREMENT)
		for(var/i in field_turfs)
			if(istype(i, /turf/open/floor/colorswitch))
				var/turf/open/floor/colorswitch/T = i
				T.increment()
	if(color_floor_mode == RHYTHMFIELD_COLOR_FLOOR_OSCILLATE)
		color_floor_current = !color_floor_current
		for(var/i in field_turfs)
			if(istype(i, /turf/open/floor/colorswitch))
				var/turf/open/floor/colorswitch/T = i
				T.current_color = color_floor_current + 1
				T.update_icon()

//MOB HANDLING
/datum/proximity_monitor/advanced/rhythm/proc/tick_mobs()
	for(var/i in controlled_mobs)
		tick_mob(i)

/datum/proximity_monitor/advanced/rhythm/proc/tick_mob(mob/M)
	if(!is_turf_in_field(get_turf(M), src))
		release_mob(M)
		return
	if(control_mobs_click_delay)
		tick_mob_clickdelay(M)
	tick_mob_movement(M)
	if(!(tick_current % tick_rate_simple_animal))
		if(isanimal(M) && !M.client)
			SSnpcpool.process_simple_animal(M)

/datum/proximity_monitor/advanced/rhythm/proc/tick_mob_clickdelay(mob/M)
	if(tick_current % tick_rate_player_attack)
		return
	if(control_mobs_click_delay)
		M.next_move = 0			//Forcefully allow attack/otherwise.

/datum/proximity_monitor/advanced/rhythm/proc/tick_mob_movement(mob/M)
	if(tick_current % tick_rate_player_movement)
		return
	if(M.client)
		M.movementKeyLoop(M.client)

/datum/proximity_monitor/advanced/rhythm/proc/capture_mob(mob/living/M)
	if(controlled_mobs[M])
		return
	controlled_mobs[M] = list(M.key_movement_disabled, null)
	M.key_movement_disabled = TRUE
	if(control_mobs_click_delay)
		controlled_mobs[M][RHYTHMFIELD_MOB_INDEX_CLICKCD_EFFECT] = M.apply_status_effect(/datum/status_effect/rhythmfield_halting)
	if(isanimal(M))
		var/mob/living/simple_animal/SA = M
		SA.pause_processing = TRUE

/datum/proximity_monitor/advanced/rhythm/proc/release_mob(mob/living/M)
	if(!controlled_mobs[M])
		return
	M.key_movement_disabled = controlled_mobs[M][RHYTHMFIELD_MOB_INDEX_OLD_KEYMOVE_DISABLE]
	if(control_mobs_click_delay)
		M.remove_status_effect(controlled_mobs[M][RHYTHMFIELD_MOB_INDEX_CLICKCD_EFFECT])
	controlled_mobs -= M
	if(isanimal(M))
		var/mob/living/simple_animal/SA = M
		SA.pause_processing = FALSE

//THROWN THING HANDLING
/datum/proximity_monitor/advanced/rhythm/proc/tick_thrownthings()
	if(tick_current % tick_rate_thrown_objects)
		return
	for(var/i in controlled_thrownthings)
		var/atom/movable/AM = i
		if(QDELETED(AM) || !AM.throwing)
			controlled_thrownthings -= i
			continue
		tick_thrownthing(i)

/datum/proximity_monitor/advanced/rhythm/proc/tick_thrownthing(atom/movable/AM)
	if(!AM.throwing)
		return FALSE
	if(!is_turf_in_field(get_turf(AM), src))
		release_thrownthing(AM)
		return
	var/datum/thrownthing/TT = AM.throwing
	TT.tile_move(1)
	return TRUE

/datum/proximity_monitor/advanced/rhythm/proc/capture_thrownthing(atom/movable/AM)
	if(AM in controlled_thrownthings)
		return
	if(!AM.throwing)
		return FALSE
	var/datum/thrownthing/TT = AM.throwing
	TT.paused = TRUE
	controlled_thrownthings += AM
	return TRUE

/datum/proximity_monitor/advanced/rhythm/proc/release_thrownthing(atom/movable/AM)
	if(!(AM in controlled_thrownthings))
		return
	if(!AM.throwing)
		return FALSE
	var/datum/thrownthing/TT = AM.throwing
	TT.paused = FALSE
	controlled_thrownthings -= AM
	return TRUE

//PROJECTILE HANDLING
/datum/proximity_monitor/advanced/rhythm/proc/tick_projectiles()
	if(tick_current % tick_rate_projectiles)
		return
	for(var/i in controlled_projectiles)
		var/obj/item/projectile/P = i
		if(QDELETED(P))
			controlled_projectiles -= i
			continue
		tick_projectile(i)

/datum/proximity_monitor/advanced/rhythm/proc/tick_projectile(obj/item/projectile/P)
	if(!is_turf_in_field(get_turf(P), src))
		release_projectile(P)
		return
	P.pixel_move(1)

/datum/proximity_monitor/advanced/rhythm/proc/capture_projectile(obj/item/projectile/P)
	if(P in controlled_projectiles)
		return
	P.pause()
	controlled_projectiles |= P

/datum/proximity_monitor/advanced/rhythm/proc/release_projectile(obj/item/projectile/P)
	if(!(P in controlled_projectiles))
		return
	controlled_projectiles -= P
		P.resume()

/datum/proximity_monitor/advanced/rhythm/auto_create_floor
	var/list/original_turfs = list()		//[z][x][y] = type
	var/list/converted = list()
	var/turf_a_type = /turf/open/floor/colorswitch/light/colour_cycle/rhythm/a
	var/turf_b_type = /turf/open/floor/colorswitch/light/colour_cycle/rhythm/b

/datum/proximity_monitor/advanced/rhythm/auto_create_floor/proc/convert_floor(turf/T)
	if(converted[T])
		return
	converted[T] = TRUE
	LAZYINITLIST(original_turfs["[T.z]"])
	LAZYINITLIST(original_turfs["[T.z]"]["[T.x]"])
	original_turfs["[T.z]"]["[T.x]"]["[T.y]"] = T.type
	if((!((T.x - 1) % 2) && !((T.y - 1) % 2)) || (!(T.x % 2) && !(T.y % 2)))
		T.ChangeTurf(turf_a_type)
	else
		T.ChangeTurf(turf_b_type)

/datum/proximity_monitor/advanced/rhythm/auto_create_floor/proc/reset_floor(turf/T)
	if(!converted[T])
		return
	converted -= T
	T.ChangeTurf(original_turfs["[T.z]"]["[T.x]"]["[T.y]"])
	original_turfs["[T.z]"]["[T.x]"] -= "[T.y]"

/datum/proximity_monitor/advanced/rhythm/auto_create_floor/proc/reset_all_floors()
	for(var/z in original_turfs)
		for(var/y in z)
			for(var/x in y)
				var/turf/T = locate(x, y, z)
				T.ChangeTurf(original_turfs[z][y][x])

/datum/proximity_monitor/advanced/rhythm/auto_create_floor/Destroy()
	reset_all_floors()
	return ..()

/datum/proximity_monitor/advanced/rhythm/auto_create_floor/setup_field_turf(turf/T)
	. = ..()
	if(isclosedturf(T))
		return
	convert_floor(T)

/datum/proximity_monitor/advanced/rhythm/auto_create_floor/cleanup_field_turf(turf/T)
	. = ..()
	reset_floor(T)

/datum/proximity_monitor/advanced/rhythm/field_turf_crossed(atom/movable/AM)
	capture_atom(AM)
