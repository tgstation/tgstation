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
	///What module is selected for each occupant? Different occupants can have different modules selected.
	var/list/selected_modules = list() // list(mob = module)
	///What forklift modules are available?
	var/list/available_modules = list(
		/datum/forklift_module/furniture,
		/datum/forklift_module/walls,
		/datum/forklift_module/floors,
		/datum/forklift_module/airlocks,
		/datum/forklift_module/shuttle,
	)
	var/starting_module_path = /datum/forklift_module/furniture
	///How many sheets of materials can this hold?
	var/maximum_materials = SHEET_MATERIAL_AMOUNT * 125 // 125 sheets of materials. Ideally 50 iron, 50 glass, 25 of anything else.
	///What construction holograms do we got?
	var/list/holograms = list()
	///What path do we use for the ridable component? Needed for key overrides.
	var/ridable_path = /datum/component/riding/vehicle/forklift
	///What upgrades have been applied?
	var/list/applied_upgrades = list()
	/// Our mouse movement catchers.
	var/list/mouse_catchers = list()
	COOLDOWN_DECLARE(build_cooldown)
	COOLDOWN_DECLARE(destructive_scan_cooldown)
	COOLDOWN_DECLARE(deconstruction_cooldown)

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
	AddComponent(/datum/component/material_container, materials_list, maximum_materials, MATCONTAINER_EXAMINE, allowed_items=/obj/item/stack)
	AddElement(/datum/element/ridable, ridable_path)

/obj/vehicle/ridden/forklift/add_occupant(mob/M, control_flags)
	. = ..()
	if(!.)
		return FALSE
	RegisterSignal(M, COMSIG_MOUSE_SCROLL_ON, .proc/on_scroll_wheel)
	RegisterSignal(M, COMSIG_MOB_CLICKON, .proc/on_click)
	RegisterSignal(M, COMSIG_MOB_SAY, .proc/fortnite_check)
	var/datum/forklift_module/new_module = new starting_module_path
	new_module.my_forklift = src
	selected_modules[M] = new_module
	var/atom/movable/screen/fullscreen/cursor_catcher/mouse_catcher = M.overlay_fullscreen("forklift", /atom/movable/screen/fullscreen/cursor_catcher/lock_on, 0)
	mouse_catcher.assign_to_mob(M)
	mouse_catchers[M] = mouse_catcher

// Officially requested by the headcoder.
/obj/vehicle/ridden/forklift/proc/fortnite_check(mob/source, list/speech_args)
	SIGNAL_HANDLER
	var/message = speech_args[SPEECH_MESSAGE]
	if(findtext(message, "fortnite"))
		source.balloon_alert_to_viewers("smited by God for [source.p_their()] crimes!")
		var/mob/living/living_mob = source
		living_mob.gib(TRUE) // no coming back from fortnite

/obj/vehicle/ridden/forklift/remove_occupant(mob/M)
	UnregisterSignal(M, list(COMSIG_MOUSE_SCROLL_ON, COMSIG_MOB_CLICKON, COMSIG_MOUSE_ENTERED_ON, COMSIG_MOB_SAY))
	qdel(selected_modules[M])
	qdel(mouse_catchers[M])
	..()

/obj/vehicle/ridden/forklift/key_inserted()
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/ridden/forklift/process(delta_time)
	for(var/riding_mob in occupants)
		if(mouse_catchers[riding_mob])
			var/atom/movable/screen/fullscreen/cursor_catcher/mouse_catcher = mouse_catchers[riding_mob]
			if(mouse_catcher.mouse_params)
				mouse_catcher.calculate_params()
			if(mouse_catcher.given_turf)
				var/datum/forklift_module/current_module = selected_modules[riding_mob]
				current_module.on_mouse_entered(riding_mob, mouse_catcher.given_turf)
	if(COOLDOWN_FINISHED(src, build_cooldown)) // Build a hologram!
		for(var/obj/structure/building_hologram/hologram in holograms)
			if(get_dist(src, hologram) > 7)
				continue
			if(ispath(hologram.typepath_to_build, /turf))
				var/turf/turf_to_replace = get_turf(hologram)
				if(!hologram.turf_place_on_top)
					turf_to_replace.ChangeTurf(hologram.typepath_to_build)
				else
					turf_to_replace.place_on_top(hologram.typepath_to_build)
			else
				var/atom/built_atom = new hologram.typepath_to_build(get_turf(hologram))
				hologram.after_build(built_atom)
			playsound(hologram, 'sound/machines/click.ogg', 50, TRUE)
			COOLDOWN_START(src, build_cooldown, hologram.build_length)
			hologram.give_refund = FALSE
			qdel(hologram)
			break

	if(COOLDOWN_FINISHED(src, destructive_scan_cooldown))
		COOLDOWN_START(src, destructive_scan_cooldown, DESTRUCTIVE_SCAN_COOLDOWN)
		rcd_scan(src, play_sound = FALSE)
	..()

/obj/vehicle/ridden/forklift/key_removed()
	STOP_PROCESSING(SSfastprocess, src)

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
		next_module = new next_module
		next_module.my_forklift = src
		next_module.last_turf_moused_over = current_module.last_turf_moused_over
		LAZYREMOVE(source.client.images, current_module.preview_image)
		qdel(current_module.preview_image)
		next_module.update_preview_icon()
		next_module.preview_image.loc = next_module.last_turf_moused_over
		LAZYOR(source.client.images, next_module.preview_image)
		selected_modules[source] = next_module
		balloon_alert(source, next_module.name)
		qdel(current_module)
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

/obj/vehicle/ridden/forklift/engineering
	name = "engineering forklift"
	desc = "A forklift for rapidly constructing in an area. Has a \"Days since supermatter incident: 0\" sticker on the back."
	available_modules = list(
		/datum/forklift_module/furniture,
		/datum/forklift_module/walls,
		/datum/forklift_module/floors,
		/datum/forklift_module/airlocks,
		/datum/forklift_module/shuttle,
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
