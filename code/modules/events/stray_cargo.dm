///Spawns a cargo pod containing a random cargo supply pack on a random area of the station
/datum/round_event_control/stray_cargo
	name = "Stray Cargo Pod"
	typepath = /datum/round_event/stray_cargo
	weight = 20
	max_occurrences = 4
	earliest_start = 10 MINUTES
	category = EVENT_CATEGORY_BUREAUCRATIC
	description = "A pod containing a random supply crate lands on the station."
	admin_setup = list(/datum/event_admin_setup/set_location/stray_cargo, /datum/event_admin_setup/listed_options/stray_cargo)

/datum/event_admin_setup/set_location/stray_cargo
	input_text = "Aim pod at turf we're on?"

/datum/event_admin_setup/set_location/stray_cargo/apply_to_event(datum/round_event/stray_cargo/event)
	event.admin_override_turf = chosen_turf

/datum/event_admin_setup/listed_options/stray_cargo
	input_text = "Choose a cargo crate to drop."
	normal_run_option = "Random Crate"

/datum/event_admin_setup/listed_options/stray_cargo/get_list()
	return sort_list(subtypesof(/datum/supply_pack), /proc/cmp_typepaths_asc)

/datum/event_admin_setup/listed_options/stray_cargo/apply_to_event(datum/round_event/stray_cargo/event)
	event.admin_override_contents = chosen
	var/log_message = "[key_name_admin(usr)] has aimed a stray cargo pod at [event.admin_override_turf ? AREACOORD(event.admin_override_turf) : "a random location"]. The pod contents are [chosen ? chosen : "random"]."
	message_admins(log_message)
	log_admin(log_message)

///Spawns a cargo pod containing a random cargo supply pack on a random area of the station
/datum/round_event/stray_cargo
	var/area/impact_area ///Randomly picked area
	announce_chance = 75
	var/list/possible_pack_types = list() ///List of possible supply packs dropped in the pod, if empty picks from the cargo list
	var/static/list/stray_spawnable_supply_packs = list() ///List of default spawnable supply packs, filtered from the cargo list
	///Admin setable override that is used instead of selecting a random location
	var/atom/admin_override_turf
	///Admin setable override to spawn a specific cargo pack type
	var/admin_override_contents

/datum/round_event/stray_cargo/announce(fake)
	if(fake)
		impact_area = find_event_area()
	priority_announce("Stray cargo pod detected on long-range scanners. Expected location of impact: [impact_area.name].", "Collision Alert")

/**
* Tries to find a valid area, throws an error if none are found
* Also randomizes the start timer
*/
/datum/round_event/stray_cargo/setup()
	start_when = rand(20, 40)
	if(admin_override_turf)
		impact_area = get_area(admin_override_turf)
	else
		impact_area = find_event_area()
	if(!impact_area)
		CRASH("No valid areas for cargo pod found.")
	var/list/turf_test = get_area_turfs(impact_area)
	if(!turf_test.len)
		CRASH("Stray Cargo Pod : No valid turfs found for [impact_area] - [impact_area.type]")

	if(!stray_spawnable_supply_packs.len)
		stray_spawnable_supply_packs = SSshuttle.supply_packs.Copy()
		for(var/pack in stray_spawnable_supply_packs)
			var/datum/supply_pack/pack_type = pack
			if(initial(pack_type.special))
				stray_spawnable_supply_packs -= pack

///Spawns a random supply pack, puts it in a pod, and spawns it on a random tile of the selected area
/datum/round_event/stray_cargo/start()
	var/list/turf/valid_turfs = get_area_turfs(impact_area)
	//Only target non-dense turfs to prevent wall-embedded pods
	for(var/i in valid_turfs)
		var/turf/T = i
		if(T.density)
			valid_turfs -= T
	var/turf/landing_zone
	if(admin_override_turf)
		landing_zone = admin_override_turf
	else
		landing_zone = pick(valid_turfs)
	var/pack_type
	if(admin_override_contents)
		pack_type = admin_override_contents
	else
		if(possible_pack_types.len)
			pack_type = pick(possible_pack_types)
		else
			pack_type = pick(stray_spawnable_supply_packs)
	var/datum/supply_pack/supply_pack
	if(ispath(pack_type, /datum/supply_pack))
		supply_pack = new pack_type
	else  // treat this as a supply pack id and resolving it with SSshuttle
		if(admin_override_contents)
			supply_pack = admin_override_contents //Syndicate crates create a new datum while being customized which will result in this being triggered. Outside of this situation this should never trigger
		else
			supply_pack = SSshuttle.supply_packs[pack_type]
	var/obj/structure/closet/crate/crate = supply_pack.generate(null)
	if(crate) //empty supply packs are a thing! get memed on.
		crate.locked = FALSE //Unlock secure crates
		crate.update_appearance()
	var/obj/structure/closet/supplypod/pod = make_pod()
	var/obj/effect/pod_landingzone/landing_marker = new(landing_zone, pod, crate)
	var/static/mutable_appearance/target_appearance = mutable_appearance('icons/obj/supplypods_32x32.dmi', "LZ")
	notify_ghosts("[control.name] has summoned a supply crate!", source = get_turf(landing_marker), header = "Cargo Inbound", alert_overlay = target_appearance)

///Handles the creation of the pod, in case it needs to be modified beforehand
/datum/round_event/stray_cargo/proc/make_pod()
	var/obj/structure/closet/supplypod/S = new
	return S

///Picks an area that wouldn't risk critical damage if hit by a pod explosion
/datum/round_event/stray_cargo/proc/find_event_area()
	var/static/list/allowed_areas
	if(!allowed_areas)
		///Places that shouldn't explode
		var/static/list/safe_area_types = typecacheof(list(
		/area/station/ai_monitored/turret_protected/ai,
		/area/station/ai_monitored/turret_protected/ai_upload,
		/area/station/engineering,
		/area/shuttle,
	))

		///Subtypes from the above that actually should explode.
		var/static/list/unsafe_area_subtypes = typecacheof(list(/area/station/engineering/break_room))
		allowed_areas = make_associative(GLOB.the_station_areas) - safe_area_types + unsafe_area_subtypes
	var/list/possible_areas = typecache_filter_list(GLOB.areas, allowed_areas)
	if (length(possible_areas))
		return pick(possible_areas)

///A rare variant that drops a crate containing syndicate uplink items
/datum/round_event_control/stray_cargo/syndicate
	name = "Stray Syndicate Cargo Pod"
	typepath = /datum/round_event/stray_cargo/syndicate
	weight = 6
	max_occurrences = 1
	earliest_start = 30 MINUTES
	description = "A pod containing syndicate gear lands on the station."
	min_wizard_trigger_potency = 3
	max_wizard_trigger_potency = 6
	admin_setup = list(/datum/event_admin_setup/set_location/stray_cargo, /datum/event_admin_setup/syndicate_cargo_pod)

/datum/event_admin_setup/syndicate_cargo_pod
	///Admin setable override to spawn a specific cargo pack type
	var/pack_type_override

/datum/event_admin_setup/syndicate_cargo_pod/prompt_admins()
	var/admin_selected_pack = tgui_alert(usr,"Customize Pod contents?", "Pod Contents", list("Yes", "No", "Cancel"))
	switch(admin_selected_pack)
		if("Yes")
			override_contents()
		if("No")
			pack_type_override = null
		else
			return ADMIN_CANCEL_EVENT

///This proc prompts admins to set a TC value and uplink type for the crate, those values are then passed to a new syndicate pack's setup_contents() to generate the contents before spawning it.
/datum/event_admin_setup/syndicate_cargo_pod/proc/override_contents()
	var/datum/supply_pack/misc/syndicate/custom_value/syndicate_pack = new
	var/pack_telecrystals = tgui_input_number(usr, "Please input crate's value in telecrystals.", "Set Telecrystals.", 30)
	if(isnull(pack_telecrystals))
		return ADMIN_CANCEL_EVENT
	var/list/possible_uplinks = list("Traitor" = UPLINK_TRAITORS, "Nuke Op" = UPLINK_NUKE_OPS, "Clown Op" = UPLINK_CLOWN_OPS)
	var/uplink_type = tgui_input_list(usr, "Choose uplink to draw items from.", "Choose uplink type.", possible_uplinks)
	var/selection
	if(!isnull(uplink_type))
		selection = possible_uplinks[uplink_type]
	else
		return ADMIN_CANCEL_EVENT
	syndicate_pack.setup_contents(pack_telecrystals, selection)
	pack_type_override = syndicate_pack

/datum/event_admin_setup/syndicate_cargo_pod/apply_to_event(datum/round_event/stray_cargo/syndicate/event)
	event.admin_override_contents = pack_type_override
	var/log_message = "[key_name_admin(usr)] has aimed a stray syndicate cargo pod at [event.admin_override_turf ? AREACOORD(event.admin_override_turf) : "a random location"]. The pod contents are [pack_type_override ? pack_type_override : "random"]."
	message_admins(log_message)
	log_admin(log_message)

/datum/round_event/stray_cargo/syndicate
	possible_pack_types = list(/datum/supply_pack/misc/syndicate)

///Apply the syndicate pod skin
/datum/round_event/stray_cargo/syndicate/make_pod()
	var/obj/structure/closet/supplypod/S = new
	S.setStyle(STYLE_SYNDICATE)
	return S
