/*
	Holodeck Update

	The on-station holodeck area is of type [holodeck_type].
	All subtypes of [program_type] are loaded into the program cache or emag programs list.
	If init_program is null, a random program will be loaded on startup.
	If you don't wish this, set it to the offline program or another of your choosing.

	You can use this to add holodecks with minimal code:
	1) Define new areas for the holodeck programs in code/game/area/areas/holodeck
	2) Define new map template datums in code/modules/holodeck/holodeck
	3) Create the new map templates in _maps/templates
	4) Create a new control console that uses those templates

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
	var/area/mappedstartarea = /area/holodeck/rec_center //var edit this to a different area if youre making a second holodeck different from the station one
	var/area/holodeck/loaded
	var/program = "holodeck_offline"
	var/last_program
	var/offline_program = "holodeck_offline"
	var/holodeck_access = STATION_HOLODECK
	//var/holoaccess_flag = (1<<holodeck_access)

	var/list/program_cache
	var/list/emag_programs

	// Splitting this up allows two holodecks of the same size
	// to use the same source patterns.  Y'know, if you want to.
	var/holodeck_type = /datum/map_template/holodeck
	var/program_type = /datum/map_template/holodeck	// subtypes of this (but not this itself) are loadable programs

	var/active = FALSE
	var/damaged = FALSE
	var/list/spawned = list()
	var/list/effects = list()
	var/current_cd = 0
	var/datum/map_template/holodeck/template
	var/turf/spawn_tile
	var/turf/bottom_left
	var/list/before_load = list()
	var/list/after_load = list()

/obj/machinery/computer/holodeck/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/holodeck/LateInitialize()//from here linked is populated and the program list is generated. its also set to load the offline program
	linked = GLOB.areas_by_type[mappedstartarea]
	bottom_left = locate(linked.x, linked.y, src.z)

	var/area/AS = get_area(src)
	if(istype(AS, /area/holodeck))
		log_mapping("Holodeck computer cannot be in a holodeck, This would cause circular power dependency.")
		qdel(src)
		return

	// the following is necessary for power reasons
	if(!linked)
		log_world("No matching holodeck area found")
		qdel(src)
		return
	else if (!offline_program)
		log_world("Holodeck console created without an offline program")
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
	load_program(offline_program,TRUE)//this does nothing for normal holodecks, but will help with additional custom holodecks

/obj/machinery/computer/holodeck/proc/generate_program_list()
	for(var/typekey in subtypesof(program_type))
		var/datum/map_template/holodeck/A = typekey
		//if(!A)
			//continue
		var/list/info_this = list()
		info_this["id"] = initial(A.template_id)
		info_this["name"] = initial(A.name)
		if(initial(A.restricted) && (initial(A.access_flags) & holodeck_access))
			LAZYADD(emag_programs, list(info_this))
		else if (initial(A.access_flags) & holodeck_access)
			LAZYADD(program_cache, list(info_this))

/obj/machinery/computer/holodeck/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Holodeck", name)
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
	. = ..()
	if(.)
		return
	. = TRUE
	switch(action)
		if("load_program")
			var/program_to_load = params["id"]
			//load the map_template that program_to_load represents
			if(program_to_load)
				load_program(program_to_load)//do i only need to replace this? NO EASYNESS, ONLY PAIN
		if("safety")
			if((obj_flags & EMAGGED) && program)
				emergency_shutdown()
			nerf(obj_flags & EMAGGED)
			obj_flags ^= EMAGGED
			say("Safeties restored. Restarting...")

/obj/machinery/computer/holodeck/process(delta_time)
	if(damaged && DT_PROB(5, delta_time))
		for(var/turf/T in linked)
			if(DT_PROB(2.5, delta_time))
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
				derez(item)
	for(var/e in effects)
		var/obj/effect/holodeck_effect/HE = e
		HE.tick()
	active_power_usage = 50 + spawned.len * 3 + effects.len * 5

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = FALSE)
	if(active == toggleOn)
		return

	if(toggleOn)
		if(last_program && (last_program != offline_program))
			load_program(last_program)
		active = TRUE
	else
		last_program = program
		load_program("holodeck_offline")
		active = FALSE

/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	last_program = program
	load_program("holodeck_offline", TRUE)
	active = FALSE

/obj/machinery/computer/holodeck/proc/floorcheck()
	for(var/turf/T in linked)
		if(!T.intact || isspaceturf(T))
			return FALSE
	return TRUE

/obj/machinery/computer/holodeck/proc/nerf(active)//i cant really think of a situation in which nerf does anything, since its deactivated when safeties are turned off
	for(var/obj/item/I in spawned)
		I.damtype = active ? STAMINA : initial(I.damtype)

/datum/map_template/holodeck/load(turf/T, centered = FALSE, )
	if(centered)
		T = locate(T.x - round(width/2) , T.y - round(height/2) , T.z)
	if(!T)
		return
	if(T.x+width > world.maxx)
		return
	if(T.y+height > world.maxy)
		return

	var/list/border = block(locate(max(T.x-1, 1),			max(T.y-1, 1),			 T.z),
							locate(min(T.x+width+1, world.maxx),	min(T.y+height+1, world.maxy), T.z))
	for(var/L in border)
		var/turf/turf_to_disable = L
		SSair.remove_from_active(turf_to_disable) //stop processing turfs along the border to prevent runtimes, we return it in holodeckTemplateBounds()
		turf_to_disable.atmos_adjacent_turfs?.Cut()

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	cached_map = keep_cached_map ? parsed : null
	if(!parsed.load(T.x, T.y, T.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=FALSE))
		return
	var/list/bounds = parsed.bounds
	if(!bounds)
		return

	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
		repopulate_sorted_areas()

	//initialize things that are normally initialized after map load

	spawned_atoms = parsed.holodeckTemplateBounds()
	for (var/obj/base_container in spawned_atoms)
		if (length(base_container.contents) > 0)
			spawned_atoms -= base_container
			spawned_atoms += base_container.GetAllContents()

	lastparsed = parsed
	log_game("[name] loaded at [T.x],[T.y],[T.z]")
	return bounds

/datum/parsed_map/proc/holodeckTemplateBounds()
	var/list/obj/machinery/atmospherics/atmos_machines = list()
	var/list/obj/structure/cable/cables = list()
	var/list/atom/atoms = list()
	var/list/atom/newatoms = list()
	var/list/area/areas = list()

	var/list/turfs = block(
		locate(
			bounds[MAP_MINX],
			bounds[MAP_MINY],
			bounds[MAP_MINZ]
			),
		locate(
			bounds[MAP_MAXX],
			bounds[MAP_MAXY],
			bounds[MAP_MAXZ]
			)
		)

	for(var/L in turfs)
		var/turf/B = L
		areas |= B.loc
		for(var/atom/A in B)
			if (!(A.flags_1 & INITIALIZED_1))//anything in the parsed map that hasnt been initialized is something spawned from the holodeck, so add it to newatoms
				newatoms += A
			else
				atoms += A

			if(istype(A, /obj/structure/cable))
				cables += A
				continue
			if(istype(A, /obj/machinery/atmospherics))
				atmos_machines += A

	SSmapping.reg_in_areas_in_z(areas)
	SSatoms.InitializeAtoms(turfs)
	SSatoms.InitializeAtoms(atoms)
	SSatoms.InitializeAtoms(newatoms)
	SSmachines.setup_template_powernets(cables)
	SSair.setup_template_machinery(atmos_machines)

	var/list/template_and_bordering_turfs = block(
		locate(
			max(bounds[MAP_MINX]-1, 1),
			max(bounds[MAP_MINY]-1, 1),
			bounds[MAP_MINZ]
			),
		locate(
			min(bounds[MAP_MAXX]+1, world.maxx),
			min(bounds[MAP_MAXY]+1, world.maxy),
			bounds[MAP_MAXZ]
			)
		)
	for(var/t in template_and_bordering_turfs)
		var/turf/affected_turf = t
		affected_turf.air_update_turf(TRUE)

	return newatoms//this is what will become the spawned list for the holodeck

/obj/machinery/computer/holodeck/proc/load_program(var/map_id, force = FALSE, add_delay = TRUE)

	if(program == map_id)
		return

	if(current_cd > world.time && !force)
		say("ERROR. Recalibrating projection apparatus.")
		return

	if(add_delay)
		current_cd = world.time + HOLODECK_CD
		if(damaged)
			current_cd += HOLODECK_DMG_CD

	use_power = active + IDLE_POWER_USE
	program = map_id

	if (spawned)//clear the items from the previous program
		for (var/atom/item in spawned)
			derez(item)

	template = SSmapping.holodeck_templates[map_id]
	template.load(bottom_left, FALSE)//this is what actually loads the holodeck simulation into the map

	spawned += template.spawned_atoms//parsed_map.holodeckTemplateBounds has newatoms, which is passed to template as spawned_atoms, which is passed to this as spawned

	linked = get_area(bottom_left)
	linked.linked = src

	finish_spawn()

/obj/machinery/computer/holodeck/proc/finish_spawn()//this is used for holodeck effects (like spawners). otherwise they dont do shit
	var/list/added = list()

	for (var/atom/atoms in spawned)

		if (atoms.flags_1 & INITIALIZED_1)
			atoms.flags_1 |= HOLOGRAM_1

		if (istype(atoms, /obj/effect/holodeck_effect/))//this is what makes holoeffects work
			var/obj/effect/holodeck_effect/HE = atoms
			effects += HE
			spawned -= HE
			var/atom/x = HE.activate(src)
			if(istype(x) || islist(x))
				spawned += x // holocarp are not forever
				added += x

		if (istype(atoms, /obj))
			var/obj/obbies = atoms
			obbies.resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
			if (ismachinery(obbies))
				var/obj/machinery/machines = obbies
				machines.power_change()
				if(istype(machines, /obj/machinery/button))
					var/obj/machinery/button/buttons = machines
					buttons.setup_device()

	for(var/obj/machinery/M in spawned)
		M.flags_1 |= NODECONSTRUCT_1
	for(var/obj/structure/S in spawned)
		S.flags_1 |= NODECONSTRUCT_1

/obj/machinery/computer/holodeck/proc/derez(obj/object, silent = TRUE, forced = FALSE)//this qdels holoitems that should no longer exist for whatever reason
	if(!object)
		return

	spawned -= object
	var/turf/T = get_turf(object)
	for(var/atom/movable/AM in object) // these should be derezed if they were generated
		AM.forceMove(T)
		if(ismob(AM))
			silent = FALSE // otherwise make sure they are dropped

	if(!silent)
		visible_message("<span class='notice'>[object] fades away!</span>")

	qdel(object)

/obj/machinery/computer/holodeck/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	if(!LAZYLEN(emag_programs))
		to_chat(user, "[src] does not seem to have a card swipe port. It must be an inferior model.")
		return
	playsound(src, "sparks", 75, TRUE)
	obj_flags |= EMAGGED
	to_chat(user, "<span class='warning'>You vastly increase projector power and override the safety and security protocols.</span>")
	say("Warning. Automatic shutoff and derezzing protocols have been corrupted. Please call Nanotrasen maintenance and do not use the simulator.")
	log_game("[key_name(user)] emagged the Holodeck Control Console")
	nerf(!(obj_flags & EMAGGED))

/obj/machinery/computer/holodeck/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	emergency_shutdown()

/obj/machinery/computer/holodeck/ex_act(severity, target)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/Destroy()
	emergency_shutdown()
	if(linked)
		linked.linked = null
		linked.power_usage = new /list(AREA_USAGE_LEN)
	return ..()

/obj/machinery/computer/holodeck/power_change()
	. = ..()
	INVOKE_ASYNC(src, .proc/toggle_power, !machine_stat)

/obj/machinery/computer/holodeck/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()

#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
