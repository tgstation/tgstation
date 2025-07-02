#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"

/obj/item/door_remote
	icon_state = "remote"
	base_icon_state = "remote"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	icon = 'icons/obj/devices/remote.dmi'
	name = "control wand"
	desc = "A remote for controlling a set of airlocks."
	w_class = WEIGHT_CLASS_TINY

	var/department = "civilian"
	var/mode = WAND_OPEN
	var/region_access = REGION_GENERAL
	var/list/access_list = list()
	// the trim of the owner of this remote, if applied
	var/datum/id_trim/job/owner_trim = null
	// areas that this remote is the exclusive owner of
	var/list/area/our_domain = null
	// areas specifically considered as restricted from a remote
	// accessing them unless specifically allowed (vault, security, etc)
	var/static/list/area/restricted_areas = list(
		/area/station/command/bridge, 									/*so Captain's remote isn't totally useless*/
		/area/station/security, 										/*so antag RD/HoP/QM/CMO can't easily screw up the brig doors*/
		/area/station/ai_monitored/command/nuke_storage, 				/*aka Vault since it's QM's special thing*/
		/area/station/ai_monitored/turret_protected/ai,					// these are areas exclusive to RD
		/area/station/ai_monitored/turret_protected/ai_upload_foyer,	// but sometimes mappers might misconfig
		/area/station/ai_monitored/turret_protected/ai_upload,			// their doors with our several dozen access helpers
	)

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	update_icon_state()
	// initialize late to make sure job accesses are fully configured
	return INITIALIZE_HINT_LATELOAD

/obj/item/door_remote/LateInitialize()
	access_list = SSid_access.get_region_access_list(list(region_access))
	if(!isnull(owner_trim))
		var/datum/id_trim/job/trim_singlet = SSid_access.trim_singletons_by_path[owner_trim]
		access_list |= trim_singlet.access

/obj/item/door_remote/proc/is_my_domain(area/restricted_area)
	for(var/area/dominion as anything in our_domain)
		if(istype(restricted_area, dominion))
			return TRUE
	return FALSE

/obj/item/door_remote/attack_self(mob/user)
	var/static/list/ops = list(WAND_OPEN = "Open Door", WAND_BOLT = "Toggle Bolts", WAND_EMERGENCY = "Toggle Emergency Access")
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	update_icon_state()
	balloon_alert(user, "mode: [ops[mode]]")

/obj/item/door_remote/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!istype(interacting_with, /obj/machinery/door) && !isturf(interacting_with))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	department = "omni"
	region_access = REGION_ALL_STATION
	our_domain = list(	/area/station	)

/obj/item/door_remote/captain
	name = "command door remote"
	desc = "A remote for controlling a set of airlocks. Despite its gaudy insignia denoting the Captain as its owner, some fine print\
		indicates that its access is exclusively relegated to the Bridge and high-security command areas -- an additional byline\
		specifically excludes Security from the high-security areas. Ironic."
	department = "command"
	region_access = REGION_COMMAND
	our_domain = list(
		/area/station,	// still restricted by limited accesses in REGION_COMMAND
	)

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	desc = "A remote for controlling a set of airlocks. This one smells like burnt flesh and ozone."
	department = "engi"
	region_access = REGION_ENGINEERING
	owner_trim = /datum/id_trim/job/chief_engineer
	// doesn't need a domain because their specific high-security areas aren't on anyone else's trim but cap

/obj/item/door_remote/research_director
	name = "research door remote"
	desc = "A remote for controlling a set of airlocks. This one is slightly misshapen, as if squeezed by a person possessing ludicrous strength."
	department = "sci"
	region_access = REGION_RESEARCH
	owner_trim = /datum/id_trim/job/research_director
	our_domain = list(
		/area/station/ai_monitored/turret_protected/ai,
		/area/station/ai_monitored/turret_protected/ai_upload_foyer,
		/area/station/ai_monitored/turret_protected/ai_upload,
	)

/obj/item/door_remote/head_of_security
	name = "security door remote"
	desc = "A remote for controlling a set of airlocks. This one smells like sweat, blood, resentment, and coffee.\
		Someone appears to have tampered with the identifier."
	department = "security"
	region_access = REGION_SECURITY
	owner_trim = /datum/id_trim/job/head_of_security
	our_domain = list(	/area/station/security	)

/obj/item/door_remote/quartermaster
	name = "cargo door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access. Despite that, holding it makes you feel insecure for some reason."
	department = "cargo"
	region_access = REGION_SUPPLY
	owner_trim = /datum/id_trim/job/quartermaster
	our_domain = list( /area/station/ai_monitored/command/nuke_storage )

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	desc = "A remote for controlling a set of airlocks. It has the overpowering odor of blood and, despite its medical insignia,\
		has absolutely no accompanying odor of disinfectant."
	department = "med"
	region_access = REGION_MEDBAY
	owner_trim = /datum/id_trim/job/chief_medical_officer

/obj/item/door_remote/head_of_personnel
	name = "service door remote"
	desc = "A remote for controlling a set of airlocks. This one smells like printer ink, and fills its holder with the urge\
		to mysteriously vanish."
	department = "civilian"
	region_access = REGION_GENERAL
	owner_trim = /datum/id_trim/job/head_of_personnel

/obj/item/door_remote/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	var/obj/machinery/door/door

	if (istype(interacting_with, /obj/machinery/door))
		door = interacting_with
		if (!door.opens_with_door_remote)
			return ITEM_INTERACT_BLOCKING

	else
		for (var/obj/machinery/door/door_on_turf in get_turf(interacting_with))
			if (door_on_turf.opens_with_door_remote)
				door = door_on_turf
				break

		if (isnull(door))
			return ITEM_INTERACT_BLOCKING

	if (!door.check_access_list(access_list) || !door.requiresID())
		interacting_with.balloon_alert(user, "can't access!")
		return ITEM_INTERACT_BLOCKING

	var/area/door_area = get_area(door)
	if(is_type_in_list(door_area, restricted_areas) && !is_my_domain(get_area(door)))
		interacting_with.balloon_alert(user, "can't access!")
		return ITEM_INTERACT_BLOCKING

	var/obj/machinery/door/airlock/airlock = door

	if (!door.hasPower() || (istype(airlock) && !airlock.canAIControl()))
		interacting_with.balloon_alert(user, mode == WAND_OPEN ? "it won't budge!" : "nothing happens!")
		return ITEM_INTERACT_BLOCKING

	switch (mode)
		if (WAND_OPEN)
			if (door.density)
				door.open()
			else
				door.close()
		if (WAND_BOLT)
			if (!istype(airlock))
				interacting_with.balloon_alert(user, "only airlocks!")
				return ITEM_INTERACT_BLOCKING

			if (airlock.locked)
				airlock.unbolt()
				log_combat(user, airlock, "unbolted", src)
			else
				airlock.bolt()
				log_combat(user, airlock, "bolted", src)
		if (WAND_EMERGENCY)
			if (!istype(airlock))
				interacting_with.balloon_alert(user, "only airlocks!")
				return ITEM_INTERACT_BLOCKING

			airlock.emergency = !airlock.emergency
			airlock.update_appearance(UPDATE_ICON)

	return ITEM_INTERACT_SUCCESS

/obj/item/door_remote/update_icon_state()
	var/icon_state_mode
	switch(mode)
		if(WAND_OPEN)
			icon_state_mode = "open"
		if(WAND_BOLT)
			icon_state_mode = "bolt"
		if(WAND_EMERGENCY)
			icon_state_mode = "emergency"

	icon_state = "[base_icon_state]_[department]_[icon_state_mode]"
	return ..()

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
