/// Attempts to spawn a crate twice based on the list of available locations
/obj/machinery/quantum_server/proc/attempt_spawn_cache(list/possible_turfs)
	if(!length(possible_turfs))
		return TRUE

	shuffle_inplace(possible_turfs)
	var/turf/chosen_turf = validate_turf(pick(possible_turfs))

	if(isnull(chosen_turf))
		possible_turfs.Remove(chosen_turf)
		chosen_turf = validate_turf(pick(possible_turfs))
		if(isnull(chosen_turf))
			CRASH("vdom: after two attempts, could not find a valid turf for cache")

	new /obj/structure/closet/crate/secure/bitrunning/encrypted(chosen_turf)
	return TRUE

/// Attempts to spawn a lootbox
/obj/machinery/quantum_server/proc/attempt_spawn_curiosity(list/possible_turfs)
	if(!length(possible_turfs)) // Out of turfs to place a curiosity
		return FALSE

	if(generated_domain.secondary_loot_generated >= assoc_value_sum(generated_domain.secondary_loot)) // Out of curiosities to place
		return FALSE

	shuffle_inplace(possible_turfs)
	var/turf/chosen_turf = validate_turf(pick(possible_turfs))

	if(isnull(chosen_turf))
		possible_turfs.Remove(chosen_turf)
		chosen_turf = validate_turf(pick(possible_turfs))
		if(isnull(chosen_turf))
			CRASH("vdom: after two attempts, could not find a valid turf for curiosity")

	new /obj/item/storage/lockbox/bitrunning/encrypted(chosen_turf)
	return chosen_turf

/// Generates a new avatar for the bitrunner.
/obj/machinery/quantum_server/proc/generate_avatar(obj/structure/hololadder/wayout, datum/outfit/netsuit)
	var/mob/living/carbon/human/avatar = new(wayout.loc)

	var/outfit_path = generated_domain.forced_outfit || netsuit
	var/datum/outfit/to_wear = new outfit_path()

	to_wear.belt = /obj/item/bitrunning_host_monitor
	to_wear.ears = null
	to_wear.glasses = null
	to_wear.gloves = null
	to_wear.l_pocket = null
	to_wear.r_pocket = null
	to_wear.suit = null
	to_wear.suit_store = null

	avatar.equipOutfit(to_wear, visualsOnly = TRUE)

	var/obj/item/clothing/under/jumpsuit = avatar.w_uniform
	if(istype(jumpsuit))
		jumpsuit.set_armor(/datum/armor/clothing_under)

	var/obj/item/clothing/head/hat = locate() in avatar.get_equipped_items()
	if(istype(hat))
		hat.set_armor(/datum/armor/none)

	for(var/obj/thing in avatar.held_items)
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

	avatar.AddComponent( \
		/datum/component/simple_bodycam, \
		camera_name = "bitrunner bodycam", \
		c_tag = "Avatar [avatar.real_name]", \
		network = BITRUNNER_CAMERA_NET, \
		emp_proof = TRUE, \
	)
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

/// Loads in any mob segments of the map
/obj/machinery/quantum_server/proc/load_mob_segments()
	if(!length(generated_domain.mob_modules))
		return TRUE

	var/current_index = 1
	shuffle_inplace(generated_domain.mob_modules)

	for(var/obj/effect/landmark/bitrunning/mob_segment/landmark in GLOB.landmarks_list)
		if(current_index > length(generated_domain.mob_modules))
			stack_trace("vdom: mobs segments are set to unique, but there are more landmarks than available segments")
			return FALSE

		var/path
		if(generated_domain.modular_unique_mobs)
			path = generated_domain.mob_modules[current_index]
			current_index += 1
		else
			path = pick(generated_domain.mob_modules)

		var/datum/modular_mob_segment/segment = new path()
		segment.spawn_mobs(get_turf(landmark))
		mutation_candidate_refs += segment.spawned_mob_refs
		qdel(landmark)

	return TRUE

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

			if(locate(our_action.type) in avatar.actions)
				failed = TRUE
				continue

			our_action.Grant(avatar)
			continue

		if(istype(disk, /obj/item/bitrunning_disk/item) && !domain_forbids_items)
			var/obj/item/bitrunning_disk/item/item_disk = disk

			if(isnull(item_disk.granted_item))
				failed = TRUE
				continue

			avatar.put_in_hands(new item_disk.granted_item())

	if(failed)
		to_chat(neo, span_warning("One of your disks failed to load. Check for duplicate or inactive disks."))

	var/obj/item/organ/internal/brain/neo_brain = neo.get_organ_slot(ORGAN_SLOT_BRAIN)
	for(var/obj/item/skillchip/skill_chip as anything in neo_brain?.skillchips)
		if(!skill_chip.active)
			continue
		var/obj/item/skillchip/clone_chip = new skill_chip.type
		avatar.implant_skillchip(clone_chip, force = TRUE)
		clone_chip.try_activate_skillchip(silent = TRUE, force = TRUE)
