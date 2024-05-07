/datum/traitor_objective/ultimate/battle_royale
	name = "Implant crewmembers with a subtle implant, then make them fight to the death on pay-per-view TV."
	description = "Go to %AREA%, and receive the Royale Broadcast Kit. \
		Use the contained implant on station personnel to subtly implant them with a micro-explosive. \
		Once you have at least six contestants, use the contained remote to start a timer and begin broadcasting live. \
		If more than one contestant remains alive after ten minutes, all of the implants will detonate."

	///Area type the objective owner must be in to receive the tools.
	var/area/kit_spawn_area
	///Whether the kit was sent already.
	var/equipped = FALSE

/datum/traitor_objective/ultimate/battle_royale/generate_objective(datum/mind/generating_for, list/possible_duplicates)
	var/list/possible_areas = GLOB.the_station_areas.Copy()
	for(var/area/possible_area as anything in possible_areas)
		if(ispath(possible_area, /area/station/hallway) || ispath(possible_area, /area/station/security))
			possible_areas -= possible_area
	if(length(possible_areas) == 0)
		return FALSE
	kit_spawn_area = pick(possible_areas)
	replace_in_name("%AREA%", initial(kit_spawn_area.name))
	return TRUE

/datum/traitor_objective/ultimate/battle_royale/generate_ui_buttons(mob/user)
	var/list/buttons = list()
	if(!equipped)
		buttons += add_ui_button("", "Pressing this will call down a pod with the Royale Broadcast kit.", "biohazard", "deliver_kit")
	return buttons

/datum/traitor_objective/ultimate/battle_royale/ui_perform_action(mob/living/user, action)
	. = ..()
	if(action != "deliver_kit" || equipped)
		return
	var/area/delivery_area = get_area(user)
	if(delivery_area.type != kit_spawn_area)
		to_chat(user, span_warning("You must be in [initial(kit_spawn_area.name)] to receive the Royale Broadcast kit."))
		return
	equipped = TRUE
	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = /obj/item/storage/box/syndie_kit/battle_royale,
	))
