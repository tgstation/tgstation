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
/obj/machinery/quantum_server/proc/generate_avatar(turf/destination, datum/outfit/netsuit)
	var/mob/living/carbon/human/avatar = new(destination)

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

	avatar.equipOutfit(to_wear, visuals_only = TRUE)

	var/obj/item/clothing/under/jumpsuit = avatar.w_uniform
	if(istype(jumpsuit))
		jumpsuit.set_armor(/datum/armor/clothing_under)

	var/obj/item/clothing/head/hat = locate() in avatar.get_equipped_items()
	if(istype(hat))
		hat.set_armor(/datum/armor/none)

	if(!generated_domain.forced_outfit)
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

	// DOPPLER EDIT BEGIN: assign trait for avatars
	ADD_TRAIT(avatar, TRAIT_BITRUNNER_AVATAR, REF(src))
	// DOPPLER EDIT END

	return avatar


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

		var/list/mob_spawns = landmark.spawn_mobs(get_turf(landmark), segment)
		if(length(mob_spawns))
			mutation_candidate_refs += mob_spawns

		qdel(landmark)
		qdel(segment)

	return TRUE


/// Scans over neo's contents for bitrunning tech disks. Loads the items or abilities onto the avatar.
/obj/machinery/quantum_server/proc/stock_gear(mob/living/carbon/human/avatar, mob/living/carbon/human/neo, datum/lazy_template/virtual_domain/generated_domain)
	var/domain_forbids_flags = generated_domain.external_load_flags

	//DOPPLER EDIT ADDITION BEGIN - BITRUNNING_PREFS_DISKS - Track if we've used multiple avatar preference disks, for avoiding overrides and displaying the failure message.
	var/duplicate_prefs = FALSE
	//DOPPLER EDIT ADDITION END

	var/import_ban = list()
	var/disk_ban = list()
	if(domain_forbids_flags & DOMAIN_FORBIDS_ITEMS)
		import_ban += "smuggled digital equipment"
		disk_ban += "items"
	if(domain_forbids_flags & DOMAIN_FORBIDS_ABILITIES)
		import_ban += "imported_abilities"
		disk_ban += "powers"

	if(length(import_ban))
		to_chat(neo, span_warning("This domain forbids the use of [english_list(import_ban)], your externally loaded [english_list(disk_ban)] will not be granted!"))

	var/return_flags = NONE
	return_flags = SEND_SIGNAL(neo, COMSIG_BITRUNNER_STOCKING_GEAR, avatar, domain_forbids_flags)

	if(return_flags & BITRUNNER_GEAR_LOAD_FAILED)
		to_chat(neo, span_warning("At least one of your external data sources has encountered a failure in its loading process. Check for overlapping or inactive disks."))
	if(return_flags & BITRUNNER_GEAR_LOAD_BLOCKED)
		to_chat(neo, span_warning("At least one of your external data sources has been blocked from fully loading. Check domain restrictions."))

	//DOPPLER EDIT ADDITION BEGIN - BITRUNNING_PREFS_DISKS - Handles our avatar preference disks, if present.
	for(var/obj/item/bitrunning_disk/disk in neo.get_contents())
		if(istype(disk, /obj/item/bitrunning_disk/preferences))
			var/obj/item/bitrunning_disk/preferences/prefs_disk = disk
			var/datum/preferences/avatar_preference = prefs_disk.chosen_preference

			if(isnull(avatar_preference) || duplicate_prefs)
				continue
			if(!(domain_forbids_flags & DOMAIN_FORBIDS_ABILITIES))
				avatar_preference.safe_transfer_prefs_to(avatar)
				SSquirks.AssignQuirks(avatar, prefs_disk.mock_client)
			if(!(domain_forbids_flags & DOMAIN_FORBIDS_ITEMS) && prefs_disk.include_loadout)
				avatar.equip_outfit_and_loadout(/datum/outfit, avatar_preference)

			duplicate_prefs = TRUE
	//DOPPLER EDIT ADDITION END

	var/obj/item/organ/brain/neo_brain = neo.get_organ_slot(ORGAN_SLOT_BRAIN)
	for(var/obj/item/skillchip/skill_chip as anything in neo_brain?.skillchips)
		if(!skill_chip.active)
			continue
		var/obj/item/skillchip/clone_chip = new skill_chip.type
		avatar.implant_skillchip(clone_chip, force = TRUE)
		clone_chip.try_activate_skillchip(silent = TRUE, force = TRUE)
