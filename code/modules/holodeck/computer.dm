/*
	Holodeck Update

	The on-station holodeck area is of type [holodeck_type].
	All subtypes of [program_type] are loaded into the program cache or emag programs list.
	If init_program is null, a random program will be loaded on startup.
	If you don't wish this, set it to the offline program or another of your choosing.

	You can use this to add holodecks with minimal code:
	1) Define new areas for the holodeck programs
	2) Map them
	3) Create a new control console that uses those areas

	Non-mapped areas should be skipped but you should probably comment them out anyway.
	The base of program_type will always be ignored; only subtypes will be loaded.
*/

/obj/machinery/computer/holodeck
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	icon_screen = "holocontrol"
	idle_power_usage = 10
	active_power_usage = 50
	var/area/holodeck/linked
	var/area/holodeck/program
	var/area/holodeck/last_program
	var/area/offline_program = /area/holodeck/rec_center/offline

	var/list/program_cache = list()
	var/list/emag_programs = list()

	// Splitting this up allows two holodecks of the same size
	// to use the same source patterns.  Y'know, if you want to.
	var/holodeck_type = /area/holodeck/rec_center	// locate(this) to get the target holodeck
	var/program_type = /area/holodeck/rec_center	// subtypes of this (but not this itself) are loadable programs

	// set this if you want it to start with some particular program.
	var/init_program = null
	// or this to get anything
	var/random_program = 0

	var/active = 0
	var/damaged = 0
	var/list/spawned = list()
	var/list/effects = list()
	var/last_change = 0

/obj/machinery/computer/holodeck/New()

	if(ispath(holodeck_type,/area))
		linked = locate(holodeck_type)
	if(ispath(offline_program,/area))
		offline_program = locate(offline_program)
	// the following is necessary for power reasons
	var/area/AS = get_area(src)
	if(istype(AS,/area/holodeck))
		log_world("### MAPPING ERROR")
		log_world("Holodeck computer cannot be in a holodeck.")
		log_world("This would cause circular power dependency.")
		qdel(src)  // todo handle constructed computers
		return	//l-lewd...
	else
		linked.linked = src // todo detect multiple/constructed computers
	..()

/obj/machinery/computer/holodeck/Initialize(mapload)
	. = mapload	//late-initialize, area_copy need turfs to have air
	if(!mapload)
		..()
		program_cache = list()
		emag_programs = list()
		for(var/typekey in subtypesof(program_type))
			var/area/holodeck/A = locate(typekey)
			if(!A || A == offline_program) continue
			if(A.contents.len == 0) continue // not loaded
			if(A.restricted)
				emag_programs += A
			else
				program_cache += A
			if(typekey == init_program)
				load_program(A,force=1)
		if(random_program && program_cache.len && init_program == null)
			load_program(pick(program_cache),force=1)
		else if(!program)
			load_program(offline_program)

/obj/machinery/computer/holodeck/power_change()
	..()
	toggle_power(!stat)

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = 0)
	if(active == toggleOn) return

	if(toggleOn)
		if(last_program && last_program != offline_program)
			load_program(last_program, delay = 1)
		active = 1
	else
		last_program = program
		load_program(offline_program,force=1)
		active = 0

/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	last_program = program
	load_program(offline_program,1)
	active = 0

/obj/machinery/computer/holodeck/process()
	if(damaged)
		if(prob(10))
			for(var/turf/T in linked)
				if(prob(5))
					var/datum/effect_system/spark_spread/s = new
					s.set_up(2, 1, T)
					s.start()
					return

	if(!..() || !active)
		return

	if(!floorcheck())
		emergency_shutdown()
		damaged = 1
		for(var/mob/M in urange(10,src))
			M.show_message("The holodeck overloads!")

		for(var/turf/T in linked)
			if(prob(30))
				var/datum/effect_system/spark_spread/s = new
				s.set_up(2, 1, T)
				s.start()
			T.ex_act(3)
			T.hotspot_expose(1000,500,1)

	if(!emagged)
		for(var/item in spawned)
			if(!(get_turf(item) in linked))
				derez(item, 0)
	for(var/obj/effect/holodeck_effect/HE in effects)
		HE.tick()

	active_power_usage = 50 + spawned.len * 3 + effects.len * 5

/obj/machinery/computer/holodeck/proc/floorcheck()
	for(var/turf/T in linked)
		if(!T.intact || isspaceturf(T))
			return 0
	return 1

/obj/machinery/computer/holodeck/Topic(href, list/href_list)
	if(..())
		return
	usr.set_machine(src)
	add_fingerprint(usr)
	if(href_list["loadarea"])
		var/areapath = text2path(href_list["loadarea"])
		if(!ispath(areapath, /area/holodeck))
			return
		var/area/holodeck/area = locate(areapath)
		if(!istype(area))
			return
		if(area == offline_program || (area in program_cache) || (emagged && (area in emag_programs)))
			load_program(area)
	else if("safety" in href_list)
		var/safe = text2num(href_list["safety"])
		emagged = !safe
		if(!program)
			return
		if(safe && (program in emag_programs))
			emergency_shutdown()
		nerf(safe)
	updateUsrDialog()

/obj/machinery/computer/holodeck/proc/nerf(active)
	for(var/obj/item/I in spawned)
		I.damtype = (active? STAMINA : initial(I.damtype) )
	for(var/obj/effect/holodeck_effect/HE in effects)
		HE.safety(active)

/obj/machinery/computer/holodeck/emag_act(mob/user as mob)
	if(!emagged)
		if(!emag_programs.len)
			to_chat(user, "[src] does not seem to have a card swipe port.  It must be an inferior model.")
			return
		playsound(loc, 'sound/effects/sparks4.ogg', 75, 1)
		emagged = 1
		to_chat(user, "<span class='warning'>You vastly increase projector power and override the safety and security protocols.</span>")
		to_chat(user, "Warning.  Automatic shutoff and derezing protocols have been corrupted.  Please call Nanotrasen maintenance and do not use the simulator.")
		log_game("[key_name(user)] emagged the Holodeck Control Console")
		updateUsrDialog()
		nerf(!emagged)

/obj/machinery/computer/holodeck/Destroy()
	emergency_shutdown()
	linked.linked = null
	return ..()

/obj/machinery/computer/holodeck/emp_act(severity)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/ex_act(severity, target)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()