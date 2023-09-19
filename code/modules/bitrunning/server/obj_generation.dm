/// Generates a new avatar for the bitrunner.
/obj/machinery/quantum_server/proc/generate_avatar(obj/structure/hololadder/wayout, datum/outfit/netsuit)
	var/mob/living/carbon/human/avatar = new(wayout.loc)

	var/outfit_path = generated_domain.forced_outfit || netsuit
	var/datum/outfit/to_wear = new outfit_path()

	to_wear.suit_store = null
	to_wear.belt = /obj/item/bitrunning_host_monitor
	to_wear.glasses = null
	to_wear.suit = null
	to_wear.gloves = null

	avatar.equipOutfit(to_wear, visualsOnly = TRUE)

	var/obj/item/storage/backpack/bag = avatar.back
	if(istype(bag))
		bag.contents += list(
			new /obj/item/storage/box/survival,
			new /obj/item/storage/medkit/regular,
			new /obj/item/flashlight,
		)

	var/obj/item/card/id/outfit_id = avatar.wear_id
	if(outfit_id)
		outfit_id.assignment = "Bit Avatar"
		outfit_id.registered_name = avatar.real_name

		outfit_id.registered_account = new()
		outfit_id.registered_account.replaceable = FALSE

		SSid_access.apply_trim_to_card(outfit_id, /datum/id_trim/bit_avatar)

	return avatar

/// Generates a new hololadder for the bitrunner. Effectively a respawn attempt.
/obj/machinery/quantum_server/proc/generate_hololadder()
	if(!length(exit_turfs))
		return

	if(retries_spent >= length(exit_turfs))
		return

	var/turf/destination
	for(var/turf/dest_turf in exit_turfs)
		if(!locate(/obj/structure/hololadder) in dest_turf)
			destination = dest_turf
			break

	if(isnull(destination))
		return

	var/obj/structure/hololadder/wayout = new(destination)
	if(isnull(wayout))
		return

	retries_spent += 1

	return wayout

/// Scans over neo's contents for bitrunning tech disks. Loads the items or abilities onto the avatar.
/obj/machinery/quantum_server/proc/stock_gear(mob/living/carbon/human/avatar, mob/living/carbon/human/neo)
	for(var/obj/item/bitrunning_disk/disk in neo)
		if(disk.granted_action)
			disk.granted_action.Grant(avatar)
		if(disk.granted_item)
			avatar.put_in_hands(disk.granted_item)
