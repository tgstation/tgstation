/// Small handheld chameleon item that allows a user to mimic the outfit of another person.
/obj/item/chameleon_scanner
	item_flags = NOBLUDGEON
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/chameleon/change/scanner)
	/// Range that we can scan people
	var/scan_range = 5

/obj/item/chameleon_scanner/examine(mob/user)
	. = ..()
	if(!IS_TRAITOR(user))
		return
	. += span_red("There's a small button on the bottom side of it. You recognize this as a hidden chameleon scanner.")
	. += span_red("Left click will scan a target up to [scan_range] tiles and upload their outfit as a custom outfit for you to use.")
	. += span_red("Right click will do the same, but instantly equip the outfit.")

/obj/item/chameleon_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(scan_target(target, user))
		. |= AFTERATTACK_PROCESSED_ITEM
	return .

/obj/item/chameleon_scanner/afterattack_secondary(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return .

	var/list/scanned_outfit = scan_target(target, user)
	if(length(scanned_outfit))
		var/datum/outfit/empty_outfit = new()
		var/datum/action/chameleon_outfit/outfit_action = locate() in user.actions
		outfit_action?.apply_outfit(empty_outfit, scanned_outfit)
		qdel(empty_outfit)

	return SECONDARY_ATTACK_CONTINUE_CHAIN // no normal afterattack

/**
 * Attempts to scan a human's outfit
 *
 * * scanned - the atom being scanned.
 * * scanner - the mob doing the scanning
 *
 * Returns null or a list of paths scanned. Will not return an empty list.
 */
/obj/item/chameleon_scanner/proc/scan_target(atom/scanned, mob/scanner)
	if(get_dist(scanned, scanner) > scan_range)
		return

	var/mob/living/carbon/human/mob_copying
	if(ishuman(scanned))
		mob_copying = scanned
	else if(isturf(scanned))
		// Aim assist
		mob_copying = locate() in scanned

	if(isnull(mob_copying))
		return

	var/list/all_scanned_items = list()
	for(var/obj/item/thing in mob_copying.get_equipped_items())
		var/datum/action/item_action/chameleon/change/counter_chameleon = locate() in thing.actions
		if(counter_chameleon)
			all_scanned_items |= counter_chameleon.active_type
		else
			all_scanned_items |= thing.type

	if(!length(all_scanned_items))
		scanned.balloon_alert(scanner, "nothing to scan!")
		return

	var/datum/action/chameleon_outfit/outfit_action = locate() in scanner.actions
	outfit_action?.save_outfit(scanner, all_scanned_items)

	return all_scanned_items
