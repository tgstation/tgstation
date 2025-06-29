/*
Map Template Holodeck

Holodeck finds the location of mapped_start_area and loads offline_program in it on LateInitialize. It then passes its program templates to Holodeck.js in the form of program_cache and emag_programs. when a user selects a program the
ui calls load_program() with the id of the selected program.
load_program() -> map_template/load() on map_template/holodeck.

holodeck map templates:
1. have an update_blacklist that doesnt allow placing on non holofloors (except for engine floors so you can repair it)
2. has should_place_on_top = FALSE, so that the baseturfs list doesnt pull a kilostation oom crash
3. has returns_created = TRUE, so that SSatoms gives the map template a list of spawned atoms
all the fancy flags and shit are added to holodeck objects in finish_spawn()

Easiest way to add new holodeck programs:
1. Define new map template datums in code/modules/holodeck/holodeck_map_templates, make sure they have the access flags
of the holodeck you want them to be able to load, for the onstation holodeck the flag is STATION_HOLODECK.
2. Create the new map templates in _maps/templates (remember theyre 9x10, and make sure they have area/noop or else it will fuck with linked)
all turfs in holodeck programs MUST be of type /turf/open/floor/holofloor, OR /turf/open/floor/engine, or they will block future programs!

Note: if youre looking at holodeck code because you want to see how returns_created is handled so that templates return a list of atoms
created from them: make sure you handle that list correctly! Either copy them by value and delete them or reference it and handle qdel'ing
and clear when youre done! if you dont i will use :newspaper2: on you
*/

#define HOLODECK_CD (2 SECONDS)
#define HOLODECK_DMG_CD (5 SECONDS)

/// typecache for turfs that should be considered ok during floorchecks.
/// A linked turf being anything not in this typecache will cause the holodeck to perform an emergency shutdown.
GLOBAL_LIST_INIT(typecache_holodeck_linked_floorcheck_ok, typecacheof(list(/turf/open/floor/holofloor, /turf/closed)))

/obj/machinery/computer/holodeck
	name = "holodeck control console"
	desc = "A computer used to control a nearby holodeck."
	icon_screen = "holocontrol"

	//new vars
	///what area type this holodeck loads into. linked turns into the nearest instance of this area
	var/area/mapped_start_area = /area/station/holodeck/rec_center

	///the currently used map template
	var/datum/map_template/holodeck/template

	///bottom left corner of the loading room, used for placing
	var/turf/bottom_left

	///if TRUE the holodeck is busy spawning another simulation and should immediately stop loading the newest one
	var/spawning_simulation = FALSE

	//old vars

	///the area that this holodeck loads templates into, used for power and deleting holo objects that leave it
	var/area/station/holodeck/linked

	///what program is loaded right now or is about to be loaded
	var/program = "holodeck_offline"
	var/last_program

	///the default program loaded by this holodeck when spawned and when deactivated
	var/offline_program = "holodeck_offline"

	///stores all of the unrestricted holodeck map templates that this computer has access to
	var/list/program_cache
	///stores all of the restricted holodeck map templates that this computer has access to
	var/list/emag_programs

	///subtypes of this (but not this itself) are loadable programs
	var/program_type = /datum/map_template/holodeck

	///every holo object created by the holodeck goes in here to track it
	var/list/spawned = list()
	var/list/effects = list() //like above, but for holo effects

	///special locs that can mess with derez'ing holo spawned objects
	var/list/special_locs = list(
		/obj/item/mob_holder,
	)

	///TRUE if the holodeck is using extra power because of a program, FALSE otherwise
	var/active = FALSE
	///increases the holodeck cooldown if TRUE, causing the holodeck to take longer to allow loading new programs
	var/damaged = FALSE

	//creates the timer that determines if another program can be manually loaded
	COOLDOWN_DECLARE(holodeck_cooldown)

/obj/machinery/computer/holodeck/post_machine_initialize() //from here linked is populated and the program list is generated. its also set to load the offline program
	. = ..()
	linked = GLOB.areas_by_type[mapped_start_area]
	if(!linked)
		log_mapping("[src] at [AREACOORD(src)] has no matching holodeck area.")
		qdel(src)
		return

	bottom_left = locate(linked.x, linked.y, src.z)
	if(!bottom_left)
		log_mapping("[src] at [AREACOORD(src)] has an invalid holodeck area.")
		qdel(src)
		return

	var/area/computer_area = get_area(src)
	if(istype(computer_area, /area/station/holodeck))
		log_mapping("Holodeck computer cannot be in a holodeck, This would cause circular power dependency.")
		qdel(src)
		return

	// the following is necessary for power reasons
	if(!offline_program)
		stack_trace("Holodeck console created without an offline program")
		qdel(src)
		return

	linked.linked = src
	var/area/my_area = get_area(src)
	if(my_area)
		linked.energy_usage = my_area.energy_usage
	else
		linked.energy_usage = list(AREA_USAGE_LEN)

	COOLDOWN_START(src, holodeck_cooldown, HOLODECK_CD)
	generate_program_list()
	load_program(offline_program,TRUE)

///adds all programs that this holodeck has access to, and separates the restricted and unrestricted ones
/obj/machinery/computer/holodeck/proc/generate_program_list()
	for(var/typekey in subtypesof(program_type))
		var/datum/map_template/holodeck/program = typekey
		var/list/info_this = list("id" = initial(program.template_id), "name" = initial(program.name))
		if(initial(program.restricted))
			LAZYADD(emag_programs, list(info_this))
		else
			LAZYADD(program_cache, list(info_this))

/obj/machinery/computer/holodeck/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
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
	data["can_toggle_safety"] = HAS_SILICON_ACCESS(user)
	return data

/obj/machinery/computer/holodeck/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	. = TRUE

	switch(action)
		if("load_program")
			var/program_to_load = params["id"]

			var/list/checked = program_cache.Copy()
			if (obj_flags & EMAGGED)
				checked |= emag_programs
			var/valid = FALSE //dont tell security about this

			//checks if program_to_load is any one of the loadable programs, if it isnt then it rejects it
			for(var/list/check_list as anything in checked)
				if(check_list["id"] == program_to_load)
					valid = TRUE
					break
			if(!valid)
				return FALSE
			//load the map_template that program_to_load represents
			if(program_to_load)
				load_program(program_to_load)
		if("safety")
			if (!(obj_flags & EMAGGED) && !issilicon(usr))
				return
			if((obj_flags & EMAGGED) && program)
				emergency_shutdown()
			nerf(obj_flags & EMAGGED,FALSE)
			obj_flags ^= EMAGGED
			say("Safeties reset. Restarting...")
			usr.log_message("disabled Holodeck safeties.", LOG_GAME)

///this is what makes the holodeck not spawn anything on broken tiles (space and non engine plating / non holofloors)
/datum/map_template/holodeck/update_blacklist(turf/placement, list/input_blacklist)
	for(var/turf/possible_blacklist as anything in get_affected_turfs(placement))
		if (possible_blacklist.holodeck_compatible)
			continue
		input_blacklist[possible_blacklist] = TRUE

///loads the template whose id string it was given ("offline_program" loads datum/map_template/holodeck/offline)
/obj/machinery/computer/holodeck/proc/load_program(map_id, force = FALSE, add_delay = TRUE)
	if (program == map_id)
		return

	if (!is_operational)//load_program is called once with a timer (in toggle_power) we dont want this to load anything if its off
		map_id = offline_program
		force = TRUE

	if (!force && (!COOLDOWN_FINISHED(src, holodeck_cooldown) || spawning_simulation))
		say("ERROR. Recalibrating projection apparatus.")
		return

	if(spawning_simulation)
		return

	if (add_delay)
		COOLDOWN_START(src, holodeck_cooldown, (damaged ? HOLODECK_CD + HOLODECK_DMG_CD : HOLODECK_CD))
		if (damaged && floorcheck())
			damaged = FALSE

	spawning_simulation = TRUE
	active = (map_id != offline_program)
	update_mode_power_usage(ACTIVE_POWER_USE, initial(active_power_usage))
	program = map_id

	clear_projection()

	template = SSmapping.holodeck_templates[map_id]
	template.load(bottom_left) //this is what actually loads the holodeck simulation into the map

	if(template.restricted)
		usr.log_message("loaded a restricted Holodeck program: [program].", LOG_GAME)
		message_admins("[ADMIN_LOOKUPFLW(usr)] loaded a restricted Holodeck program: [program].")

	spawned = template.created_atoms //populate the spawned list with the atoms belonging to the holodeck

	if(istype(template, /datum/map_template/holodeck/thunderdome1218) && !SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_MEDISIM])
		say("Special note from \"1218 AD\" developer: I see you too are interested in the REAL dark ages of humanity! I've made this program also unlock some interesting shuttle designs on any communication console around. Have fun!")
		SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_MEDISIM] = TRUE

	nerf(!(obj_flags & EMAGGED))
	finish_spawn()

///To be used on destroy, mainly to prevent sleeping inside well, destroy. Missing a lot of the things contained in load_program
/obj/machinery/computer/holodeck/proc/reset_to_default()
	if (program == offline_program)
		return

	program = offline_program
	clear_projection()
	//update_mode_power_usage(ACTIVE_POWER_USE, initial(active_power_usage))
	update_use_power(IDLE_POWER_USE)

	template = SSmapping.holodeck_templates[offline_program]
	INVOKE_ASYNC(template, TYPE_PROC_REF(/datum/map_template, load), bottom_left) //this is what actually loads the holodeck simulation into the map

/obj/machinery/computer/holodeck/proc/clear_projection()
	//clear the items from the previous program
	for(var/holo_atom in spawned)
		derez(holo_atom)

	for(var/obj/effect/holodeck_effect/holo_effect as anything in effects)
		effects -= holo_effect
		holo_effect.deactivate(src)

	//makes sure that any time a holoturf is inside a baseturf list (e.g. if someone put a wall over it) its set to the OFFLINE turf
	//so that you cant bring turfs from previous programs into other ones (like putting the plasma burn turf into lounge for example)
	for(var/turf/closed/holo_turf in linked)
		holo_turf.replace_baseturf(/turf/open/floor/holofloor, /turf/open/floor/holofloor/plating)

///finalizes objects in the spawned list
/obj/machinery/computer/holodeck/proc/finish_spawn()
	for(var/atom/holo_atom as anything in spawned)
		if(QDELETED(holo_atom))
			spawned -= holo_atom
			continue
		finalize_spawned(holo_atom)
	spawning_simulation = FALSE

/obj/machinery/computer/holodeck/proc/finalize_spawned(atom/holo_atom)
	RegisterSignal(holo_atom, COMSIG_QDELETING, PROC_REF(remove_from_holo_lists))
	holo_atom.flags_1 |= HOLOGRAM_1

	if(isholoeffect(holo_atom))//activates holo effects and transfers them from the spawned list into the effects list
		var/obj/effect/holodeck_effect/holo_effect = holo_atom
		effects += holo_effect
		spawned -= holo_effect
		var/atom/holo_effect_product = holo_effect.activate(src)//change name
		if(istype(holo_effect_product))
			spawned += holo_effect_product // we want mobs or objects spawned via holoeffects to be tracked as objects
			RegisterSignal(holo_effect_product, COMSIG_QDELETING, PROC_REF(remove_from_holo_lists))
		if(islist(holo_effect_product))
			for(var/atom/atom_product as anything in holo_effect_product)
				spawned += atom_product
				RegisterSignal(atom_product, COMSIG_QDELETING, PROC_REF(remove_from_holo_lists))
		return

	if(isobj(holo_atom))
		var/obj/holo_object = holo_atom
		holo_object.resistance_flags = LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

		if(isstructure(holo_object))
			holo_object.obj_flags |= NO_DEBRIS_AFTER_DECONSTRUCTION
			if(istype(holo_object, /obj/structure/closet))
				RegisterSignal(holo_object, COMSIG_CLOSET_CONTENTS_INITIALIZED, PROC_REF(register_contents))
			return

		if(ismachinery(holo_object))
			var/obj/machinery/holo_machine = holo_object
			holo_machine.obj_flags |= NO_DEBRIS_AFTER_DECONSTRUCTION
			holo_machine.power_change()

			if(istype(holo_machine, /obj/machinery/button))
				var/obj/machinery/button/holo_button = holo_machine
				holo_button.setup_device()

/obj/machinery/computer/holodeck/proc/register_contents(obj/structure/closet/storage)
	SIGNAL_HANDLER

	for(var/atom/movable/item as anything in storage.get_all_contents_type(/atom/movable))
		if(item == storage)
			continue
		add_to_spawned(item)

/**
 * A separate proc for objects that weren't loaded by the template nor spawned by holo effects
 * yet need to be added to the list of spawned objects. (e.g. holographic fishes)
 */
/obj/machinery/computer/holodeck/proc/add_to_spawned(atom/holo_atom)
	spawned |= holo_atom
	if(!(obj_flags & EMAGGED) && isitem(holo_atom))
		var/obj/item/to_be_nerfed = holo_atom
		to_be_nerfed.damtype = STAMINA
	finalize_spawned(holo_atom)

///this qdels holoitems that should no longer exist for whatever reason
/obj/machinery/computer/holodeck/proc/derez(atom/movable/holo_atom, silent = TRUE, forced = FALSE)
	spawned -= holo_atom
	if(!holo_atom)
		return
	UnregisterSignal(holo_atom, COMSIG_QDELETING)
	var/turf/target_turf = get_turf(holo_atom)
	for(var/atom/movable/atom_contents as anything in holo_atom) //make sure that things inside of a holoitem are moved outside before destroying it
		if(atom_contents.flags_1 & HOLOGRAM_1) //hologram in hologram is fine
			continue
		atom_contents.forceMove(target_turf)

	if(istype(holo_atom, /obj/item/clothing/under))
		var/obj/item/clothing/under/holo_clothing = holo_atom
		holo_clothing.dump_attachments()

	if(istype(holo_atom, /obj/item/organ))
		var/obj/item/organ/holo_organ = holo_atom
		if(holo_organ.owner) // a mob has the holo organ inside them... oh dear
			to_chat(holo_organ.owner, span_warning("\The [holo_organ] inside of you fades away!"))
	if(!silent)
		visible_message(span_notice("[holo_atom] fades away!"))

	if(is_type_in_list(holo_atom.loc, special_locs))
		qdel(holo_atom.loc)
	qdel(holo_atom)

/obj/machinery/computer/holodeck/proc/remove_from_holo_lists(datum/to_remove, _forced)
	SIGNAL_HANDLER
	spawned -= to_remove
	UnregisterSignal(to_remove, COMSIG_QDELETING)

/obj/machinery/computer/holodeck/process(seconds_per_tick)
	if(damaged && SPT_PROB(5, seconds_per_tick))
		for(var/turf/holo_turf in linked)
			if(SPT_PROB(2.5, seconds_per_tick))
				do_sparks(2, 1, holo_turf)
				return
	if(spawning_simulation)
		return // putting it here because updating power would be pointless we are only loading it
	. = ..()
	if(!. || program == offline_program)//we dont need to scan the holodeck if the holodeck is offline
		update_use_power(IDLE_POWER_USE)
		return

	if(!floorcheck()) //if any turfs in the floor of the holodeck are broken
		emergency_shutdown()
		damaged = TRUE
		visible_message("The holodeck overloads!")
		for(var/turf/holo_turf in linked)
			if(prob(30))
				do_sparks(2, 1, holo_turf)
			SSexplosions.lowturf += holo_turf
			holo_turf.hotspot_expose(1000,500,1)

	if(!(obj_flags & EMAGGED))
		for(var/item in spawned)
			if(!(get_turf(item) in linked))
				derez(item)
	for(var/obj/effect/holodeck_effect/holo_effect as anything in effects)
		holo_effect.tick()
	update_use_power(ACTIVE_POWER_USE)
	update_mode_power_usage(ACTIVE_POWER_USE, initial(active_power_usage) + (spawned.len * 15 + effects.len * 25))

/obj/machinery/computer/holodeck/proc/toggle_power(toggleOn = FALSE)
	if(active == toggleOn)
		return

	if(toggleOn)
		if(last_program && (last_program != offline_program))
			addtimer(CALLBACK(src, PROC_REF(load_program), last_program, TRUE), 2.5 SECONDS)
		active = TRUE
	else
		last_program = program
		load_program(offline_program, TRUE)
		active = FALSE

/obj/machinery/computer/holodeck/power_change()
	. = ..()
	INVOKE_ASYNC(src, PROC_REF(toggle_power), !machine_stat)

///shuts down the holodeck and force loads the offline_program
/obj/machinery/computer/holodeck/proc/emergency_shutdown()
	last_program = program
	active = FALSE
	load_program(offline_program, TRUE)

///returns TRUE if all floors of the holodeck are present, returns FALSE if any are broken or removed
/obj/machinery/computer/holodeck/proc/floorcheck()
	for(var/turf/holo_floor in linked)
		if (is_type_in_typecache(holo_floor, GLOB.typecache_holodeck_linked_floorcheck_ok))
			continue
		return FALSE
	return TRUE

///changes all weapons in the holodeck to do stamina damage if set
/obj/machinery/computer/holodeck/proc/nerf(nerf_this, is_loading = TRUE)
	if (!nerf_this && is_loading)
		return
	for(var/obj/item/to_be_nerfed in spawned)
		to_be_nerfed.damtype = nerf_this ? STAMINA : initial(to_be_nerfed.damtype)
	for(var/obj/effect/holodeck_effect/holo_effect as anything in effects)
		holo_effect.safety(nerf_this)

/obj/machinery/computer/holodeck/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	if(!LAZYLEN(emag_programs))
		balloon_alert(user, "no card swipe port!")
		return FALSE
	playsound(src, SFX_SPARKS, 75, TRUE)
	obj_flags |= EMAGGED
	if (user)
		balloon_alert(user, "safety protocols destroyed") // im gonna keep this once since this perfectly describes it
		to_chat(user, span_warning("You override the safety and security protocols."))
		user.log_message("emagged the Holodeck Control Console.", LOG_GAME)
		message_admins("[ADMIN_LOOKUPFLW(user)] emagged the Holodeck Control Console.")

	say("Warning. Automatic shutoff and derezzing protocols have been corrupted. Please call Nanotrasen maintenance and do not use the simulator.")
	nerf(!(obj_flags & EMAGGED),FALSE)
	return TRUE

/obj/machinery/computer/holodeck/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	emergency_shutdown()

/obj/machinery/computer/holodeck/ex_act(severity, target)
	emergency_shutdown()
	return ..()

/obj/machinery/computer/holodeck/Destroy()
	reset_to_default()
	if(linked)
		linked.linked = null
		linked.energy_usage = list(AREA_USAGE_LEN)
	return ..()

/obj/machinery/computer/holodeck/blob_act(obj/structure/blob/B)
	emergency_shutdown()
	return ..()

#undef HOLODECK_CD
#undef HOLODECK_DMG_CD
