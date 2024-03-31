#define HOLOGRAM_FADE_TIME (15 SECONDS)
#define DESTRUCTIVE_SCAN_COOLDOWN (HOLOGRAM_FADE_TIME + 1 SECONDS)
/**
 * # Forklifts
 */
/obj/vehicle/ridden/forklift
	name = "rapid construction forklift"
	desc = "A forklift for rapidly constructing in an area."
	icon_state = "rat"
	key_type = /obj/item/key/forklift
	movedelay = 1
	/// What module is selected for each occupant? Different occupants can have different modules selected.
	var/list/datum/forklift_module/selected_modules = list() // list(mob = module)
	/// What forklift modules are available?
	var/list/datum/forklift_module/available_modules = list(
		/datum/forklift_module/furniture,
		/datum/forklift_module/walls,
		/datum/forklift_module/floors,
		/datum/forklift_module/airlocks,
		/datum/forklift_module/shuttle,
	)
	/// The module that a user defaults to when they first enter the forklift.
	var/datum/forklift_module/starting_module_path = /datum/forklift_module/furniture
	/// How many sheets of materials can this hold?
	var/maximum_materials = SHEET_MATERIAL_AMOUNT * 125 // 125 sheets of materials. Ideally 50 iron, 50 glass, 25 of anything else.
	/// What construction holograms do we have?
	var/list/obj/structure/building_hologram/holograms = list()
	/// What path do we use for the ridable component? Needed for key overrides.
	var/ridable_path = /datum/component/riding/vehicle/forklift
	/// Our material container.
	var/datum/component/material_container/material_container
	COOLDOWN_DECLARE(build_cooldown)
	COOLDOWN_DECLARE(destructive_scan_cooldown)
	COOLDOWN_DECLARE(deconstruction_cooldown)

/obj/vehicle/ridden/forklift/Destroy(force)
	QDEL_LIST_ASSOC_VAL(selected_modules)
	QDEL_LIST(holograms)
	QDEL_NULL(material_container)
	return ..()

/obj/vehicle/ridden/forklift/ui_status(mob/living/user, datum/ui_state/state)
	if(!istype(user)) // damn admins
		return !user.client.holder ? UI_CLOSE : UI_INTERACTIVE
	if(isnull(inserted_key))
		return UI_CLOSE
	if(!user.Adjacent(src))
		return UI_UPDATE
	return UI_INTERACTIVE

/obj/vehicle/ridden/forklift/verb/fucking_interact()
	set name = "Forklift Management Console"
	set category = "Object"
	set src in view(1)
	ui_interact(usr)

/obj/vehicle/ridden/forklift/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ConstructionForklift")
		ui.open()

/obj/vehicle/ridden/forklift/ui_data(mob/user)
	var/list/data = list()

	data["materials"] = list(
		"storage_max" = material_container.max_amount,
		"storage_now" = material_container.total_amount(),
		"storage" = list(),
	)
	for(var/datum/material/material_singleton as anything in material_container.materials)
		data["materials"]["storage"][material_singleton.name] = material_container.materials[material_singleton]

	data["modules"] = list(
		"active_ref" = REF(selected_modules[user].type),
		"available" = list(),
	)
	for(var/datum/forklift_module/module_type as anything in available_modules)
		data["modules"]["available"][REF(module_type)] = module_type.name

	data["cooldowns"] = list()
	data["cooldowns"]["build"] = COOLDOWN_TIMELEFT(src, build_cooldown)
	data["cooldowns"]["scan"] = COOLDOWN_TIMELEFT(src, destructive_scan_cooldown)
	data["cooldowns"]["deconstruct"] = COOLDOWN_TIMELEFT(src, deconstruction_cooldown)

	data["holograms"] = length(holograms)

	return data

/obj/vehicle/ridden/forklift/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(!..())
		return

	switch(action)
		if("set-active")
			var/module_type_ref = params["new_module_ref"]
			var/datum/forklift_module/module_type = locate(module_type_ref) in available_modules
			if(isnull(module_type))
				return FALSE
			set_active_module(ui.user, module_type)
			return TRUE

		if("interact-module")
			selected_modules[ui.user]?.ui_interact(ui.user)
			return TRUE

		if("scan")
			return TRUE

		if("deconstruct")
			return TRUE

		else
			stack_trace("unknown forklift ui action '[action]'")
			return FALSE

/obj/vehicle/ridden/forklift/Initialize(mapload)
	. = ..()
	add_overlay(image(icon, "rat_overlays", ABOVE_MOB_LAYER))
	var/static/list/materials_list = list(
		/datum/material/iron,
		/datum/material/glass,
		/datum/material/silver,
		/datum/material/gold,
		/datum/material/diamond,
		/datum/material/plasma,
		/datum/material/uranium,
		/datum/material/bananium,
		/datum/material/titanium,
		/datum/material/bluespace,
		/datum/material/plastic,
		/datum/material/wood,
		)
	material_container = LoadComponent(/datum/component/material_container, materials_list, maximum_materials, MATCONTAINER_EXAMINE, allowed_items = /obj/item/stack)
	AddElement(/datum/element/ridable, ridable_path)

/obj/vehicle/ridden/forklift/add_occupant(mob/M, control_flags)
	. = ..()
	if(!.)
		return FALSE
	RegisterSignal(M, COMSIG_MOUSE_SCROLL_ON, PROC_REF(on_scroll_wheel))
	RegisterSignal(M, COMSIG_MOB_CLICKON, PROC_REF(on_click))
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(fortnite_check))
	RegisterSignal(M, COMSIG_MOUSE_ENTERED_ON_CHEAP, PROC_REF(on_mouse_entered))
	var/datum/forklift_module/new_module = new starting_module_path
	new_module.my_forklift = src
	selected_modules[M] = new_module

// Officially requested by the headcoder.
/obj/vehicle/ridden/forklift/proc/fortnite_check(mob/living/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(!findtext(message, "fortnite"))
		return

	var/static/list/already_judged = list()
	var/their_ref = REF(source)
	if(their_ref in already_judged)
		return
	already_judged += their_ref

	var/smite_timer_id = addtimer(CALLBACK(src, PROC_REF(fortnite_smite), source), 10 SECONDS, TIMER_UNIQUE | TIMER_STOPPABLE)
	var/admin_href_pardon = "<b><u><a href='?_src_=[REF(src)];[HrefToken(forceGlobal = TRUE)];pardon_id=[smite_timer_id];pardon_ckey=\"[source.ckey]\"'>pardon</a></u></b>"
	to_chat(source, span_userdanger("You feel a sudden chill run down your spine."))
	message_admins(span_adminnotice("[key_name_admin(source)] has angered the Forklift Gods. You have ten seconds to [admin_href_pardon] them!"))

/obj/vehicle/ridden/forklift/proc/fortnite_smite(mob/living/poor_soul)
	poor_soul.balloon_alert_to_viewers("smited by God for [poor_soul.p_their()] crimes!")
	poor_soul.gib(TRUE)

/obj/vehicle/ridden/forklift/Topic(href, list/href_list)
	if(!("pardon_id" in href_list))
		return ..()

	var/smite_timer_id = text2num(href_list["pardon_id"])
	if(!timeleft(smite_timer_id))
		return // too late to save them; or too slow and someone else already did.

	deltimer(text2num(smite_timer_id))
	message_admins(span_adminnotice("[key_name_admin(src)] has pardoned [key_name_admin(href_list["pardon_ckey"])]"))

/obj/vehicle/ridden/forklift/remove_occupant(mob/M)
	UnregisterSignal(M, list(COMSIG_MOUSE_SCROLL_ON, COMSIG_MOB_CLICKON, COMSIG_MOUSE_ENTERED_ON_CHEAP, COMSIG_MOB_SAY))
	qdel(selected_modules[M])
	..()

/obj/vehicle/ridden/forklift/on_key_inserted()
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/ridden/forklift/process(delta_time)
	var/currently_building = FALSE
	var/currently_deconstructing = FALSE
	for(var/obj/structure/building_hologram/found_hologram as anything in holograms)
		if(get_dist(src, found_hologram) > 7)
			continue
		if(istype(found_hologram, /obj/structure/building_hologram/deconstruction))
			if(currently_deconstructing)
				continue
			if(found_hologram.building)
				currently_deconstructing = TRUE
				continue
		else
			if(currently_building)
				continue
			if(found_hologram.building)
				currently_building = TRUE
				continue
		found_hologram.begin_building()
		break

	if(COOLDOWN_FINISHED(src, destructive_scan_cooldown))
		COOLDOWN_START(src, destructive_scan_cooldown, DESTRUCTIVE_SCAN_COOLDOWN)
		//rcd_scan(src, play_sound = FALSE)
	..()

/obj/vehicle/ridden/forklift/key_removed()
	STOP_PROCESSING(SSfastprocess, src)

/obj/vehicle/ridden/forklift/proc/set_active_module(mob/user, datum/forklift_module/module_type)
	if(selected_modules[user]?.type == module_type)
		return
	var/datum/forklift_module/old_module = selected_modules[user]

	var/datum/forklift_module/new_module = new module_type
	selected_modules[user] = new_module
	new_module.my_forklift = src
	if(isnull(old_module))
		return

	new_module.last_turf_moused_over = old_module.last_turf_moused_over
	LAZYREMOVE(user.client.images, old_module.preview_image)
	qdel(old_module.preview_image)
	new_module.update_preview_icon()
	new_module.preview_image.loc = new_module.last_turf_moused_over
	LAZYOR(user.client.images, new_module.preview_image)
	balloon_alert(user, new_module.name)
	qdel(old_module)

/obj/vehicle/ridden/forklift/proc/on_scroll_wheel(mob/source, atom/A, delta_x, delta_y, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params)
	var/scrolled_up = (delta_y > 0)
	var/datum/forklift_module/current_module = selected_modules[source]
	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		var/datum/forklift_module/next_module
		if(scrolled_up)
			next_module = next_list_item(current_module.type, available_modules)
		else
			next_module = previous_list_item(current_module.type, available_modules)
		set_active_module(source, next_module)

	else if(LAZYACCESS(modifiers, CTRL_CLICK))
		current_module.on_ctrl_scrollwheel(source, A, scrolled_up)

	else if(LAZYACCESS(modifiers, ALT_CLICK))
		current_module.on_alt_scrollwheel(source, A, scrolled_up)

	else
		current_module.on_scrollwheel(source, A, scrolled_up)

/obj/vehicle/ridden/forklift/proc/on_click(mob/source, atom/clickingon, list/modifiers)
	SIGNAL_HANDLER
	if(modifiers[ALT_CLICK] || modifiers[SHIFT_CLICK])
		return // Allow removing the keys from the forklift and examining things.
	if(clickingon == src)
		return // Allow the person to unbuckle from the forklift.
	if(!inserted_key)
		balloon_alert(source, "no key!")
		return // No key, can't do shit.
	var/datum/forklift_module/current_module = selected_modules[source]
	if(modifiers[RIGHT_CLICK])
		current_module.on_right_click(source, clickingon)
		return COMSIG_MOB_CANCEL_CLICKON
	else if(modifiers[LEFT_CLICK])
		current_module.on_left_click(source, clickingon)
		return COMSIG_MOB_CANCEL_CLICKON
	else if(modifiers[MIDDLE_CLICK])
		current_module.on_middle_click(source, clickingon)
		return COMSIG_MOB_CANCEL_CLICKON

/obj/vehicle/ridden/forklift/proc/on_mouse_entered(mob/source, atom/A)
	SIGNAL_HANDLER
	var/datum/forklift_module/current_module = selected_modules[source]
	current_module.on_mouse_entered(source, A)

/obj/vehicle/ridden/forklift/engineering
	name = "engineering forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Days since supermatter incident: 0\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/furniture,
		/datum/forklift_module/walls,
		/datum/forklift_module/floors,
		/datum/forklift_module/airlocks,
		/datum/forklift_module/shuttle,
		/datum/forklift_module/lighting,
		/datum/forklift_module/department_machinery/engineering,
		// /datum/forklift_module/atmos,
	)
	icon = 'icons/obj/vehicles_large.dmi'
	pixel_x = -16
	pixel_y = -16
	starting_module_path = /datum/forklift_module/furniture
	key_type = /obj/item/key/forklift/engineering
	ridable_path = /datum/component/riding/vehicle/forklift/engineering

/obj/vehicle/ridden/forklift/medical
	name = "medical forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Clean hands save lives!\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/plumbing,
		/datum/forklift_module/department_machinery/medical,
	)
	starting_module_path = /datum/forklift_module/plumbing
	key_type = /obj/item/key/forklift/medbay
	ridable_path = /datum/component/riding/vehicle/forklift/medical

/obj/vehicle/ridden/forklift/science
	name = "science forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Have you read your SICP today?\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/plumbing,
		// /datum/forklift_module/atmos,
		/datum/forklift_module/department_machinery/science,
	)
	starting_module_path = /datum/forklift_module/plumbing
	key_type = /obj/item/key/forklift/science
	ridable_path = /datum/component/riding/vehicle/forklift/science

/obj/vehicle/ridden/forklift/security
	name = "security forklift"
	desc = "A forklift for rapidly constructing in an area. It's lifted, and there's a pair of truck nuts dangling from the hitch on the back."
	available_modules = list(
		/datum/forklift_module/department_machinery/security,
	)
	starting_module_path = /datum/forklift_module/department_machinery/security
	key_type = /obj/item/key/forklift/security
	ridable_path = /datum/component/riding/vehicle/forklift/security

/obj/vehicle/ridden/forklift/service
	name = "service forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"How's my driving? PDA the HoP!\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/department_machinery/service,
	)
	starting_module_path = /datum/forklift_module/department_machinery/service
	key_type = /obj/item/key/forklift/service
	ridable_path = /datum/component/riding/vehicle/forklift/service

/obj/vehicle/ridden/forklift/cargo
	name = "cargo forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Every worker a member of the board!\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/department_machinery/cargo,
	)
	starting_module_path = /datum/forklift_module/department_machinery/cargo
	key_type = /obj/item/key/forklift/cargo
	ridable_path = /datum/component/riding/vehicle/forklift/cargo

#undef HOLOGRAM_FADE_TIME
#undef DESTRUCTIVE_SCAN_COOLDOWN
