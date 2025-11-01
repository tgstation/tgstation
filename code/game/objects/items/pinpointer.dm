//Pinpointers are used to track atoms from a distance as long as they're on the same z-level. The captain and nuke ops have ones that track the nuclear authentication disk.
/obj/item/pinpointer
	name = "pinpointer"
	desc = "A handheld tracking device that locks onto certain signals."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "pinpointer"
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	inhand_icon_state = "electronic"
	worn_icon_state = "pinpointer"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 2.5)
	sound_vary = TRUE
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP
	var/active = FALSE
	var/atom/movable/target //The thing we're searching for
	var/minimum_range = 0 //at what range the pinpointer declares you to be at your destination
	var/alert = FALSE // TRUE to display things more seriously
	var/process_scan = TRUE // some pinpointers change target every time they scan, which means we can't have it change very process but instead when it turns on.
	var/icon_suffix = "" // for special pinpointer icons

/obj/item/pinpointer/Initialize(mapload)
	. = ..()
	GLOB.pinpointer_list += src

/obj/item/pinpointer/Destroy()
	STOP_PROCESSING(SSfastprocess, src)
	GLOB.pinpointer_list -= src
	target = null
	return ..()

/obj/item/pinpointer/attack_self(mob/living/user)
	if(!process_scan) //since it's not scanning on process, it scans here.
		scan_for_target()
	toggle_on()
	user.visible_message(span_notice("[user] [active ? "" : "de"]activates [user.p_their()] pinpointer."), span_notice("You [active ? "" : "de"]activate your pinpointer."))

/obj/item/pinpointer/examine(mob/user)
	. = ..()
	if(target)
		. += "It is currently tracking [target]."

/obj/item/pinpointer/proc/toggle_on()
	active = !active
	playsound(src, 'sound/items/tools/screwdriver2.ogg', 50, TRUE)
	if(active)
		START_PROCESSING(SSfastprocess, src)
	else
		target = null
		STOP_PROCESSING(SSfastprocess, src)
	update_appearance()

/obj/item/pinpointer/process()
	if(!active)
		return PROCESS_KILL
	if(process_scan)
		scan_for_target()
	update_appearance()

/obj/item/pinpointer/proc/scan_for_target()
	return

/obj/item/pinpointer/update_overlays()
	. = ..()
	if(!active)
		return
	if(!target)
		. += "pinon[alert ? "alert" : ""]null[icon_suffix]"
		return
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(target)
	if(!here || !there || here.z != there.z)
		. += "pinon[alert ? "alert" : ""]null[icon_suffix]"
		return
	. += get_direction_icon(here, there)

///Called by update_icon after sanity. There is a target
/obj/item/pinpointer/proc/get_direction_icon(here, there)
	if(get_dist_euclidean(here,there) <= minimum_range)
		return "pinon[alert ? "alert" : ""]direct[icon_suffix]"
	else
		setDir(get_dir(here, there))
		switch(get_dist(here, there))
			if(1 to 8)
				return "pinon[alert ? "alert" : "close"][icon_suffix]"
			if(9 to 16)
				return "pinon[alert ? "alert" : "medium"][icon_suffix]"
			if(16 to INFINITY)
				return "pinon[alert ? "alert" : "far"][icon_suffix]"

/obj/item/pinpointer/crew // A replacement for the old crew monitoring consoles
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	icon_state = "pinpointer_crew"
	worn_icon_state = "pinpointer_crew"
	custom_price = PAYCHECK_CREW * 6
	custom_premium_price = PAYCHECK_CREW * 6
	var/has_owner = FALSE
	var/pinpointer_owner = null
	var/ignore_suit_sensor_level = FALSE /// Do we find people even if their suit sensors are turned off

/obj/item/pinpointer/crew/proc/trackable(mob/living/carbon/human/H)
	var/turf/here = get_turf(src)
	var/turf/there = get_turf(H)
	if(here && there && (there.z == here.z || (is_station_level(here.z) && is_station_level(there.z)))) // Device and target should be on the same level or different levels of the same station
		if (istype(H.w_uniform, /obj/item/clothing/under))
			var/obj/item/clothing/under/U = H.w_uniform
			if(U.has_sensor && (U.sensor_mode >= SENSOR_COORDS || ignore_suit_sensor_level)) // Suit sensors must be on maximum or a contractor pinpointer
				return TRUE
	return FALSE

/obj/item/pinpointer/crew/attack_self(mob/living/user)
	if(active)
		toggle_on()
		user.visible_message(span_notice("[user] deactivates [user.p_their()] pinpointer."), span_notice("You deactivate your pinpointer."))
		return

	if (has_owner && !pinpointer_owner)
		pinpointer_owner = user

	if (pinpointer_owner && pinpointer_owner != user)
		to_chat(user, span_notice("The pinpointer doesn't respond. It seems to only recognise its owner."))
		return

	var/list/name_counts = list()
	var/list/names = list()

	for(var/i in GLOB.human_list)
		var/mob/living/carbon/human/H = i
		if(!trackable(H))
			continue

		var/crewmember_name = "Unknown"
		if(H.wear_id)
			var/obj/item/card/id/I = H.wear_id.GetID()
			if(I?.registered_name)
				crewmember_name = I.registered_name

		while(crewmember_name in name_counts)
			name_counts[crewmember_name]++
			crewmember_name = "[crewmember_name] ([name_counts[crewmember_name]])"
		names[crewmember_name] = H
		name_counts[crewmember_name] = 1

	if(!length(names))
		user.visible_message(span_notice("[user]'s pinpointer fails to detect a signal."), span_notice("Your pinpointer fails to detect a signal."))
		return
	var/pinpoint_target = tgui_input_list(user, "Person to track", "Pinpoint", sort_list(names))
	if(isnull(pinpoint_target))
		return
	if(isnull(names[pinpoint_target]))
		return
	if(QDELETED(src) || !user || !user.is_holding(src) || user.incapacitated)
		return
	target = names[pinpoint_target]
	toggle_on()
	user.visible_message(span_notice("[user] activates [user.p_their()] pinpointer."), span_notice("You activate your pinpointer."))

/obj/item/pinpointer/crew/scan_for_target()
	if(target)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(!trackable(H))
				target = null
	if(!target) //target can be set to null from above code, or elsewhere
		active = FALSE

/obj/item/pinpointer/pair
	name = "pair pinpointer"
	desc = "A handheld tracking device that locks onto its other half of the matching pair."
	var/other_pair

/obj/item/pinpointer/pair/Destroy()
	other_pair = null
	. = ..()

/obj/item/pinpointer/pair/scan_for_target()
	target = other_pair

/obj/item/pinpointer/pair/examine(mob/user)
	. = ..()
	if(!active || !target)
		return
	var/mob/mob_holder = get(target, /mob)
	if(istype(mob_holder))
		. += "Its pair is being held by [mob_holder]."
		return

/obj/item/pinpointer/shuttle
	name = "bounty shuttle pinpointer"
	desc = "A handheld tracking device that locates the bounty hunter shuttle for quick escapes."
	icon_state = "pinpointer_hunter"
	worn_icon_state = "pinpointer_black"
	icon_suffix = "_hunter"
	var/obj/docking_port/mobile/shuttleport

/obj/item/pinpointer/shuttle/Initialize(mapload)
	. = ..()
	shuttleport = SSshuttle.getShuttle("huntership")

/obj/item/pinpointer/shuttle/scan_for_target()
	if(!shuttleport)
		shuttleport = SSshuttle.getShuttle("huntership")
	target = shuttleport

/obj/item/pinpointer/shuttle/Destroy()
	shuttleport = null
	. = ..()

///list of all sheets with sniffable = TRUE for the sniffer to locate
GLOBAL_LIST_EMPTY(sniffable_sheets)

/obj/item/pinpointer/material_sniffer
	name = "material sniffer"
	desc = "A handheld tracking device that locates sheets of glass and iron."
	icon_state = "pinpointer_sniffer"
	worn_icon_state = "pinpointer_black"

/obj/item/pinpointer/material_sniffer/scan_for_target()
	if(target || !GLOB.sniffable_sheets.len)
		return
	var/obj/item/stack/sheet/new_sheet_target
	var/closest_distance = INFINITY
	for(var/obj/item/stack/sheet/potential_sheet as anything in GLOB.sniffable_sheets)
		// not enough for lag reasons, and shouldn't even be on this
		if(potential_sheet.amount < 10)
			GLOB.sniffable_sheets -= potential_sheet
			continue
		//held by someone
		if(isliving(potential_sheet.loc))
			continue
		//not on scanner's z
		if(potential_sheet.z != z)
			continue
		var/distance_from_sniffer = get_dist(src, potential_sheet)
		if(distance_from_sniffer < closest_distance)
			closest_distance = distance_from_sniffer
			new_sheet_target = potential_sheet
	if(!new_sheet_target)
		target = null
		return
	say("Located [new_sheet_target.amount] [new_sheet_target.singular_name]s!")
	target = new_sheet_target
