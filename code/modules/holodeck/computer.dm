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
	var/area/holodeck/loaded
	var/program = "holodeck_offline"//should these still be area vars after refactoring? what else can i use?
	var/last_program
	var/offline_program = "holodeck_offline"

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
	//var/template_id
	var/turf/bottom_left
	var/area/current_holodeck_area
	var/list/before_load = list()
	var/list/after_load = list()

/obj/effect/mapping_helpers/holodeck_spawner
	icon_state = ""
	var/this

/obj/machinery/computer/holodeck/proc/get_spawn_tile(var/obj/effect/Spawn)
	spawn_tile = get_turf(Spawn)

/obj/machinery/computer/holodeck/proc/get_template()//now i need to create template ids for all sims and match them with the program lists, however theyre done
	//if(template)//i think this is bad if we want to have more than one template loaded throughout the round
	//	return
	//template = SSmapping.holodeck_templates[template_id]
	//if(!template)
	//	WARNING("Shelter template ([template_id]) not found!")
	//	qdel(src)


/obj/machinery/computer/holodeck/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/holodeck/LateInitialize()//from here linked is populated and the program list is generated. its also set to load the offline program
	//var/obj/effect/holodeck_helper = locate(/obj/effect/mapping_helpers/holodeck_spawner) //BAD KYLER :newspaper2:
	//get_spawn_tile(holodeck_helper)
	current_holodeck_area = GLOB.areas_by_type[/area/holodeck/rec_center] //this should make current_area be the actual holodeck offline area object
	bottom_left = locate(current_holodeck_area.x, current_holodeck_area.y, 2)

	/*if(ispath(holodeck_type, /area))
		linked = pop(get_areas(holodeck_type, FALSE))//maybe pop removes holodeck/rec_area?
	if(ispath(offline_program, /area))
		offline_program = pop(get_areas(offline_program), FALSE)
	// the following is necessary for power reasons
	if(!linked || !offline_program)
		log_world("No matching holodeck area found")
		//qdel(src)
		return
	var/area/AS = get_area(src)
	if(istype(AS, /area/holodeck))
		log_mapping("Holodeck computer cannot be in a holodeck, This would cause circular power dependency.")
		//qdel(src)
		return
	else
		linked.linked = src
		var/area/my_area = get_area(src)
		if(my_area)
			linked.power_usage = my_area.power_usage
		else
			linked.power_usage = new /list(AREA_USAGE_LEN)
			*/

	generate_program_list()
	//load_program("holodeck_lounge")//honestly there isnt a reason to do this as far as im aware

/obj/machinery/computer/holodeck/Destroy()
	message_admins(world,"DEBUG -- lmao youre fucked")
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

/obj/machinery/computer/holodeck/ui_data(mob/user)
	var/list/data = list()

	data["default_programs"] = program_cache
	if(obj_flags & EMAGGED)
		data["emagged"] = TRUE
		data["emag_programs"] = emag_programs
	data["program"] = program
	data["can_toggle_safety"] = issilicon(user) || isAdminGhostAI(user)
	return data

/obj/machinery/computer/holodeck/ui_act(action, params)
	if(..())
		return
	. = TRUE
	switch(action)
		if("load_program")
			//var/program_to_load = text2path(params["type"])
			//^ i might have needed to do this
			//var/datum/map_template/holodeck/program_to_load = params//this shouldnt work as is, holodeck.js doesnt send the type at all, it only sends the name and template_id
			var/program_to_load = params["id"]
			//if(!ispath(program_to_load))
			//	return FALSE
			//var/valid = FALSE
			//var/list/checked = program_cache.Copy()
			/*if(obj_flags & EMAGGED)
				checked |= emag_programs
			for(var/prog in checked)
				var/list/P = prog
				if(P["type"] == program_to_load)
					valid = TRUE
					break
			if(!valid)
				return FALSE*/
			//load the map_template that program_to_load represents
			//var/datum/map_template/shelter/template //template = SSmapping.holodeck_templates[template_id]
			//var/datum/map_template/shelter/template = SSmapping.holodeck_templates[program_to_load]
			//var/area/A = locate(program_to_load) in GLOB.sortedAreas
			if(program_to_load)
				//var/id = initial(program_to_load.template_id)
				load_program(program_to_load)//do i only need to replace this? NO EASYNESS, ONLY PAIN
		/*if("safety")
			if((obj_flags & EMAGGED) && program)
				emergency_shutdown()
			nerf(obj_flags & EMAGGED)
			obj_flags ^= EMAGGED
			say("Safeties restored. Restarting...")*/


/obj/machinery/computer/holodeck/process()
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
		//if(!A)
			//continue
		var/list/info_this = list()
		info_this["name"] = initial(A.name)
		info_this["id"] = initial(A.template_id)
		if(initial(A.restricted))
			LAZYADD(emag_programs, list(info_this))
		else
			LAZYADD(program_cache, list(info_this))

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = FALSE)//low priority
	if(active == toggleOn)
		return

	if(toggleOn)
		if(last_program && last_program != offline_program)
			addtimer(CALLBACK(src, .proc/load_program, TRUE), 25)
		active = TRUE
	else
		last_program = program
		load_program("holodeck_offline")
		active = FALSE

/obj/machinery/computer/holodeck/proc/emergency_shutdown()//low priority
	last_program = program
	load_program("holodeck_offline", TRUE)
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

/*/obj/machinery/computer/holodeck/proc/prepare_holodeck_area()//called AFTER the current template is selected in l_pro, but BEFORE template.load
	//spawned += template.get_affected_turfs(bottom_left)//get_a_f shoooould be a list
	var/list/holodeck_turfs
	LAZYADD(holodeck_turf_contents, get_area_turfs(current_holodeck_area))//THIS ONLY HAS FUCKIGN TURFS
	for (var/atom/previous_item in holodeck_turfs.contents)
		if (previous_item.flags_1 & HOLOGRAM_1)
			if (!istype(previous_item,/turf/))
				qdel(previous_item)*/

/datum/map_template/holodeck/load(turf/T, centered = FALSE, )
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	var/list/border = block(locate(max(T.x-1, 1),			max(T.y-1, 1),			 T.z),//kyler, this makes a block of turfs between the farthest possible turf corner and the closest?
							locate(min(T.x+width+1, world.maxx),	min(T.y+height+1, world.maxy), T.z))
	for(var/L in border)
		var/turf/turf_to_disable = L
		SSair.remove_from_active(turf_to_disable) //stop processing turfs along the border to prevent runtimes, we return it in initTemplateBounds()
		turf_to_disable.atmos_adjacent_turfs?.Cut()

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	cached_map = keep_cached_map ? parsed : null
	if(!parsed.load(T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=TRUE))
		return
	var/list/bounds = parsed.bounds//what exactly IS parsed.bounds mean? is it whatver is boing put into the world when load is called? or is it whats in the world after load is called?
	if(!bounds)
		return

	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
		repopulate_sorted_areas()

	//parsed.findSpawnedAtoms()
	//initialize things that are normally initialized after map load
	if (parsed == lastparsed)
		spawned_atoms = parsed.holodeckTemplateBounds()
	else
		for (var/atom/atom in spawned_atoms)
			qdel(atom)
		LAZYCLEARLIST(spawned_atoms)
		spawned_atoms = parsed.holodeckTemplateBounds()

	lastparsed = parsed
	/*var/list/atoms/atoms = parsed.initTemplateBounds().atoms
	for (var/index in atoms)
		index.flags_1 |= HOLOGRAM_1*/
	//spawned_atoms = bounds
	log_game("[name] loaded at [T.x],[T.y],[T.z]")
	return bounds

/datum/parsed_map/proc/holodeckTemplateBounds()
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()
	var/list/atom/newatoms = list()
	var/list/area/areas = list()
	LAZYCLEARLIST(newatoms)

	var/list/turfs = block(	locate(bounds[MAP_MINX], bounds[MAP_MINY], bounds[MAP_MINZ]),
							locate(bounds[MAP_MAXX], bounds[MAP_MAXY], bounds[MAP_MAXZ]))
	var/list/border = block(locate(max(bounds[MAP_MINX]-1, 1),			max(bounds[MAP_MINY]-1, 1),			 bounds[MAP_MINZ]),
							locate(min(bounds[MAP_MAXX]+1, world.maxx),	min(bounds[MAP_MAXY]+1, world.maxy), bounds[MAP_MAXZ])) - turfs
	for(var/L in turfs)//for each element in the list of turfs created by block(stuff)
		var/turf/B = L
		atoms += B//atoms = atoms + B, turfs are atoms
		areas |= B.loc //areas = areas|B.loc
		for(var/atom/A in B)//does this look for the contents in the turf represented by B?
			if (!(A.flags_1 & INITIALIZED_1))
				newatoms += A
				//A.flags_1 |= HOLOGRAM_1
			else
				atoms += A//for each object in the contents of the current turf, add it to the atoms list

			if(istype(A, /obj/structure/cable))
				cables += A//if A is a cable, add to the cable list
				continue
			if(istype(A, /obj/machinery/atmospherics))//if A is an atmos machine, add it to the atmos machine list
				atmos_machines += A
	for(var/L in border)
		var/turf/T = L
		T.air_update_turf(TRUE) //calculate adjacent turfs along the border to prevent runtimes
	//for (var/atom/atom in atoms)
	//	if ((flags_1))
	//		atom.flags_1 |= HOLOGRAM_1

	//for (var/atom/atom in atoms)
	//	if (!(atom.flags_1 & INITIALIZED_1))
	//		LAZYADD(newatoms, atom)
	//		atom.flags_1 |= HOLOGRAM_1


	SSmapping.reg_in_areas_in_z(areas)
	//SSatoms.InitializeAtoms(atoms)
	SSatoms.InitializeAtoms(newatoms) //copy the whole scanning thingy in another proc, look for all atoms that dont have the INITIALIZED_1 flag & have the HOLOGRAM_1 flag, add them to spawned
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)
	return newatoms

/obj/machinery/computer/holodeck/proc/load_program(var/map_id, force = FALSE, add_delay = TRUE)

	/*if(!is_operational)
		template = offline_program
		force = TRUE

	if(program == map_id)//if the program is the same as the corresponding area
		return*/

	program = map_id //<- dont forget this

	//template = SSmapping.holodeck_templates[template_id]
	template = SSmapping.holodeck_templates[map_id]
	//prepare_holodeck_area()
	//template.load(bottom_left, FALSE)
	//spawned = template.load(bottom_left, FALSE) //write another proc that just gets the atoms from holodeckTemplateBounds()?

	//BOUNDS ARE JUST COORDINATES AHHHHHHHHHHHHHHHHHHHHHHH
	template.load(bottom_left, FALSE)
	//if (!spawned.len)
	spawned = template.spawned_atoms


	current_holodeck_area = get_area(bottom_left)
	//linked is the argument in place of the copy_contents area/A parameter
	//map.load places templates on a TURF, copy_contents copies to an entire area

	//spawned = A.copy_contents_to(linked, 1, nerf_weapons = !(obj_flags & EMAGGED))
	//message_admins(world,"DEBUG -- load_program ended")

/obj/machinery/computer/holodeck/proc/finish_spawn()
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
	/*// Emagging a machine creates an anomaly in the derez systems.
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
		qdel(O)*/

#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
