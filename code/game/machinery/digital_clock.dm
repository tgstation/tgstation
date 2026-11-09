/obj/machinery/digital_clock
	name = "digital clock"
	desc = "An ultra-futuristic, sleek, advanced, next-gen normal digital clock that tells the time. Powered by bluespace. Despite supposedly being better in every way to classic clocks, it just doesn't feel the same. They just don't make them the way they used to..."
	icon_state = "digital_clock_base"
	icon = 'icons/obj/digital_clock.dmi'
	verb_say = "beeps"
	verb_ask = "bloops"
	verb_exclaim = "blares"
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4)
	subsystem_type = /datum/controller/subsystem/processing/digital_clock

/obj/item/wallframe/digital_clock
	name = "digital clock frame"
	desc = "Used to build digital clocks, just secure to the wall."
	icon_state = "digital_clock_base"
	icon = 'icons/obj/digital_clock.dmi'
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 4)
	result_path = /obj/machinery/digital_clock
	pixel_shift = 28

/obj/machinery/digital_clock/wrench_act_secondary(mob/living/user, obj/item/tool)
	balloon_alert(user, "[anchored ? "un" : ""]securing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		balloon_alert(user, "[anchored ? "un" : ""]secured")
		deconstruct(TRUE)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/digital_clock/welder_act(mob/living/user, obj/item/tool)
	if(get_integrity() >= max_integrity)
		balloon_alert(user, "it doesn't need repairs!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "repairing display...")
	if(!tool.use_tool(src, user, 4 SECONDS, amount = 0, volume = 50))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "repaired")
	repair_damage(INFINITY)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/digital_clock/atom_fix()
	. = ..()
	set_machine_stat(machine_stat & ~BROKEN)

/obj/machinery/digital_clock/multitool_act(mob/living/user, obj/item/tool)
	if(!(obj_flags & EMAGGED))
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "resetting...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 6 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, vary = TRUE)
		balloon_alert(user, "reset")
		obj_flags &= ~EMAGGED
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/machinery/digital_clock/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	playsound(src, /datum/sound_effect/sparks, 100, vary = TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	do_sparks(3, cardinal_only = FALSE, source = src)
	obj_flags |= EMAGGED
	return TRUE

/obj/machinery/digital_clock/emp_act(severity)
	. = ..()
	emag_act()

/obj/machinery/digital_clock/on_deconstruction(disassembled)
	var/atom/droploc = drop_location()
	if(disassembled)
		new /obj/item/wallframe/digital_clock(droploc)
	else
		new /obj/item/stack/sheet/iron(droploc, 2)
		new /obj/item/shard(droploc)
		new /obj/item/shard(droploc)

/obj/machinery/digital_clock/Initialize(mapload)
	. = ..()
	if(mapload)
		find_and_mount_on_atom()
	AddElement(/datum/element/beauty, 200)
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/digital_clock/process(seconds_per_tick)
	if(!is_operational)
		return
	update_appearance(UPDATE_OVERLAYS)

/obj/machinery/digital_clock/on_set_is_operational(old_value)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)
	if(is_operational)
		set_light(l_range = 1.5, l_power = 0.7, l_color = LIGHT_COLOR_BLUE) // blue light
	else
		set_light(0)

/obj/machinery/digital_clock/update_overlays()
	. = ..()
	if(!is_operational)
		return
	. += get_time_overlays()

#define RETRIEVE_TIME_CACHE_ENTRY(offset_amount, entry_state, cache_list, return_list) \
	do { \
		var/_key = "[offset_amount][entry_state]"; \
		if(!cache_list[_key]) { \
			cache_list[_key] = image(icon = 'icons/obj/digital_clock.dmi', icon_state = "+[entry_state]"); \
			cache_list[_key].pixel_w = offset_amount; \
		} \
		return_list += cache_list[_key]; \
	} while(FALSE)

/obj/machinery/digital_clock/proc/get_time_overlays()
	var/station_minutes = (obj_flags & EMAGGED) ? rand(0, 99) : text2num(round_timestamp(format = "mm"))
	// tenth / the '3' in '31' / 31 -> 3.1 -> 3
	var/station_minute_tenth = station_minutes >= 10 ? round(station_minutes * 0.1) : 0
	// one / the '1' in '31' / 31 -> 31 - (3 * 10) -> 31 - 30 -> 1
	var/station_minute_one = station_minutes - (station_minute_tenth * 10)

	var/station_hours = (obj_flags & EMAGGED) ? rand(0, 99) : text2num(round_timestamp(format = "hh"))
	// one / the '1' in '12' / 12 -> 1.2 -> 1
	var/station_hours_tenth = station_hours >= 10 ? round(station_hours * 0.1) : 0
	// tenth / the '2' in '12' / 12 -> 12 - (1 * 10) -> 12 - 10 -> 2
	var/station_hours_one = station_hours - (station_hours_tenth * 10)

	var/static/list/image/time_overlay_cache
	var/list/return_overlays = list()

	time_overlay_cache ||= list()
	RETRIEVE_TIME_CACHE_ENTRY(0, "separator", time_overlay_cache, return_overlays)
	RETRIEVE_TIME_CACHE_ENTRY(0, station_minute_one, time_overlay_cache, return_overlays)
	RETRIEVE_TIME_CACHE_ENTRY(-4, station_minute_tenth, time_overlay_cache, return_overlays)
	RETRIEVE_TIME_CACHE_ENTRY(-10, station_hours_one, time_overlay_cache, return_overlays)
	RETRIEVE_TIME_CACHE_ENTRY(-14, station_hours_tenth, time_overlay_cache, return_overlays)

	return return_overlays

#undef RETRIEVE_TIME_CACHE_ENTRY

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/digital_clock, 28)
