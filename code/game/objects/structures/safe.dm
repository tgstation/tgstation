/*
CONTAINS:
SAFES
FLOOR SAFES
*/

/// Chance for a sound clue
#define SOUND_CHANCE 10
/// Explosion number threshold for opening safe
#define BROKEN_THRESHOLD 3

//SAFES
/obj/structure/safe
	name = "safe"
	desc = "A huge chunk of metal with a dial embedded in it. Fine print on the dial reads \"Scarborough Arms - 2 tumbler safe, guaranteed thermite resistant, explosion resistant, and assistant resistant.\""
	icon = 'icons/obj/structures.dmi'
	icon_state = "safe"
	anchored = TRUE
	density = TRUE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT
	/// The maximum combined w_class of stuff in the safe
	var/maxspace = 24
	/// The amount of tumblers that will be generated
	var/number_of_tumblers = 2
	/// Whether the safe is open or not
	var/open = FALSE
	/// Whether the safe is locked or not
	var/locked = TRUE
	/// The position the dial is pointing to
	var/dial = 0
	/// The list of tumbler dial positions that need to be hit
	var/list/tumblers = list()
	/// The index in the tumblers list of the tumbler dial position that needs to be hit
	var/current_tumbler_index = 1
	/// The combined w_class of everything in the safe
	var/space = 0
	/// Tough, but breakable if explosion counts reaches set value
	var/explosion_count = 0

/obj/structure/safe/Initialize(mapload)
	. = ..()

	// Combination generation
	for(var/iterating in 1 to number_of_tumblers)
		tumblers.Add(rand(0, 99))

	if(!mapload)
		return

	// Put as many items on our turf inside as possible
	for(var/obj/item/inserting_item in loc)
		if(space >= maxspace)
			return
		if(inserting_item.w_class + space <= maxspace)
			space += inserting_item.w_class
			inserting_item.forceMove(src)

/obj/structure/safe/update_icon_state()
	icon_state = "[initial(icon_state)][open ? "-open" : null]"
	return ..()

/obj/structure/safe/attackby(obj/item/attacking_item, mob/user, params)
	if(open)
		. = TRUE //no afterattack
		if(attacking_item.w_class + space <= maxspace)
			if(!user.transferItemToLoc(attacking_item, src))
				to_chat(user, span_warning("\The [attacking_item] is stuck to your hand, you cannot put it in the safe!"))
				return
			space += attacking_item.w_class
			to_chat(user, span_notice("You put [attacking_item] in [src]."))
		else
			to_chat(user, span_warning("[attacking_item] won't fit in [src]."))
	else
		if(istype(attacking_item, /obj/item/clothing/neck/stethoscope))
			attack_hand(user)
			return
		else
			to_chat(user, span_warning("You can't put [attacking_item] into the safe while it is closed!"))
			return

/obj/structure/safe/blob_act(obj/structure/blob/B)
	return

/obj/structure/safe/ex_act(severity, target)
	if(((severity == EXPLODE_HEAVY && target == src) || severity == EXPLODE_DEVASTATE) && explosion_count < BROKEN_THRESHOLD)
		explosion_count++
		switch(explosion_count)
			if(1)
				desc = initial(desc) + "\nIt looks a little banged up."
			if(2)
				desc = initial(desc) + "\nIt's pretty heavily damaged."
			if(3)
				desc = initial(desc) + "\nThe lock seems to be broken."

/obj/structure/safe/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/simple/safe),
	)

/obj/structure/safe/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/safe/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Safe", name)
		ui.open()

/obj/structure/safe/ui_data(mob/user)
	var/list/data = list()
	data["dial"] = dial
	data["open"] = open
	data["locked"] = locked
	data["broken"] = check_broken()

	if(open)
		var/list/contents_names = list()
		data["contents"] = contents_names
		for(var/obj/O in contents)
			contents_names[++contents_names.len] = list("name" = O.name, "sprite" = O.icon_state)
			user << browse_rsc(icon(O.icon, O.icon_state), "[O.icon_state].png")

	return data

/obj/structure/safe/ui_act(action, params)
	. = ..()
	if(.)
		return

	if(!ishuman(usr))
		return
	var/mob/living/carbon/human/user = usr
	if(!user.can_perform_action(src))
		return

	var/canhear = FALSE
	if(user.is_holding_item_of_type(/obj/item/clothing/neck/stethoscope))
		canhear = TRUE

	switch(action)
		if("open")
			if(!check_unlocked() && !open && !broken)
				to_chat(user, span_warning("You cannot open [src], as its lock is engaged!"))
				return
			to_chat(user, span_notice("You [open ? "close" : "open"] [src]."))
			open = !open
			update_appearance()
			return TRUE
		if("turnright")
			if(open)
				return
			if(broken)
				to_chat(user, span_warning("The dial will not turn, as the mechanism is destroyed!"))
				return
			var/ticks = text2num(params["num"])
			for(var/iterate in 1 to ticks)
				dial = WRAP(dial - 1, 0, 100)

				var/invalid_turn = current_tumbler_index % 2 == 0 || current_tumbler_index > number_of_tumblers
				if(invalid_turn) // The moment you turn the wrong way or go too far, the tumblers reset
					current_tumbler_index = 1

				if(!invalid_turn && dial == tumblers[current_tumbler_index])
					notify_user(user, canhear, list("tink", "krink", "plink"), ticks, iterate)
					current_tumbler_index++
				else
					notify_user(user, canhear, list("clack", "scrape", "clank"), ticks, iterate)
			check_unlocked()
			return TRUE
		if("turnleft")
			if(open)
				return
			if(broken)
				to_chat(user, span_warning("The dial will not turn, as the mechanism is destroyed!"))
				return
			var/ticks = text2num(params["num"])
			for(var/iterate in 1 to ticks)
				dial = WRAP(dial + 1, 0, 100)

				var/invalid_turn = current_tumbler_index % 2 != 0 || current_tumbler_index > number_of_tumblers
				if(invalid_turn) // The moment you turn the wrong way or go too far, the tumblers reset
					current_tumbler_index = 1

				if(!invalid_turn && dial == tumblers[current_tumbler_index])
					notify_user(user, canhear, list("tonk", "krunk", "plunk"), ticks, iterate)
					current_tumbler_index++
				else
					notify_user(user, canhear, list("click", "chink", "clink"), ticks, iterate)
			check_unlocked()
			return TRUE
		if("retrieve")
			if(!open)
				return
			var/index = text2num(params["index"])
			if(!index)
				return
			var/obj/item/retrieved_item = contents[index]
			if(!retrieved_item || !in_range(src, user))
				return
			user.put_in_hands(retrieved_item)
			space -= retrieved_item.w_class
			return TRUE

/**
 * Checks if safe is considered in a broken state for force-opening the safe
 */
/obj/structure/safe/proc/check_broken()
	return broken || explosion_count >= BROKEN_THRESHOLD

/**
 * Called every dial turn to determine whether the safe should unlock or not.
 */
/obj/structure/safe/proc/check_unlocked()
	if(check_broken())
		return TRUE
	if(current_tumbler_index > number_of_tumblers)
		locked = FALSE
		visible_message(span_boldnotice("[pick("Spring", "Sprang", "Sproing", "Clunk", "Krunk")]!"))
		return TRUE
	locked = TRUE
	return FALSE

/**
 * Called every dial turn to provide feedback if possible.
 */
/obj/structure/safe/proc/notify_user(user, canhear, sounds, total_ticks, current_tick)
	if(!canhear)
		return
	if(current_tick == 2)
		to_chat(user, "<span class='italics'>The sounds from [src] are too fast and blend together.</span>")
	if(total_ticks == 1 || prob(SOUND_CHANCE))
		balloon_alert(user, pick(sounds))

//FLOOR SAFES
/obj/structure/safe/floor
	name = "floor safe"
	icon_state = "floorsafe"
	density = FALSE
	layer = LOW_OBJ_LAYER

/obj/structure/safe/floor/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile)

#undef SOUND_CHANCE
#undef BROKEN_THRESHOLD
