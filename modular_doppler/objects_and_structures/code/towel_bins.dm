/obj/structure/towel_bin
	name = "towel bin"
	desc = "Seeing this really makes you think of how much worse your life would have been without towels. Seriously, who doesn't use towels?"
	icon = 'icons/obj/structures.dmi'
	icon_state = "linenbin-full"
	anchored = TRUE
	resistance_flags = FLAMMABLE
	max_integrity = 70
	/// How many towels there is in the bin (separate from the towels list because we won't instanciate 10 towels per bin in existance).
	var/amount = 10
	/// The list of already-instanciated towels, for when people put them back in it.
	var/list/towels
	/// An item that might be hidden between some towels in the bin.
	var/obj/item/hidden = null


/obj/structure/towel_bin/empty
	amount = 0
	icon_state = "linenbin-empty"
	anchored = FALSE


/obj/structure/towel_bin/examine(mob/user)
	. = ..()
	if(amount <= 0)
		. += "There are no towels in the bin."
	else
		. += "There [amount == 1 ? "is one towel" : "are [amount] towels"] in the bin."


/obj/structure/towel_bin/update_icon_state()
	switch(amount)
		if(0)
			icon_state = "linenbin-empty"
		if(1 to 5)
			icon_state = "linenbin-half"
		else
			icon_state = "linenbin-full"
	return ..()


/obj/structure/towel_bin/fire_act(exposed_temperature, exposed_volume)
	if(amount)
		amount = 0
		update_appearance()

	return ..()


/obj/structure/towel_bin/screwdriver_act(mob/living/user, obj/item/tool)
	if(amount)
		to_chat(user, span_warning("[src] must be empty first!"))
		return ITEM_INTERACT_SUCCESS

	if(tool.use_tool(src, user, 0.5 SECONDS, volume = 50))
		to_chat(user, span_notice("You disassemble [src]."))
		if(!(obj_flags & NO_DEBRIS_AFTER_DECONSTRUCTION))
			new /obj/item/stack/rods(loc, 2)
		qdel(src)
		return ITEM_INTERACT_SUCCESS


/obj/structure/towel_bin/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool, time = 0.5 SECONDS)
	return ITEM_INTERACT_SUCCESS


/obj/structure/towel_bin/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/towel))
		if(!user.transferItemToLoc(attacking_item, src))
			return
		LAZYADD(towels, attacking_item)
		amount++
		to_chat(user, span_notice("You put [attacking_item] in [src]."))
		update_appearance()

	else if(amount && !hidden && attacking_item.w_class < WEIGHT_CLASS_BULKY) //make sure there's sheets to hide it among, make sure nothing else is hidden in there.
		if(!user.transferItemToLoc(attacking_item, src))
			to_chat(user, span_warning("[attacking_item] is stuck to your hand, you cannot hide it among the sheets!"))
			return
		hidden = attacking_item
		to_chat(user, span_notice("You hide [attacking_item] among the sheets."))


/obj/structure/towel_bin/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)


/obj/structure/towel_bin/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return

	if(isliving(user))
		var/mob/living/living_user = user
		if(!(living_user.mobility_flags & MOBILITY_PICKUP))
			return

	take_towel_out(user)


/obj/structure/towel_bin/attack_tk(mob/user)
	take_towel_out(user, tk = TRUE)

	return COMPONENT_CANCEL_ATTACK_CHAIN


/**
 * Helper proc for taking a towel out of the bin, to reduce code repetitions.
 * Intended to only be called by `attack_hand()` and `attack_tk()`.
 *
 * Arguments:
 * * user - Mob that's trying to take a towel out.
 * * tk - Is the user trying to do this using telekinesis? Defaults to `FALSE`.
 */
/obj/structure/towel_bin/proc/take_towel_out(mob/user, tk = FALSE)
	if(amount <= 0)
		to_chat(user, span_warning("You can't figure out how to take a towel out of [src] when it doesn't contain any!"))
		return

	amount--

	var/obj/item/towel/towel

	if(LAZYLEN(towels))
		towel = towels[LAZYLEN(towels)]
		LAZYREMOVE(towels, towel)

	else
		towel = new (loc)

	towel.forceMove(drop_location())
	to_chat(user, span_notice("You [tk ? "telekinetically remove" : "take"] \a [towel] out of [src]."))
	update_appearance()

	if(hidden)
		if(!tk)
			to_chat(user, span_notice("\A [hidden] falls out of [towel]!"))

		hidden.forceMove(drop_location())
		hidden = null

	add_fingerprint(user)
