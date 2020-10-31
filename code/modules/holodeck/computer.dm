/*
	Map Template Holodeck

	Holodeck finds the location of mappedstartarea and loads offline_program in it on LateInitialize. It then loads the programs that have the same holodeck_access
	flag as it (e.g. the station holodeck has the holodeck_access flag STATION_HOLODECK, and it loads all programs with this flag), these program templates are then
	given to Holodeck.js in the form of program_cache and emag_programs. when a user selects a program the ui calls load_program with the id of the selected program.
	There are two modified map template procs for the holodeck, map_template/holodeck/load and parsed_map/holodeckTemplateBounds. These are similar to their
	non holodeck counterparts, map_template/load and parsed_map/initTemplateBounds. the main difference is that holodeckTemplateBounds records how many non turf
	atoms it created, and passes this to map_template/holodeck/load, which passes it to load_program as the spawned list. if something spawned by the holodeck
	doesnt get deleted when it should, then for whatever reason it is not being put inside the spawned list. usually this is because it was created by an object
	that was inside the spawned list (like how deconstructing a dresser spawns 10 wood planks, which are themselves not put into spawned)


	Easiest way to add new holodeck programs
	1) Define new map template datums in code/modules/holodeck/holodeck_map_templates
	2) Create the new map templates in _maps/templates (remember theyre 9x10)
	3) Create a new control console that uses those templates


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
	var/area/mappedstartarea = /area/holodeck/rec_center //change this to a different area if youre making a second holodeck different from the station one
	var/program = "holodeck_offline"
	var/last_program
	var/offline_program = "holodeck_offline"
	var/holodeck_access = STATION_HOLODECK

	var/list/program_cache
	var/list/emag_programs

	var/program_type = /datum/map_template/holodeck	// subtypes of this (but not this itself) are loadable programs

	var/active = FALSE
	var/damaged = FALSE
	var/list/spawned = list()
	var/list/effects = list()
	var/current_cd = 0
	var/datum/map_template/holodeck/template
	var/turf/bottom_left
	//var/broken_floor = TRUE
	var/list/non_holo_items_in_area = list()

/obj/machinery/computer/holodeck/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/holodeck/LateInitialize()//from here linked is populated and the program list is generated. its also set to load the offline program
	linked = GLOB.areas_by_type[mappedstartarea]
	bottom_left = locate(linked.x, linked.y, src.z)

	var/area/computer_area = get_area(src)
	if(istype(computer_area, /area/holodeck))
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
		var/datum/map_template/holodeck/program = typekey
		var/list/info_this = list()
		info_this["id"] = initial(program.template_id)
		info_this["name"] = initial(program.name)
		if(initial(program.restricted) && (initial(program.access_flags) & holodeck_access))
			LAZYADD(emag_programs, list(info_this))
		else if (initial(program.access_flags) & holodeck_access)
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
				load_program(program_to_load)
		if("safety")
			if((obj_flags & EMAGGED) && program)
				emergency_shutdown()
			nerf(obj_flags & EMAGGED)
			obj_flags ^= EMAGGED
			say("Safeties restored. Restarting...")

/*
	basically the equivalent of map_template/load except it calls parsed.load with placeOnTop = FALSE (so holodeck programs dont stack in the baseturf list)
	and passes spawned_atoms from parsed to the holodeck template datum
*/
/*
/datum/map_template/holodeck/load(turf/target_turf, centered = FALSE, )
	if(centered)
		target_turf = locate(target_turf.x - round(width/2) , target_turf.y - round(height/2) , target_turf.z)
	if(!target_turf)
		return
	if(target_turf.x+width > world.maxx)
		return
	if(target_turf.y+height > world.maxy)
		return

	var/list/border = block(locate(max(target_turf.x-1, 1),	max(target_turf.y-1, 1), target_turf.z),
							locate(min(target_turf.x+width+1, world.maxx),	min(target_turf.y+height+1, world.maxy), target_turf.z))
	for(var/_turf in border)
		var/turf/turf_to_disable = _turf
		SSair.remove_from_active(turf_to_disable) //stop processing turfs along the border to prevent runtimes, we return it in holodeckTemplateBounds()
		turf_to_disable.atmos_adjacent_turfs?.Cut()

	// Accept cached maps, but don't save them automatically - we don't want
	// ruins clogging up memory for the whole round.
	var/datum/parsed_map/parsed = cached_map || new(file(mappath))
	cached_map = keep_cached_map ? parsed : null
	if(!parsed.load(target_turf.x, target_turf.y, target_turf.z, cropMap=TRUE, no_changeturf=(SSatoms.initialized == INITIALIZATION_INSSATOMS), placeOnTop=FALSE))
		return
	var/list/bounds = parsed.bounds
	if(!bounds)
		return

	if(!SSmapping.loading_ruins) //Will be done manually during mapping ss init
		repopulate_sorted_areas()

	//initialize things that are normally initialized after map load

	spawned_atoms = parsed.holodeckTemplateBounds()

	for (var/obj/base_container in spawned_atoms)//this didnt seem to work when i put this in holodeckTemplateBounds
		if (length(base_container.contents) > 0)
			spawned_atoms -= base_container
			spawned_atoms += base_container.GetAllContents()

	lastparsed = parsed
	log_game("[name] loaded at [target_turf.x],[target_turf.y],[target_turf.z]")
	return bounds

/*
	similar to initTemplateBounds except it keeps track of all new objects it creates and passes it to map_template/holodeck/load
*/
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

	for(var/_turf in turfs)
		var/turf/turf_iterate = _turf
		areas |= turf_iterate.loc
		for(var/atom/atom_iterate in turf_iterate)
			if (!(atom_iterate.flags_1 & INITIALIZED_1))//anything in the parsed map that hasnt been initialized is something spawned from the holodeck, so add it to newatoms
				newatoms += atom_iterate
			else
				atoms += atom_iterate

			if(istype(atom_iterate, /obj/structure/cable))
				cables += atom_iterate
				continue
			if(istype(atom_iterate, /obj/machinery/atmospherics))
				atmos_machines += atom_iterate

	SSmapping.reg_in_areas_in_z(areas)
	SSatoms.InitializeAtoms(turfs+atoms+newatoms)
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
	for(var/_turf in template_and_bordering_turfs)
		var/turf/affected_turf = _turf
		affected_turf.air_update_turf(TRUE)

	return newatoms//this is what will become the spawned list for the holodeck
*/

/datum/map_template/holodeck/update_blacklist(turf/placement)
	turf_blacklist.Cut()
	for (var/_turf in get_affected_turfs(placement))
		var/turf/possible_blacklist = _turf
		if (!istype(possible_blacklist, /turf/open/floor/holofloor))
			if (istype(possible_blacklist, /turf/open/floor/engine))
				continue
			turf_blacklist += possible_blacklist

/*
	the main engine of the holodeck, it loads the template whose id string it was given ("offline_program" loads datum/map_template/holodeck/offline)
*/
/obj/machinery/computer/holodeck/proc/load_program(var/map_id, force = FALSE, add_delay = TRUE)

	if (program == map_id)
		return

	if (current_cd > world.time && !force)
		say("ERROR. Recalibrating projection apparatus.")
		return

	if (add_delay)
		current_cd = world.time + HOLODECK_CD
		if(damaged)
			current_cd += HOLODECK_DMG_CD

	active = (map_id != offline_program)
	use_power = active + IDLE_POWER_USE
	program = map_id

	//clear the items from the previous program
	if (spawned)
		for (var/_item in spawned)
			var/obj/holo_item = _item
			derez(holo_item)
	if (effects)
		for (var/_effect in effects)
			var/obj/effect/holodeck_effect/holo_effect = _effect
			effects -= holo_effect
			holo_effect.deactivate(src)

	template = SSmapping.holodeck_templates[map_id]
	non_holo_items_in_area.Cut()

	for (var/_turf in linked)
		var/turf/holo_turf = _turf
		non_holo_items_in_area += holo_turf.contents

	template.load(bottom_left)//this is what actually loads the holodeck simulation into the map

	spawned = template.created_atoms

	nerf(!(obj_flags & EMAGGED))
	finish_spawn()

/obj/machinery/computer/holodeck/proc/finish_spawn()//this is used for holodeck effects (like spawners). otherwise they dont do shit
	for (var/_atom in spawned)
		var/atom/atoms = _atom

		if (isturf(atoms))
			var/turf/holo_turf = atoms
			spawned -= holo_turf

		atoms.flags_1 |= HOLOGRAM_1

		if (istype(atoms, /obj/effect/holodeck_effect/))//this is what makes holoeffects work
			var/obj/effect/holodeck_effect/holo_effect = atoms
			effects += holo_effect
			spawned -= holo_effect
			var/atom/active_effect = holo_effect.activate(src)
			if(istype(active_effect) || islist(active_effect))
				spawned += active_effect // holocarp are not forever

		if (isobj(atoms))
			var/obj/holo_object = atoms
			if (length(holo_object.contents) > 0)
				spawned -= holo_object
				spawned += holo_object.GetAllContents()
			holo_object.resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

			if (ismachinery(holo_object))
				var/obj/machinery/machines = holo_object
				machines.flags_1 |= NODECONSTRUCT_1
				machines.power_change()

				if(istype(machines, /obj/machinery/button))
					var/obj/machinery/button/buttons = machines
					buttons.setup_device()

			if (isstructure(holo_object))
				var/obj/structure/structures = holo_object
				structures.flags_1 |= NODECONSTRUCT_1

/obj/machinery/computer/holodeck/proc/derez(obj/object, silent = TRUE, forced = FALSE)//this qdels holoitems that should no longer exist for whatever reason
	if(!object)
		return

	spawned -= object
	for (var/_object in non_holo_items_in_area)
		var/obj/is_holo = _object
		if (object == is_holo)
			return
	var/turf/target_turf = get_turf(object)
	for(var/atom/movable/object_contents in object) // these should be derezed if they were generated
		object_contents.forceMove(target_turf)
		if(ismob(object_contents))
			silent = FALSE // otherwise make sure they are dropped

	if(!silent)
		visible_message("<span class='notice'>[object] fades away!</span>")

	qdel(object)

/obj/machinery/computer/holodeck/process(delta_time)
	if(damaged && DT_PROB(5, delta_time))
		for(var/turf/holo_turf in linked)
			if(DT_PROB(2.5, delta_time))
				do_sparks(2, 1, holo_turf)
				return

	if(!..() || program == offline_program)//we dont need to scan the holodeck if the holodeck is offline
		return

	if(!floorcheck())
		emergency_shutdown()
		damaged = TRUE
		for(var/mob/can_see_fuckup in urange(10,src))
			can_see_fuckup.show_message("The holodeck overloads!")

		for(var/turf/holo_turf in linked)
			if(prob(30))
				do_sparks(2, 1, holo_turf)
			SSexplosions.lowturf += holo_turf
			holo_turf.hotspot_expose(1000,500,1)

	if(!(obj_flags & EMAGGED))
		for(var/item in spawned)
			if(!(get_turf(item) in linked))
				derez(item)
	for(var/_effect in effects)
		var/obj/effect/holodeck_effect/holo_effect = _effect
		holo_effect.tick()
	active_power_usage = 50 + spawned.len * 3 + effects.len * 5

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = FALSE)
	if(active == toggleOn)
		return

	if(toggleOn)
		if(last_program && (last_program != offline_program))
			addtimer(CALLBACK(src, .proc/load_program, last_program, TRUE), 25)
		active = TRUE
	else
		last_program = program
		load_program("holodeck_offline", TRUE)
		active = FALSE

/obj/machinery/computer/holodeck/power_change()
	. = ..()
	INVOKE_ASYNC(src, .proc/toggle_power, !machine_stat)

/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	last_program = program
	active = FALSE
	//broken_floor = FALSE
	for (var/_item in spawned)
		var/obj/to_remove = _item
		derez(to_remove)
	/*for (var/_turf in linked)
		var/turf/holo_turf = _turf
		if (istype(holo_turf, /turf/open/floor/holofloor))
			holo_turf.ChangeTurf(/turf/open/floor/holofloor/plating, null, flags = CHANGETURF_INHERIT_AIR)*/
	load_program("holodeck_offline", TRUE)

/obj/machinery/computer/holodeck/proc/floorcheck()
	for(var/turf/holo_floor in linked)
		if(isspaceturf(holo_floor))
			return FALSE
		if(!holo_floor.intact)
			return FALSE
	return TRUE

/obj/machinery/computer/holodeck/proc/nerf(var/nerf_this)
	for(var/obj/item/to_be_nerfed in spawned)
		to_be_nerfed.damtype = nerf_this ? STAMINA : initial(to_be_nerfed.damtype)
	for(var/to_be_nerfed in effects)
		var/obj/effect/holodeck_effect/holo_effect = to_be_nerfed
		holo_effect.safety(nerf_this)

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



/obj/machinery/computer/holodeck/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()


/obj/machinery/computer/holodeck/offstation
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	offline_program = "holodeck_offline"
	holodeck_access = CUSTOM_HOLODECK_ONE
	mappedstartarea = /area/holodeck/rec_center/offstation_one

/obj/machinery/computer/holodeck/offstation/LateInitialize()
	holodeck_access |= STATION_HOLODECK
	. = ..()

#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
