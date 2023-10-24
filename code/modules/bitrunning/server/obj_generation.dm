/// Generates a new avatar for the bitrunner.
/obj/machinery/quantum_server/proc/generate_avatar(obj/structure/hololadder/wayout, datum/outfit/netsuit)
	var/mob/living/carbon/human/avatar = new(wayout.loc)

	var/outfit_path = generated_domain.forced_outfit || netsuit
	var/datum/outfit/to_wear = new outfit_path()

	to_wear.belt = /obj/item/bitrunning_host_monitor
	to_wear.glasses = null
	to_wear.gloves = null
	to_wear.l_hand = null
	to_wear.l_pocket = null
	to_wear.r_hand = null
	to_wear.r_pocket = null
	to_wear.suit = null
	to_wear.suit_store = null

	avatar.equipOutfit(to_wear, visualsOnly = TRUE)

	var/thing = avatar.get_active_held_item()
	if(!isnull(thing))
		qdel(thing)

	thing = avatar.get_inactive_held_item()
	if(!isnull(thing))
		qdel(thing)

	var/obj/item/storage/backpack/bag = avatar.back
	if(istype(bag))
		QDEL_LIST(bag.contents)

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
/obj/machinery/quantum_server/proc/stock_gear(mob/living/carbon/human/avatar, mob/living/carbon/human/neo, datum/lazy_template/virtual_domain/generated_domain)
	var/domain_forbids_items = generated_domain.forbids_disk_items
	var/domain_forbids_spells = generated_domain.forbids_disk_spells

	var/import_ban = list()
	var/disk_ban = list()
	if(domain_forbids_items)
		import_ban += "smuggled digital equipment"
		disk_ban += "items"
	if(domain_forbids_spells)
		import_ban += "imported_abilities"
		disk_ban += "powers"

	if(length(import_ban))
		to_chat(neo, span_warning("This domain forbids the use of [english_list(import_ban)], your disk [english_list(disk_ban)] will not be granted!"))

	var/failed = FALSE

	// We don't need to bother going over the disks if neither of the types can be used.
	if(domain_forbids_spells && domain_forbids_items)
		return
	for(var/obj/item/bitrunning_disk/disk in neo.get_contents())
		if(istype(disk, /obj/item/bitrunning_disk/ability) && !domain_forbids_spells)
			var/obj/item/bitrunning_disk/ability/ability_disk = disk

			if(isnull(ability_disk.granted_action))
				failed = TRUE
				continue

			var/datum/action/our_action = new ability_disk.granted_action()
			our_action.Grant(avatar)
			continue

		if(istype(disk, /obj/item/bitrunning_disk/item) && !domain_forbids_items)
			var/obj/item/bitrunning_disk/item/item_disk = disk

			if(isnull(item_disk.granted_item))
				failed = TRUE
				continue

			avatar.put_in_hands(new item_disk.granted_item())

	if(failed)
		to_chat(neo, span_warning("One of your disks failed to load. You must activate them to make a selection."))
