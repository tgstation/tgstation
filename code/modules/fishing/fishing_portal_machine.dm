/obj/machinery/fishing_portal_generator
	name = "fish-porter 3000"
	desc = "Fishing anywhere, anytime... anyway what was I talking about?"
	icon = 'icons/obj/fishing.dmi'
	icon_state = "portal"
	idle_power_usage = 0
	active_power_usage = BASE_MACHINE_ACTIVE_CONSUMPTION * 2
	anchored = FALSE
	density = TRUE
	circuit = /obj/item/circuitboard/machine/fishing_portal_generator

	///The current fishing spot loaded in
	var/datum/component/fishing_spot/active
	///A list of fishing spot it's linked to with a multitool.
	var/list/linked_fishing_spots
	///The maximum number of fishing spots it can be linked to
	var/max_fishing_spots = 1
	///If true, the fishing portal can stay connected to a linked fishing spot even on different z-levels
	var/long_range_link = FALSE

/obj/machinery/fishing_portal_generator/Initialize(mapload)
	. = ..()
	var/static/list/tool_screentips = list(
		TOOL_MULTITOOL = list(
			SCREENTIP_CONTEXT_LMB = "Link",
			SCREENTIP_CONTEXT_RMB = "Unlink fishing spots"
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_screentips)
	ADD_TRAIT(src, TRAIT_UNLINKABLE_FISHING_SPOT, INNATE_TRAIT)

/obj/machinery/fishing_portal_generator/Destroy()
	deactivate()
	linked_fishing_spots = null
	return ..()

///Higher tier parts let you link to more fishing spots at once and eventually let you connect through different zlevels.
/obj/machinery/fishing_portal_generator/RefreshParts()
	. = ..()
	max_fishing_spots = 0
	long_range_link = FALSE
	for(var/datum/stock_part/matter_bin/matter_bin in component_parts)
		max_fishing_spots += matter_bin.tier * 0.5
	max_fishing_spots = ROUND_UP(max_fishing_spots)
	for(var/datum/stock_part/capacitor/capacitor in component_parts)
		if(capacitor.tier >= 3)
			long_range_link = TRUE
	if(!long_range_link)
		check_fishing_spot_z()
	if(length(linked_fishing_spots) > max_fishing_spots)
		if(active)
			deactivate()
		linked_fishing_spots.len = max_fishing_spots

/obj/machinery/fishing_portal_generator/on_set_panel_open()
	update_appearance()
	return ..()

/obj/machinery/fishing_portal_generator/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/fishing_portal_generator/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(machine_stat & NOPOWER)
		balloon_alert(user, "no power!")
		return ITEM_INTERACT_BLOCKING
	var/unlink = tool.buffer == src
	tool.set_buffer(unlink ? null : src)
	balloon_alert(user, "fish-porter [unlink ? "un" : ""]linked")
	if(!unlink)
		tool.item_flags |= ITEM_HAS_CONTEXTUAL_SCREENTIPS
		RegisterSignal(tool, COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, PROC_REF(multitool_context))
		RegisterSignal(tool, COMSIG_MULTITOOL_REMOVE_BUFFER, PROC_REF(multitool_unbuffered))
	return ITEM_INTERACT_SUCCESS

/obj/machinery/fishing_portal_generator/multitool_act_secondary(mob/living/user, obj/item/tool)
	if(machine_stat & NOPOWER)
		balloon_alert(user, "no power!")
		return ITEM_INTERACT_BLOCKING
	if(!length(linked_fishing_spots))
		balloon_alert(user, "nothing to unlink!")
		return ITEM_INTERACT_BLOCKING
	var/list/fishing_list = list()
	var/id = 1
	for(var/atom/spot as anything in linked_fishing_spots)
		var/choice_name = "[spot.name] ([id])"
		fishing_list[choice_name] = spot
		id++
	var/list/choices = list()
	for(var/radial_name in fishing_list)
		var/datum/fish_source/source = fishing_list[radial_name]
		var/mutable_appearance/appearance = mutable_appearance('icons/hud/radial_fishing.dmi', source.radial_state)
		appearance.add_overlay('icons/hud/radial_fishing.dmi', "minus_sign")
		choices[radial_name] = appearance

	var/choice = show_radial_menu(user, src, choices, radius = 38, custom_check = CALLBACK(src, TYPE_PROC_REF(/atom, can_interact), user), tooltips = TRUE)
	if(!choice)
		return
	var/atom/spot = fishing_list[choice]
	if(QDELETED(spot) || !(spot in linked_fishing_spots) || !can_interact(user))
		return
	unlink_fishing_spot(spot)
	balloon_alert(user, "fishing spot unlinked")

/obj/machinery/fishing_portal_generator/proc/multitool_context(obj/item/source, list/context, atom/target, mob/living/user)
	SIGNAL_HANDLER
	if(HAS_TRAIT(target, TRAIT_FISHING_SPOT) && !HAS_TRAIT(target, TRAIT_UNLINKABLE_FISHING_SPOT))
		context[SCREENTIP_CONTEXT_LMB] = "Link to fish-porter"
		return CONTEXTUAL_SCREENTIP_SET
	return NONE

/obj/machinery/fishing_portal_generator/proc/multitool_unbuffered(datum/source, datum/buffer)
	SIGNAL_HANDLER
	UnregisterSignal(source, list(COMSIG_ITEM_REQUESTING_CONTEXT_FOR_TARGET, COMSIG_MULTITOOL_REMOVE_BUFFER))

///Called when using a multitool on any other fishing source.
/obj/machinery/fishing_portal_generator/proc/link_fishing_spot(datum/fish_source/source, atom/spot, mob/living/user)
	if(istype(spot, /obj/machinery/fishing_portal_generator)) //Don't link it to itself or other fishing portals.
		return
	if(length(linked_fishing_spots) >= max_fishing_spots)
		spot.balloon_alert(user, "cannot link more!")
		return ITEM_INTERACT_BLOCKING
	for(var/other_spot in linked_fishing_spots)
		var/datum/fish_source/stored = linked_fishing_spots[other_spot]
		if(stored == source)
			spot.balloon_alert(user, "already linked!")
			playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 15, FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
			return ITEM_INTERACT_BLOCKING
	if(HAS_TRAIT(spot, TRAIT_UNLINKABLE_FISHING_SPOT))
		spot.balloon_alert(user, "unlinkable fishing spot!")
		playsound(src, 'sound/machines/buzz/buzz-sigh.ogg', 15, FALSE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
		return ITEM_INTERACT_BLOCKING
	LAZYSET(linked_fishing_spots, spot, source)
	RegisterSignal(spot, SIGNAL_REMOVETRAIT(TRAIT_FISHING_SPOT), PROC_REF(unlink_fishing_spot))
	spot.balloon_alert(user, "fishing spot linked")
	playsound(spot, 'sound/machines/ping.ogg', 15, TRUE, extrarange = SHORT_RANGE_SOUND_EXTRARANGE)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/fishing_portal_generator/proc/unlink_fishing_spot(atom/spot)
	SIGNAL_HANDLER
	var/datum/fish_source/source = linked_fishing_spots[spot]
	if(active?.fish_source == source)
		deactivate()
	LAZYREMOVE(linked_fishing_spots, spot)
	UnregisterSignal(spot, SIGNAL_REMOVETRAIT(TRAIT_FISHING_SPOT))

/obj/machinery/fishing_portal_generator/examine(mob/user)
	. = ..()
	. += span_notice("You can unlock further portal settings by completing fish scanning experiments, \
		or by connecting it to other fishing spots with a multitool.")

/obj/machinery/fishing_portal_generator/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "syndicate setting loaded")
	playsound(src, SFX_SPARKS, 25, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	return TRUE

/obj/machinery/fishing_portal_generator/interact(mob/user)
	. = ..()
	if(active)
		deactivate()
	else
		select_fish_source(user)

/obj/machinery/fishing_portal_generator/update_overlays()
	. = ..()
	if(panel_open)
		. += "portal_open"
	if(!active)
		return
	. += "portal_on"
	var/datum/fish_source/portal = active.fish_source
	. += portal.overlay_state
	. += emissive_appearance(icon, "portal_emissive", src)

/obj/machinery/fishing_portal_generator/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	check_fishing_spot_z()

/obj/machinery/fishing_portal_generator/proc/check_fishing_spot_z()
	if(!active || long_range_link || istype(active.fish_source, /datum/fish_source/portal))
		return
	var/turf/new_turf = get_turf(src)
	if(!new_turf)
		deactivate()
		return
	for(var/atom/spot as anything in linked_fishing_spots)
		if(linked_fishing_spots[spot] != active.fish_source)
			continue
		var/turf/turf = get_turf(spot)
		if(turf.z != new_turf.z && !(is_station_level(turf.z) && is_station_level(new_turf.z)))
			deactivate()

/obj/machinery/fishing_portal_generator/proc/activate(datum/fish_source/selected_source, mob/user)
	if(QDELETED(selected_source))
		return
	if(machine_stat & NOPOWER)
		balloon_alert(user, "no power!")
		return ITEM_INTERACT_BLOCKING
	if(!istype(selected_source, /datum/fish_source/portal)) //likely from a linked fishing spot
		var/abort = TRUE
		for(var/atom/spot as anything in linked_fishing_spots)
			if(linked_fishing_spots[spot] != selected_source)
				continue
			if(long_range_link)
				abort = FALSE
			var/turf/spot_turf = get_turf(spot)
			var/turf/turf = get_turf(src)
			if(turf.z == spot_turf.z || (is_station_level(turf.z) && is_station_level(spot_turf.z)))
				abort = FALSE
			if(!abort)
				RegisterSignal(spot, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_fishing_spot_z_level_changed))
			break
		if(abort)
			balloon_alert(user, "cannot reach linked!")
			return

	active = AddComponent(/datum/component/fishing_spot, selected_source)
	ADD_TRAIT(src, TRAIT_CATCH_AND_RELEASE, INNATE_TRAIT)
	if(use_power != NO_POWER_USE)
		use_power = ACTIVE_POWER_USE
	update_icon()

/obj/machinery/fishing_portal_generator/proc/deactivate()
	if(!active)
		return
	if(!istype(active.fish_source, /datum/fish_source/portal))
		for(var/atom/spot as anything in linked_fishing_spots)
			if(linked_fishing_spots[spot] == active.fish_source)
				UnregisterSignal(spot, COMSIG_MOVABLE_Z_CHANGED)
	QDEL_NULL(active)

	REMOVE_TRAIT(src, TRAIT_CATCH_AND_RELEASE, INNATE_TRAIT)
	if(!QDELETED(src))
		if(use_power != NO_POWER_USE)
			use_power = IDLE_POWER_USE
		update_icon()

/obj/machinery/fishing_portal_generator/proc/on_fishing_spot_z_level_changed(atom/spot, turf/old_turf, turf/new_turf, same_z_layer)
	SIGNAL_HANDLER
	var/turf/turf = get_turf(src)
	if(turf.z != new_turf.z && !(is_station_level(turf.z) && is_station_level(new_turf.z)))
		deactivate()

/obj/machinery/fishing_portal_generator/on_set_is_operational(old_value)
	if(old_value)
		deactivate()

///Create a radial menu from a list of available fish sources. If only the default is available, activate it right away.
/obj/machinery/fishing_portal_generator/proc/select_fish_source(mob/user)
	var/datum/fish_source/portal/default = GLOB.preset_fish_sources[/datum/fish_source/portal]
	var/list/available_fish_sources = list(default.radial_name = default)
	if(obj_flags & EMAGGED)
		var/datum/fish_source/portal/syndicate = GLOB.preset_fish_sources[/datum/fish_source/portal/syndicate]
		available_fish_sources[syndicate.radial_name] = syndicate
	for (var/datum/techweb/techweb as anything in SSresearch.techwebs)
		var/get_fish_sources = FALSE
		for(var/obj/machinery/rnd/server/server as anything in techweb.techweb_servers)
			if(!is_valid_z_level(get_turf(server), get_turf(src)))
				continue
			get_fish_sources = TRUE
			break
		if(!get_fish_sources)
			continue
		for(var/experiment_type in typesof(/datum/experiment/scanning/fish))
			var/datum/experiment/scanning/fish/experiment = techweb.completed_experiments[experiment_type]
			if(!experiment)
				continue
			var/datum/fish_source/portal/reward = GLOB.preset_fish_sources[experiment.fish_source_reward]
			available_fish_sources[reward.radial_name] = reward

	var/id = 1
	for(var/atom/spot as anything in linked_fishing_spots)
		var/choice_name = "[spot.name] ([id])"
		available_fish_sources[choice_name] = linked_fishing_spots[spot]
		id++

	if(length(available_fish_sources) == 1)
		activate(default, user)
		return
	var/list/choices = list()
	for(var/radial_name in available_fish_sources)
		var/datum/fish_source/source = available_fish_sources[radial_name]
		var/mutable_appearance/radial_icon = mutable_appearance('icons/hud/radial_fishing.dmi', source.radial_state)
		if(!istype(source, /datum/fish_source/portal))
			//a little star on the top-left to distinguishs them from standard portals.
			radial_icon.add_overlay('icons/hud/radial_fishing.dmi', "linked_source")
		choices[radial_name] = radial_icon

	var/choice = show_radial_menu(user, src, choices, radius = 38, custom_check = CALLBACK(src, TYPE_PROC_REF(/atom, can_interact), user), tooltips = TRUE)
	if(!choice || !can_interact(user))
		return
	activate(available_fish_sources[choice], user)

/obj/machinery/fishing_portal_generator/emagged
	obj_flags = parent_type::obj_flags | EMAGGED
	circuit = /obj/item/circuitboard/machine/fishing_portal_generator/emagged
