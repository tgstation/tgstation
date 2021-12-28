/obj/item/storage/wallet
	name = "wallet"
	desc = "It can hold a few small and personal things."
	icon_state = "wallet"
	atom_size = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	slot_flags = ITEM_SLOT_ID
	component_type = /datum/component/storage/concrete/wallet

	var/obj/item/card/id/front_id = null
	var/list/combined_access
	var/cached_flat_icon

/obj/item/storage/wallet/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage/concrete/wallet)
	STR.max_items = 4
	STR.set_holdable(list(
		/obj/item/stack/spacecash,
		/obj/item/holochip,
		/obj/item/card,
		/obj/item/clothing/mask/cigarette,
		/obj/item/flashlight/pen,
		/obj/item/seeds,
		/obj/item/stack/medical,
		/obj/item/toy/crayon,
		/obj/item/coin,
		/obj/item/dice,
		/obj/item/disk,
		/obj/item/implanter,
		/obj/item/lighter,
		/obj/item/lipstick,
		/obj/item/match,
		/obj/item/paper,
		/obj/item/pen,
		/obj/item/photo,
		/obj/item/reagent_containers/dropper,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/pill,
		/obj/item/screwdriver,
		/obj/item/stamp),
		list(/obj/item/screwdriver/power))

/obj/item/storage/wallet/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /obj/item/card/id))
		refreshID()

/**
 * Calculates the new front ID.
 *
 * Picks the ID card that has the most combined command or higher tier accesses.
 */
/obj/item/storage/wallet/proc/refreshID()
	LAZYCLEARLIST(combined_access)

	front_id = null
	var/winning_tally = 0
	var/is_magnetic_found = FALSE
	for(var/obj/item/card/id/id_card in contents)
		// Certain IDs can forcibly jump to the front so they can disguise other cards in wallets. Chameleon/Agent ID cards are an example of this.
		if(!is_magnetic_found && HAS_TRAIT(id_card, TRAIT_MAGNETIC_ID_CARD))
			front_id = id_card
			is_magnetic_found = TRUE

		if(!is_magnetic_found)
			var/card_tally = SSid_access.tally_access(id_card, ACCESS_FLAG_COMMAND)
			if(card_tally > winning_tally)
				winning_tally = card_tally
				front_id = id_card

		LAZYINITLIST(combined_access)
		combined_access |= id_card.access

	// If we didn't pick a front ID - Maybe none of our cards have any command accesses? Just grab the first card (if we even have one).
	// We could also have no ID card in the wallet at all, which will mean we end up with a null front_id and that's fine too.
	if(!front_id)
		front_id = (locate(/obj/item/card/id) in contents)

	if(ishuman(loc))
		var/mob/living/carbon/human/wearing_human = loc
		if(wearing_human.wear_id == src)
			wearing_human.sec_hud_set_ID()

	update_label()
	update_appearance(UPDATE_ICON)
	update_slot_icon()

/obj/item/storage/wallet/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/card/id))
		refreshID()

/obj/item/storage/wallet/update_overlays()
	. = ..()
	cached_flat_icon = null
	if(!front_id)
		return
	COMPILE_OVERLAYS(front_id)
	. += mutable_appearance(front_id.icon, front_id.icon_state)
	. += front_id.overlays
	. += mutable_appearance(icon, "wallet_overlay")

/obj/item/storage/wallet/proc/get_cached_flat_icon()
	if(!cached_flat_icon)
		cached_flat_icon = getFlatIcon(src)
	return cached_flat_icon

/obj/item/storage/wallet/get_examine_string(mob/user, thats = FALSE)
	if(front_id)
		return "[icon2html(get_cached_flat_icon(), user)] [thats? "That's ":""][get_examine_name(user)]" //displays all overlays in chat
	return ..()

/obj/item/storage/wallet/proc/update_label()
	if(front_id)
		name = "wallet displaying [front_id]"
	else
		name = "wallet"

/obj/item/storage/wallet/examine()
	. = ..()
	if(front_id)
		. += span_notice("Alt-click to remove the id.")

/obj/item/storage/wallet/get_id_examine_strings(mob/user)
	. = ..()
	if(front_id)
		. += front_id.get_id_examine_strings(user)

/obj/item/storage/wallet/GetID()
	return front_id

/obj/item/storage/wallet/RemoveID()
	if(!front_id)
		return
	. = front_id
	front_id.forceMove(get_turf(src))

/obj/item/storage/wallet/InsertID(obj/item/inserting_item)
	var/obj/item/card/inserting_id = inserting_item.RemoveID()
	if(!inserting_id)
		return FALSE
	attackby(inserting_id)
	if(inserting_id in contents)
		return TRUE
	return FALSE

/obj/item/storage/wallet/GetAccess()
	if(LAZYLEN(combined_access))
		return combined_access
	else
		return ..()

/obj/item/storage/wallet/random
	icon_state = "random_wallet" // for mapping purposes

/obj/item/storage/wallet/random/Initialize(mapload)
	. = ..()
	icon_state = "wallet"

/obj/item/storage/wallet/random/PopulateContents()
	new /obj/item/holochip(src, rand(5, 30))
	new /obj/effect/spawner/random/entertainment/wallet_storage(src)
