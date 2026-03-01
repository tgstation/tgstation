/// Small handheld chameleon item that allows a user to mimic the outfit of another person quickly.
/obj/item/chameleon_scanner
	// No name or desc by default, set up by the cham action
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_TINY
	actions_types = list(/datum/action/item_action/chameleon/change/scanner)
	action_slots = ALL
	throw_speed = 3
	/// Range that we can scan people
	var/scan_range = 5
	/// Cooldown between scans.
	/// Not entirely intended to be a balance knob, but rather intended to prevent accidentally scanning the same person in quick succession.
	COOLDOWN_DECLARE(scan_cooldown)

/obj/item/chameleon_scanner/Initialize(mapload)
	. = ..()
	register_item_context()

/obj/item/chameleon_scanner/add_item_context(
	obj/item/source,
	list/context,
	atom/target,
	mob/living/user,
)
	if(ishuman(target) && IS_TRAITOR(user))
		// probably don't want to give out the context to any old crewmember -
		// even though anyone can use it, it kind of reveals the fact that it's disguised
		// (though it's trivial to find that out anyway)
		context[SCREENTIP_CONTEXT_LMB] = "Scan target outfit"
		context[SCREENTIP_CONTEXT_RMB] = "Scan target outfit and equip"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/chameleon_scanner/examine(mob/user)
	. = ..()
	if(!IS_TRAITOR(user))
		return
	// similar to context, we don't want a bunch of text revealing "THIS IS A DISGUISED ITEM" to everyone on examine.
	// despite the fact that anyone can use it, we'll only show it to traitors, everyone else just has to figure it out.
	. += span_red("There's a small button on the bottom side of it. You recognize this as a hidden <i>Chameleon Scanner 6000</i>.")
	. += span_red("<b>Left click</b> will stealthily scan a target up to [scan_range] meters away and upload their getup as a custom outfit for you to use.")
	. += span_red("<b>Right click</b> will do the same, but instantly equip the outfit you obtain.")

/obj/item/chameleon_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return scan_target(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/item/chameleon_scanner/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(SHOULD_SKIP_INTERACTION(interacting_with, src, user))
		return NONE
	return ranged_interact_with_atom(interacting_with, user, modifiers)

/obj/item/chameleon_scanner/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(interacting_with) && !isturf(interacting_with))
		return NONE
	var/list/scanned_outfit = scan_target(interacting_with, user)
	if(length(scanned_outfit))
		var/datum/outfit/empty_outfit = new()
		var/datum/action/chameleon_outfit/outfit_action = locate() in user.actions
		outfit_action?.apply_outfit(empty_outfit, scanned_outfit.Copy())
		qdel(empty_outfit)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/chameleon_scanner/ranged_interact_with_atom_secondary(atom/interacting_with, mob/living/user, list/modifiers)
	return interact_with_atom_secondary(interacting_with, user, modifiers)

/**
 * Attempts to scan a human's outfit
 *
 * * scanned - the atom being scanned.
 * * scanner - the mob doing the scanning
 *
 * Returns null or a list of paths scanned. Will not return an empty list.
 */
/obj/item/chameleon_scanner/proc/scan_target(atom/scanned, mob/scanner)

	var/mob/living/carbon/human/mob_copying
	if(ishuman(scanned))
		mob_copying = scanned
	else if(isturf(scanned))
		mob_copying = locate() in scanned // Aim assist

	if(isnull(mob_copying))
		return

	if(!COOLDOWN_FINISHED(src, scan_cooldown))
		balloon_alert(scanner, "not ready yet!")
		return
	if(get_dist(scanner, mob_copying) > scan_range)
		balloon_alert(scanner, "too far away!")
		return
	// Very short scan timer, keep you on your toes
	if(!do_after(scanner, 0.5 SECONDS, scanned, hidden = TRUE))
		return

	var/list/all_scanned_items = list()
	for(var/obj/item/thing in mob_copying.get_equipped_items())
		var/datum/action/item_action/chameleon/change/counter_chameleon = locate() in thing.actions
		if(counter_chameleon?.active_type)
			// Prevent counter spying
			all_scanned_items |= counter_chameleon.active_type
		else
			// I guess this technically serves as a way to discover changling clothes at a distance...??
			// Not sure if that's a good thing or not.
			all_scanned_items |= thing.type

	if(!length(all_scanned_items))
		scanned.balloon_alert(scanner, "nothing to scan!")
		return

	playsound(src, 'sound/machines/ping.ogg', vol = 30, vary = TRUE, extrarange = SILENCED_SOUND_EXTRARANGE)
	COOLDOWN_START(src, scan_cooldown, 5 SECONDS)

	var/datum/action/chameleon_outfit/outfit_action = locate() in scanner.actions
	outfit_action?.save_outfit(scanner, all_scanned_items)

	return all_scanned_items
