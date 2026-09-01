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
	/// Is the pinpointer on?
	var/active = FALSE
	///The thing we're searching for
	var/atom/movable/target
	/// TRUE to display things more seriously
	var/alert = FALSE
	/// Some pinpointers change target every time they scan, which means we can't have it change every process() but instead when it turns on.
	var/process_scan = TRUE
	/// Icon_state suffix for special pinpointer icons
	var/icon_suffix = ""

	/// At what range the pinpointer declares you to be at your destination. Use to hide the exact location of your target.
	var/minimum_range = 0
	/// From 1 to this value, the sprite will display as though you're close.
	var/close_range = 8
	/// From close_range + 1 to this value, the sprite will display as though you're medium distance away. Past this value, we'll display as though you're far.
	var/medium_range = 16

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
		var/current_distance = get_dist(here, there)
		if(current_distance >= 1 && current_distance <= close_range)
			return "pinon[alert ? "alert" : "close"][icon_suffix]"
		else if(current_distance > (close_range + 1) && current_distance <= medium_range)
			return "pinon[alert ? "alert" : "medium"][icon_suffix]"
		else if(current_distance > medium_range)
			return "pinon[alert ? "alert" : "far"][icon_suffix]"

/obj/item/pinpointer/crew // A replacement for the old crew monitoring consoles
	name = "crew pinpointer"
	desc = "A handheld tracking device that points to crew suit sensors."
	icon_state = "pinpointer_crew"
	worn_icon_state = "pinpointer_crew"
	custom_price = PAYCHECK_CREW * 6
	custom_premium_price = PAYCHECK_CREW * 6
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.5, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 0.75, /datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT)
	/// The mob that the pinpointer is owned by.
	var/pinpointer_owner = null
	/// Do we find people even if their suit sensors are turned off
	var/ignore_suit_sensor_level = FALSE

/obj/item/pinpointer/crew/Destroy()
	. = ..()
	pinpointer_owner = null

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

	if (!pinpointer_owner)
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
	/// Reference to the other, specific pinpointer that it's bought with. Assigned on /obj/item/storage/box/pinpointer_pairs.
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
	/// Reference to the bounty hunter shuttle's docking port.
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
	custom_materials = list(/datum/material/iron = SMALL_MATERIAL_AMOUNT * 0.8, /datum/material/glass = SMALL_MATERIAL_AMOUNT * 0.7)

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
