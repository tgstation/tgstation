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

#define HOLODECK_CD 25
#define HOLODECK_DMG_CD 500

/obj/machinery/computer/holodeck
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	icon_screen = "holocontrol"
	idle_power_usage = 10
	active_power_usage = 50

	var/area/holodeck/linked
	var/datum/map_template/holodeck/program //should these still be area vars after refactoring? what else can i use?
	var/datum/map_template/holodeck/last_program
	var/area/offline_program = /datum/map_template/holodeck/offline

	var/list/program_cache
	var/list/emag_programs

	// Splitting this up allows two holodecks of the same size
	// to use the same source patterns.  Y'know, if you want to.
	var/holodeck_type = /datum/map_template/holodeck	// locate(this) to get the target holodeck
	var/program_type = /datum/map_template/holodeck	// subtypes of this (but not this itself) are loadable programs
	//^ im pretty sure this will not work
	var/active = FALSE
	var/damaged = FALSE
	var/list/spawned = list()
	var/list/effects = list()
	var/current_cd = 0
	//use template.load(deploy_location, centered = TRUE) somehow
	//use get_turf(atom reference) and define a mapping helper on the wanted spot on every holodeck
	var/datum/map_template/holodeck/template
	var/turf/spawn_tile
	var/template_id

/obj/effect/mapping_helpers/holodeck_spawner
	icon_state = ""
	var/this

/obj/machinery/computer/holodeck/proc/get_spawn_tile(var/obj/effect/Spawn)
	return spawn_tile = get_turf(Spawn)

/obj/machinery/computer/holodeck/proc/get_template()//now i need to create template ids for all sims and match them with the program lists, however theyre done
	//if(template)//i think this is bad if we want to have more than one template loaded throughout the round
	//	return
	template = SSmapping.holodeck_templates[template_id]
	//if(!template)
	//	WARNING("Shelter template ([template_id]) not found!")
	//	qdel(src)

/obj/machinery/computer/holodeck/Destroy()
	to_chat(world,"DEBUG -- lmao youre fucked")

/obj/machinery/computer/holodeck/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/holodeck/LateInitialize()//from here linked is populated and the program list is generated. its also set to load the offline program
	var/obj/effect/holodeck_helper = locate(/obj/effect/mapping_helpers/holodeck_spawner)
	get_spawn_tile(holodeck_helper)
	if(ispath(holodeck_type, /area))
		linked = pop(get_areas(holodeck_type, FALSE))//maybe pop removes holodeck/rec_area?
	if(ispath(offline_program, /area))
		offline_program = pop(get_areas(offline_program), FALSE)
	// the following is necessary for power reasons
	if(!linked || !offline_program)
		log_world("No matching holodeck area found")
		qdel(src)
		return
	var/area/AS = get_area(src)
	if(istype(AS, /area/holodeck))
		log_mapping("Holodeck computer cannot be in a holodeck, This would cause circular power dependency.")
		qdel(src)
		return
	else
		linked.linked = src
		var/area/my_area = get_area(src)
		if(my_area)
			linked.power_usage = my_area.power_usage
		else
			linked.power_usage = new /list(AREA_USAGE_LEN)

	generate_program_list()
	load_program(offline_program, FALSE, FALSE)

/obj/machinery/computer/holodeck/Destroy()
	emergency_shutdown()
	if(linked)
		linked.linked = null
		linked.power_usage = new /list(AREA_USAGE_LEN)
	return ..()

/obj/machinery/computer/holodeck/power_change()
	. = ..()
	toggle_power(!machine_stat)

/obj/machinery/computer/holodeck/ui_interact(mob/user, datum/tgui/ui)//portable
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holodeck", name)//this creates the holodeck ui
		ui.open()

/obj/machinery/computer/holodeck/ui_data(mob/user)//In this proc you munges whatever complex data your `src_object`
//has into an associative list, which will then be sent to UI as a JSON string.
	var/list/data = list()

	data["default_programs"] = program_cache
	if(obj_flags & EMAGGED)
		data["emagged"] = TRUE
		data["emag_programs"] = emag_programs
	data["program"] = program
	data["can_toggle_safety"] = issilicon(user) || isAdminGhostAI(user)
//kinda portable
	return data

/obj/machinery/computer/holodeck/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("load_program")
			//var/program_to_load = text2path(params["type"])
			var/datum/map_template/holodeck/program_to_load = params
			if(!ispath(program_to_load))
				return FALSE
			var/valid = FALSE
			var/list/checked = program_cache.Copy()
			if(obj_flags & EMAGGED)
				checked |= emag_programs
			for(var/prog in checked)
				var/list/P = prog
				if(P["type"] == program_to_load)
					valid = TRUE
					break
			if(!valid)
				return FALSE
			//load the map_template that program_to_load represents
			//var/datum/map_template/shelter/template //template = SSmapping.holodeck_templates[template_id]
			//var/datum/map_template/shelter/template = SSmapping.holodeck_templates[program_to_load]
			//var/area/A = locate(program_to_load) in GLOB.sortedAreas
			if(program_to_load)
				var/id = initial(program_to_load.template_id)
				load_program(id)//do i only need to replace this? NO EASYNESS, ONLY PAIN
		if("safety")
			if((obj_flags & EMAGGED) && program)
				emergency_shutdown()
			nerf(obj_flags & EMAGGED)
			obj_flags ^= EMAGGED
			say("Safeties restored. Restarting...")


/obj/machinery/computer/holodeck/process()//will comment out when first testing, will have to port over
	if(damaged && prob(10))
		for(var/turf/T in linked)
			if(prob(5))
				do_sparks(2, 1, T)
				return

	if(!..() || !active)
		return

	if(!floorcheck())
		emergency_shutdown()
		damaged = TRUE
		for(var/mob/M in urange(10,src))
			M.show_message("The holodeck overloads!")

		for(var/turf/T in linked)
			if(prob(30))
				do_sparks(2, 1, T)
			SSexplosions.lowturf += T
			T.hotspot_expose(1000,500,1)

	if(!(obj_flags & EMAGGED))
		for(var/item in spawned)
			if(!(get_turf(item) in linked))
				derez(item, 0)
	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.tick()

	active_power_usage = 50 + spawned.len * 3 + effects.len * 5


/obj/machinery/computer/holodeck/emag_act(mob/user)//low priority
	if(obj_flags & EMAGGED)
		return
	if(!LAZYLEN(emag_programs))//porting dangerzone
		to_chat(user, "[src] does not seem to have a card swipe port. It must be an inferior model.")
		return
	playsound(src, "sparks", 75, TRUE)
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>You vastly increase projector power and override the safety and security protocols.</span>")
	say("Warning. Automatic shutoff and derezzing protocols have been corrupted. Please call Nanotrasen maintenance and do not use the simulator.")
	log_game("[key_name(user)] emagged the Holodeck Control Console")
	nerf(!(obj_flags & EMAGGED))

/obj/machinery/computer/holodeck/emp_act(severity)//low priority
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	emergency_shutdown()

/obj/machinery/computer/holodeck/ex_act(severity, target)//low priority
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/blob_act(obj/structure/blob/B)//low priority
	emergency_shutdown()
	return ..()
//FUCKING DO IT PUSSY
/obj/machinery/computer/holodeck/proc/generate_program_list()
	for(var/typekey in subtypesof(program_type))
		var/datum/map_template/holodeck/A = typekey
		var/list/info_this = list()
		info_this["name"] = initial(A.name)
		info_this["type"] = A.type//this doesnt like initial being used on it
		if(initial(A.restricted))
			LAZYADD(emag_programs, list(info_this))
		else
			LAZYADD(program_cache, list(info_this))

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = FALSE)//low priority
	if(active == toggleOn)
		return

	if(toggleOn)
		if(last_program && last_program != offline_program)
			addtimer(CALLBACK(src, .proc/load_program, last_program, TRUE), 25)
		active = TRUE
	else
		last_program = program
		load_program(offline_program, TRUE)
		active = FALSE

/obj/machinery/computer/holodeck/proc/emergency_shutdown()//low priority
	last_program = program
	load_program(offline_program, TRUE)
	active = FALSE

/obj/machinery/computer/holodeck/proc/floorcheck()//low priority
	for(var/turf/T in linked)
		if(!T.intact || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/computer/holodeck/proc/nerf(active)
	for(var/obj/item/I in spawned)
		I.damtype = active ? STAMINA : initial(I.damtype)
	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.safety(active)
/*
1. find turf to spawn on
2. holodeck_id.place?
*/
//FOR TESTING

/obj/machinery/computer/holodeck/proc/load_program(var/map_id, force = FALSE, add_delay = TRUE)//kyler, mainly replace this?
	//takes an area, finds what program that area corresponds to
	//if (1==2)
		///datum/map_template/holodeck/wildlifesim/load(get_turf(A))
	//template.load(deploy_location, centered = TRUE)

	if(!is_operational)
		template = offline_program
		force = TRUE

	if(program == template)//if the program is the same as the corresponding area
		return
	if(current_cd > world.time && !force)
		say("ERROR. Recalibrating projection apparatus.")
		return
	if(add_delay)
		current_cd = world.time + HOLODECK_CD
		if(damaged)
			current_cd += HOLODECK_DMG_CD
	active = (template != offline_program)
	use_power = active + IDLE_POWER_USE

	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.deactivate(src)

	for(var/item in spawned)
		derez(item, !force)

	//program = A
	// note nerfing does not yet work on guns, should
	// should also remove/limit/filter reagents?
	// this is an exercise left to others I'm afraid.  -Sayu

	//template = SSmapping.holodeck_templates[template_id]
	template = SSmapping.holodeck_templates[map_id]
	spawned = template.load(spawn_tile, centered = TRUE)//kyler, oh wait, is this call what actually SPAWNS that atoms? idk
	//linked is the argument in place of the copy_contents area/A parameter
	//map.load places templates on a TURF, copy_contents copies to an entire area

	//spawned = A.copy_contents_to(linked, 1, nerf_weapons = !(obj_flags & EMAGGED))
	//spawned
	for(var/obj/machinery/M in spawned)
		M.flags_1 |= NODECONSTRUCT_1
	for(var/obj/structure/S in spawned)
		S.flags_1 |= NODECONSTRUCT_1
	effects = list()

	//addtimer(CALLBACK(src, .proc/finish_spawn), 30)//kyler, maybe this is what actually spawns the atoms?

/obj/machinery/computer/holodeck/proc/finish_spawn()//kyler, this SHOULDNT be what actually spawns shit, copy_contents_2 is called in load_pro
	//kyler, finish_spwn allows effects to work (at least spawning ones). without it pet park will not spawn anything for example
	var/list/added = list()
	for(var/obj/effect/holodeck_effect/HE in spawned)
		effects += HE
		spawned -= HE
		var/atom/x = HE.activate(src)
		if(istype(x) || islist(x))
			spawned += x // holocarp are not forever
			added += x
	for(var/obj/machinery/M in added)
		M.flags_1 |= NODECONSTRUCT_1
	for(var/obj/structure/S in added)
		S.flags_1 |= NODECONSTRUCT_1

/obj/machinery/computer/holodeck/proc/derez(obj/O, silent = TRUE, forced = FALSE)
	// Emagging a machine creates an anomaly in the derez systems.
	if(O && (obj_flags & EMAGGED) && !machine_stat && !forced)
		if((ismob(O) || ismob(O.loc)) && prob(50))
			addtimer(CALLBACK(src, .proc/derez, O, silent), 50) // may last a disturbingly long time
			return

	spawned -= O
	if(!O)
		return
	var/turf/T = get_turf(O)
	for(var/atom/movable/AM in O) // these should be derezed if they were generated
		AM.forceMove(T)
		if(ismob(AM))
			silent = FALSE					// otherwise make sure they are dropped

	if(!silent)
		visible_message("<span class='notice'>[O] fades away!</span>")
	qdel(O)

#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
