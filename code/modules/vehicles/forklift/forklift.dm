#define HOLOGRAM_FADE_TIME (15 SECONDS)
#define DESTRUCTIVE_SCAN_COOLDOWN (HOLOGRAM_FADE_TIME + 1 SECONDS)
/**
 * # Forklifts
 */
/obj/vehicle/ridden/forklift
	name = "rapid construction forklift"
	desc = "A forklift for rapidly constructing in an area."
	icon_state = "pussywagon" // TODO: get sprites.
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
	)
	var/starting_module_path = /datum/forklift_module/furniture
	///How many sheets of materials can this hold?
	var/maximum_materials = MINERAL_MATERIAL_AMOUNT * 125 // 125 sheets of materials. Ideally 50 iron, 50 glass, 25 of anything else.
	///What construction holograms do we got?
	var/list/holograms = list()
	COOLDOWN_DECLARE(build_cooldown)
	COOLDOWN_DECLARE(destructive_scan_cooldown)

/obj/vehicle/ridden/forklift/Initialize(mapload)
	. = ..()
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
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/forklift)

/obj/vehicle/ridden/forklift/add_occupant(mob/M, control_flags)
	. = ..()
	if(!.)
		return FALSE
	RegisterSignal(M, COMSIG_MOUSE_SCROLL_ON, .proc/on_scroll_wheel)
	RegisterSignal(M, COMSIG_MOB_CLICKON, .proc/on_click)
	RegisterSignal(M, COMSIG_MOUSE_ENTERED_ON, .proc/on_mouse_entered)
	RegisterSignal(M, COMSIG_MOB_SAY, .proc/fortnite_check)
	var/datum/forklift_module/new_module = new starting_module_path
	new_module.my_forklift = src
	selected_modules[M] = new_module

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
	..()

/obj/vehicle/ridden/forklift/key_inserted()
	START_PROCESSING(SSfastprocess, src)

/obj/vehicle/ridden/forklift/process(delta_time)
	if(COOLDOWN_FINISHED(src, build_cooldown)) // Build a hologram!
		for(var/obj/structure/building_hologram/hologram in holograms)
			if(get_dist(src, hologram) > 7)
				continue
			if(ispath(hologram.typepath_to_build, /turf))
				var/turf/turf_to_replace = get_turf(hologram)
				if(!hologram.turf_place_on_top)
					turf_to_replace.ChangeTurf(hologram.typepath_to_build)
				else
					turf_to_replace.PlaceOnTop(hologram.typepath_to_build)
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
		current_module.on_shift_scrollwheel(source, A, scrolled_up)
	else if(LAZYACCESS(modifiers, CTRL_CLICK))
		current_module.on_ctrl_scrollwheel(source, A, scrolled_up)
	else
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

/obj/vehicle/ridden/forklift/proc/on_mouse_entered(mob/source, atom/A, location, control, params)
	SIGNAL_HANDLER
	var/datum/forklift_module/current_module = selected_modules[source]
	current_module.on_mouse_entered(source, A, location, control, params)


