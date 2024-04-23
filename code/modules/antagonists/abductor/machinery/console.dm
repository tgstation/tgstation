/proc/get_abductor_console(team_number)
	for(var/obj/machinery/abductor/console/C as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/abductor/console))
		if(C.team_number == team_number)
			return C

//Common

/obj/machinery/abductor
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	use_power = NO_POWER_USE
	var/team_number = 0

//Console

/obj/machinery/abductor/console
	name = "abductor console"
	desc = "Ship command center."
	icon = 'icons/obj/antags/abductor.dmi'
	icon_state = "console"
	density = TRUE
	var/obj/item/abductor/gizmo/gizmo
	var/obj/item/clothing/suit/armor/abductor/vest/vest
	var/obj/machinery/abductor/experiment/experiment
	var/obj/machinery/abductor/pad/pad
	var/obj/machinery/computer/camera_advanced/abductor/camera
	var/list/datum/icon_snapshot/disguises = list()
	/// Currently selected gear category
	var/selected_cat
	/// Dictates if the compact mode of the interface is on or off
	var/compact_mode = FALSE
	/// Possible gear to be dispensed
	var/list/possible_gear

/obj/machinery/abductor/console/Initialize(mapload)
	. = ..()
	possible_gear = get_abductor_gear()

/obj/machinery/abductor/console/Destroy()
	if(gizmo)
		gizmo.console = null
		gizmo = null
	if(experiment)
		experiment.console = null
		experiment = null
	if(pad)
		pad.console = null
		pad = null
	if(camera)
		camera.console = null
		camera = null
	return ..()

/**
 * get_abductor_gear: Returns a list of a filtered abductor gear sorted by categories
 */
/obj/machinery/abductor/console/proc/get_abductor_gear()
	var/list/filtered_modules = list()
	for(var/path in GLOB.abductor_gear)
		var/datum/abductor_gear/AG = new path
		if(!filtered_modules[AG.category])
			filtered_modules[AG.category] = list()
		filtered_modules[AG.category][AG] = AG
	return filtered_modules

/obj/machinery/abductor/console/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!HAS_MIND_TRAIT(user, TRAIT_ABDUCTOR_TRAINING))
		to_chat(user, span_warning("You start mashing alien buttons at random!"))
		if(do_after(user,100, target = src))
			TeleporterSend()

/obj/machinery/abductor/console/ui_status(mob/user, datum/ui_state/state)
	if(!isabductor(user) && !isobserver(user))
		return UI_CLOSE
	return ..()

/obj/machinery/abductor/console/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/abductor/console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AbductorConsole", name)
		ui.open()

/obj/machinery/abductor/console/ui_static_data(mob/user)
	var/list/data = list()
	data["categories"] = list()
	for(var/category in possible_gear)
		var/list/cat = list(
			"name" = category,
			"items" = (category == selected_cat ? list() : null))
		for(var/gear in possible_gear[category])
			var/datum/abductor_gear/AG = possible_gear[category][gear]
			cat["items"] += list(list(
				"name" = AG.name,
				"cost" = AG.cost,
				"desc" = AG.description,
			))
		data["categories"] += list(cat)
	return data

/obj/machinery/abductor/console/ui_data(mob/user)
	var/list/data = list()
	data["compactMode"] = compact_mode
	data["experiment"] = experiment ? TRUE : FALSE
	if(experiment)
		data["points"] = experiment.points
		data["credits"] = experiment.credits
	data["pad"] = pad ? TRUE : FALSE
	if(pad)
		data["gizmo"] = gizmo && gizmo.marked_target_weakref?.resolve() ? TRUE : FALSE
	data["vest"] = vest ? TRUE : FALSE
	if(vest)
		data["vest_mode"] = vest.mode
		data["vest_lock"] = HAS_TRAIT_FROM(vest, TRAIT_NODROP, ABDUCTOR_VEST_TRAIT)
	return data

/obj/machinery/abductor/console/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("buy")
			var/item_name = params["name"]
			var/list/buyable_items = list()
			for(var/category in possible_gear)
				buyable_items += possible_gear[category]
			for(var/key in buyable_items)
				var/datum/abductor_gear/AG = buyable_items[key]
				if(AG.name == item_name)
					Dispense(AG.build_path, AG.cost)
					return TRUE
		if("teleporter_send")
			TeleporterSend()
			return TRUE
		if("teleporter_retrieve")
			TeleporterRetrieve()
			return TRUE
		if("flip_vest")
			FlipVest()
			return TRUE
		if("toggle_vest")
			if(!vest)
				return
			vest.toggle_nodrop()
			return TRUE
		if("select_disguise")
			SelectDisguise()
			return TRUE
		if("select")
			selected_cat = params["category"]
			return TRUE
		if("compact_toggle")
			compact_mode = !compact_mode
			return TRUE

/obj/machinery/abductor/console/proc/TeleporterRetrieve()
	var/mob/living/marked = gizmo.marked_target_weakref?.resolve()
	if(pad && marked)
		pad.Retrieve(marked)

/obj/machinery/abductor/console/proc/TeleporterSend()
	if(pad)
		pad.Send()

/obj/machinery/abductor/console/proc/FlipVest()
	if(vest)
		vest.flip_mode()

/obj/machinery/abductor/console/proc/SelectDisguise(remote = FALSE)
	var/list/disguises2 = list()
	for(var/name in disguises)
		var/datum/icon_snapshot/snap = disguises[name]
		var/image/dummy = image(snap.icon, src, snap.icon_state)
		dummy.overlays = snap.overlays
		disguises2[name] = dummy

	var/entry_name
	if(remote)
		entry_name = show_radial_menu(usr, camera.eyeobj, disguises2, tooltips = TRUE)
	else
		entry_name = show_radial_menu(usr, src, disguises2, require_near = TRUE, tooltips = TRUE)

	var/datum/icon_snapshot/chosen = disguises[entry_name]
	if(chosen && vest && (remote || in_range(usr,src)))
		vest.SetDisguise(chosen)

/obj/machinery/abductor/console/proc/SetDroppoint(turf/open/location,user)
	if(!istype(location))
		to_chat(user, span_warning("That place is not safe for the specimen."))
		return

	if(pad)
		pad.teleport_target = location
		to_chat(user, span_notice("Location marked as test subject release point."))

/obj/machinery/abductor/console/post_machine_initialize()
	. = ..()
	if(!team_number)
		return

	for(var/obj/machinery/abductor/pad/p as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/abductor/pad))
		if(p.team_number == team_number)
			pad = p
			pad.console = src
			break

	for(var/obj/machinery/abductor/experiment/e as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/abductor/experiment))
		if(e.team_number == team_number)
			experiment = e
			e.console = src

	for(var/obj/machinery/computer/camera_advanced/abductor/c as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/camera_advanced/abductor))
		if(c.team_number == team_number)
			camera = c
			c.console = src

/obj/machinery/abductor/console/proc/AddSnapshot(mob/living/carbon/human/target)
	if(target.can_block_magic(MAGIC_RESISTANCE_MIND, charge_cost = 0))
		say("Unable to get a proper scan of subject! Something is shielding [target]'s mind!")
		return
	var/datum/icon_snapshot/entry = new
	entry.name = target.name
	entry.icon = target.icon
	entry.icon_state = target.icon_state
	entry.overlays = target.get_overlays_copy(list(HANDS_LAYER)) //ugh
	//Update old disguise instead of adding new one
	if(disguises[entry.name])
		disguises[entry.name] = entry
		return
	disguises[entry.name] = entry

/obj/machinery/abductor/console/proc/AddGizmo(obj/item/abductor/gizmo/G)
	if(G == gizmo && G.console == src)
		return FALSE

	if(G.console)
		G.console.gizmo = null

	gizmo = G
	G.console = src
	return TRUE

/obj/machinery/abductor/console/proc/AddVest(obj/item/clothing/suit/armor/abductor/vest/V)
	if(vest == V)
		return FALSE

	for(var/obj/machinery/abductor/console/C as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/abductor/console))
		if(C.vest == V)
			C.vest = null
			break

	vest = V
	return TRUE

/obj/machinery/abductor/console/attackby(obj/O, mob/user, params)
	if(istype(O, /obj/item/abductor/gizmo) && AddGizmo(O))
		to_chat(user, span_notice("You link the tool to the console."))
	else if(istype(O, /obj/item/clothing/suit/armor/abductor/vest) && AddVest(O))
		to_chat(user, span_notice("You link the vest to the console."))
	else
		return ..()

/obj/machinery/abductor/console/proc/Dispense(items_list, cost=1)
	if(experiment && experiment.credits >= cost)
		experiment.credits -=cost
		say("Incoming supply!")
		var/drop_location = loc
		if(pad)
			flick("alien-pad", pad)
			drop_location = pad.loc
		for(var/each_item in items_list)
			for(var/i in 1 to items_list[each_item])
				new each_item(drop_location)
	else
		say("Insufficent data!")
