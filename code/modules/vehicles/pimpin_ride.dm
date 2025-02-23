/**
 * # Janicart
 */
/obj/vehicle/ridden/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	movedelay = 1
	/// The attached garbage bag, if present
	var/obj/item/storage/bag/trash/trash_bag
	/// The installed upgrade, if present
	var/obj/item/janicart_upgrade/installed_upgrade

/obj/vehicle/ridden/janicart/Initialize(mapload)
	. = ..()
	register_context()
	update_appearance()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/janicart)
	GLOB.janitor_devices += src
	if (installed_upgrade)
		installed_upgrade.install(src)

/obj/vehicle/ridden/janicart/Destroy()
	GLOB.janitor_devices -= src
	if (trash_bag)
		QDEL_NULL(trash_bag)
	if (installed_upgrade)
		QDEL_NULL(installed_upgrade)
	return ..()

/obj/vehicle/ridden/janicart/examine(mob/user)
	. = ..()
	if (installed_upgrade)
		. += "It has been upgraded with [installed_upgrade], which can be removed with a screwdriver."

/obj/vehicle/ridden/janicart/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/storage/bag/trash))
		if(trash_bag)
			to_chat(user, span_warning("[src] already has a trashbag hooked!"))
			return
		if(!user.transferItemToLoc(I, src))
			return
		to_chat(user, span_notice("You hook the trashbag onto [src]."))
		trash_bag = I
		RegisterSignal(trash_bag, COMSIG_QDELETING, PROC_REF(bag_deleted))
		SEND_SIGNAL(src, COMSIG_VACUUM_BAG_ATTACH, I)
		update_appearance()
	else if(istype(I, /obj/item/janicart_upgrade))
		if(installed_upgrade)
			to_chat(user, span_warning("[src] already has an upgrade installed! Use a screwdriver to remove it."))
			return
		var/obj/item/janicart_upgrade/new_upgrade = I
		new_upgrade.forceMove(src)
		new_upgrade.install(src)
		installed_upgrade = new_upgrade
		to_chat(user, span_notice("You upgrade [src] with [new_upgrade]."))
		update_appearance()
	else if (istype(I, /obj/item/screwdriver) && installed_upgrade)
		installed_upgrade.uninstall(src)
		installed_upgrade.forceMove(get_turf(user))
		user.put_in_hands(installed_upgrade)
		to_chat(user, span_notice("You remove [installed_upgrade] from [src]"))
		installed_upgrade = null
		update_appearance()
	else if(trash_bag && (!is_key(I) || is_key(inserted_key))) // don't put a key in the trash when we need it
		trash_bag.atom_storage.attempt_insert(I, user)
	else
		return ..()

/obj/vehicle/ridden/janicart/update_overlays()
	. = ..()
	if(trash_bag)
		if(istype(trash_bag, /obj/item/storage/bag/trash/bluespace))
			. += "cart_bluespace_garbage"
		else
			. += "cart_garbage"
	if(installed_upgrade)
		var/mutable_appearance/overlay = new(SSgreyscale.GetColoredIconByType(installed_upgrade.overlay_greyscale_config, installed_upgrade.greyscale_colors))
		overlay.icon_state = "janicart_upgrade"
		. += overlay

/obj/vehicle/ridden/janicart/attack_hand(mob/user, list/modifiers)
	// right click removes bag without unbuckling when possible
	. = (LAZYACCESS(modifiers, RIGHT_CLICK) && try_remove_bag(user)) || ..()
	if (!.)
		try_remove_bag(user)

/obj/vehicle/ridden/janicart/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(!held_item)
		if(occupant_amount() > 0)
			context[SCREENTIP_CONTEXT_LMB] = "Dismount"
			context[SCREENTIP_CONTEXT_RMB] = "Dismount"
			if(trash_bag)
				context[SCREENTIP_CONTEXT_RMB] = "Remove trash bag"
			if(is_key(inserted_key) && occupants.Find(user))
				context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove key"
			return CONTEXTUAL_SCREENTIP_SET
		else if(trash_bag)
			context[SCREENTIP_CONTEXT_LMB] = "Remove trash bag"
			context[SCREENTIP_CONTEXT_RMB] = "Remove trash bag"
			return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/storage/bag/trash) && !trash_bag)
		context[SCREENTIP_CONTEXT_LMB] = "Add trash bag"
		context[SCREENTIP_CONTEXT_RMB] = "Add trash bag"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/janicart_upgrade) && !installed_upgrade)
		context[SCREENTIP_CONTEXT_LMB] = "Install upgrade"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/screwdriver) && installed_upgrade)
		context[SCREENTIP_CONTEXT_LMB] = "Remove upgrade"
		return CONTEXTUAL_SCREENTIP_SET

	if(is_key(held_item) && !is_key(inserted_key))
		context[SCREENTIP_CONTEXT_LMB] = "Insert key"
		context[SCREENTIP_CONTEXT_RMB] = "Insert key"
		return CONTEXTUAL_SCREENTIP_SET
	else if (trash_bag)
		context[SCREENTIP_CONTEXT_LMB] = "Insert into trash bag"
		context[SCREENTIP_CONTEXT_RMB] = "Insert into trash bag"
		return CONTEXTUAL_SCREENTIP_SET

/**
 * Called if the attached bag is being qdeleted, ensures appearance is maintained properly
 */
/obj/vehicle/ridden/janicart/proc/bag_deleted(datum/source)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_remove_bag))

/**
 * Attempts to remove the attached trash bag, returns true if bag was removed
 *
 * Arguments:
 * * remover - The (optional) mob attempting to remove the bag
 */
/obj/vehicle/ridden/janicart/proc/try_remove_bag(mob/remover = null)
	if (!trash_bag)
		return FALSE
	if (remover)
		trash_bag.forceMove(get_turf(remover))
		remover.put_in_hands(trash_bag)
	UnregisterSignal(trash_bag, COMSIG_QDELETING)
	trash_bag = null
	SEND_SIGNAL(src, COMSIG_VACUUM_BAG_DETACH)
	update_appearance()
	return TRUE

/obj/vehicle/ridden/janicart/upgraded
	installed_upgrade = new /obj/item/janicart_upgrade/buffer

/obj/vehicle/ridden/janicart/upgraded/vacuum
	installed_upgrade = new /obj/item/janicart_upgrade/vacuum

/**
 * # Janicart Upgrade
 *
 * Functional upgrades that can be installed into a janicart.
 *
 */
/obj/item/janicart_upgrade
	name = "base upgrade"
	desc = "An abstract upgrade for mobile janicarts."
	icon = 'icons/obj/service/janicart_upgrade.dmi'
	icon_state = "janicart_upgrade"
	greyscale_config = /datum/greyscale_config/janicart_upgrade
	/// The greyscale config for the on-cart installed upgrade overlay
	var/overlay_greyscale_config = /datum/greyscale_config/janicart_upgrade/installed

/**
 * Called when upgrade is installed into a janicart
 *
 * Arguments:
 * * installee - The cart the upgrade is being installed into
 */
/obj/item/janicart_upgrade/proc/install(obj/vehicle/ridden/janicart/installee)
	return FALSE

/**
 * Called when upgrade is uninstalled from a janicart
 *
 * Arguments:
 * * installee - The cart the upgrade is being removed from
 */
/obj/item/janicart_upgrade/proc/uninstall(obj/vehicle/ridden/janicart/installee)
	return FALSE

/obj/item/janicart_upgrade/buffer
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts which adds a floor buffer functionality."
	greyscale_colors = "#ffffff#6aa3ff#a2a2a2#d1d15f"

/obj/item/janicart_upgrade/buffer/install(obj/vehicle/ridden/janicart/installee)
	installee.AddElement(/datum/element/cleaning)

/obj/item/janicart_upgrade/buffer/uninstall(obj/vehicle/ridden/janicart/installee)
	installee.RemoveElement(/datum/element/cleaning)

/obj/item/janicart_upgrade/vacuum
	name = "vacuum upgrade"
	desc = "An upgrade for mobile janicarts which adds a vacuum functionality."
	greyscale_colors = "#ffffff#ffea6a#a2a2a2#d1d15f"

/obj/item/janicart_upgrade/vacuum/install(obj/vehicle/ridden/janicart/installee)
	installee.AddComponent(/datum/component/vacuum, installee.trash_bag)

/obj/item/janicart_upgrade/vacuum/uninstall(obj/vehicle/ridden/janicart/installee)
	qdel(installee.GetComponent(/datum/component/vacuum))
