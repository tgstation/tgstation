//Pinpointer for relics
#define SCAN_SINGLE 1 // Scan for a specific relic
#define SCAN_SWEEP 2 // Scan for nearest relic
#define SCAN_COUNT 3 // end index

/obj/item/pinpointer/relic
	name = "relic pinpointer"
	desc = "A handheld tracking device that points to a tagged relic."
	icon_state = "pinpointer_sniffer"
	worn_icon_state = "pinpointer_black"
	custom_price = PAYCHECK_CREW * 6
	custom_premium_price = PAYCHECK_CREW * 6
	var/scan_type = SCAN_SWEEP

/obj/item/pinpointer/relic/proc/trackable(obj/item/relic/R)
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(R)
	if(here && there && (there.z == here.z || (is_station_level(here.z) && is_station_level(there.z)))) // Device and target should be on the same level or different levels of the same station
		return TRUE
	return FALSE

/obj/item/pinpointer/relic/toggle_on()
	active = !active
	playsound(src, 'sound/items/tools/screwdriver2.ogg', 50, TRUE)
	if(active)
		START_PROCESSING(SSfastprocess, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	update_appearance()

/obj/item/pinpointer/relic/scan_for_target()
	switch(scan_type)
		if (SCAN_SINGLE)
			if (target && istype(target, /obj/item/relic))
				var/obj/item/relic/target_relic = target
				target_relic.current_node.check_trans(null, /datum/relic_trans/tracked)
				if (istype(target_relic.current_node, /datum/relic_node/emp))
					target = null
		else
			var/turf/here = get_turf(src)
			if (here && /obj/item/relic::existing_relics.len > 0)
				var/obj/item/relic/target_relic = null;
				var/dist_to_beat = 1000000;
				for (var/obj/item/relic/relic_inst as anything in /obj/item/relic::existing_relics)
					if (target_relic == relic_inst)
						continue
					var/turf/there = get_turf(relic_inst)
					var/new_dist = get_dist(here, there)
					if (new_dist < dist_to_beat)
						dist_to_beat = new_dist
						target_relic = relic_inst
				if (target_relic != null)
					if (target_relic.current_node != null)
						target_relic.current_node.check_trans(null, /datum/relic_trans/tracked)
					if (istype(target_relic.current_node, /datum/relic_node/emp))
						target = null
					else
						target = target_relic
	return (target && istype(target, /obj/item/relic) && trackable(target))

/obj/item/pinpointer/relic/pre_attack(atom/O, mob/user, list/modifiers)
	if (istype(O, /obj/item/relic))
		scan_type = SCAN_SINGLE
		target = O
		balloon_alert(user, "The pinpointer starts tracking [O].")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return ..()

/obj/item/pinpointer/relic/pre_attack_secondary(atom/target, mob/living/user, list/modifiers)
	scan_type = SCAN_SWEEP
	target = null
	balloon_alert(user, "The pinpointer starts tracking the nearest relic.")
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/crafting_recipe/relic_pinpointer
	name = "Relic Pinpointer"
	time = 3 SECONDS
	reqs = list(
		/obj/item/analyzer = 1,
		/obj/item/stack/rods = 1,
		/obj/item/stack/cable_coil = 5,
	)
	tool_behaviors = list(TOOL_SCREWDRIVER)
	result = /obj/item/pinpointer/relic
	category = CAT_EQUIPMENT

/datum/design/relic_pinpointer
	name = "Relic Pinpointer"
	desc = "Makes a device to keep track of relics."
	id = "relic_pinpointer"
	build_type = PROTOLATHE | AWAY_LATHE | AUTOLATHE
	materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	build_path = /obj/item/pinpointer/relic
	category = list(RND_CATEGORY_INITIAL,
					RND_CATEGORY_EQUIPMENT + RND_SUBCATEGORY_EQUIPMENT_SCIENCE)
	departmental_flags = DEPARTMENT_BITFLAG_SCIENCE
