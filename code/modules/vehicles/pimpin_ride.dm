//PIMP-CART
/obj/vehicle/ridden/janicart
	name = "janicart (pimpin' ride)"
	desc = "A brave janitor cyborg gave its life to produce such an amazing combination of speed and utility."
	icon_state = "pussywagon"
	key_type = /obj/item/key/janitor
	movedelay = 1
	var/obj/item/storage/bag/trash/trash_bag
	var/obj/item/janicart_upgrade/installed_upgrade

/obj/vehicle/ridden/janicart/Initialize(mapload)
	. = ..()
	update_appearance()
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/janicart)
	if (installed_upgrade)
		installed_upgrade.install(src)

/obj/vehicle/ridden/janicart/Destroy()
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
	else if(trash_bag)
		trash_bag.attackby(I, user)
	else
		return ..()

/obj/vehicle/ridden/janicart/update_overlays()
	. = ..()
	if(trash_bag)
		. += "cart_garbage"
	if(installed_upgrade)
		var/mutable_appearance/overlay = new(SSgreyscale.GetColoredIconByType(installed_upgrade.overlay_greyscale_config, installed_upgrade.greyscale_colors))
		overlay.icon_state = "janicart_upgrade"
		. += overlay

/obj/vehicle/ridden/janicart/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(. || !trash_bag)
		return
	trash_bag.forceMove(get_turf(user))
	user.put_in_hands(trash_bag)
	trash_bag = null
	SEND_SIGNAL(src, COMSIG_VACUUM_BAG_DETACH)
	update_appearance()

/obj/vehicle/ridden/janicart/upgraded
	installed_upgrade = new /obj/item/janicart_upgrade/buffer

/obj/vehicle/ridden/janicart/upgraded/vacuum
	installed_upgrade = new /obj/item/janicart_upgrade/vacuum

/obj/item/janicart_upgrade
	name = "base upgrade"
	desc = "An abstract upgrade for mobile janicarts."
	icon_state = "janicart_upgrade"
	greyscale_config = /datum/greyscale_config/janicart_upgrade
	var/overlay_greyscale_config = /datum/greyscale_config/janicart_upgrade/installed

/obj/item/janicart_upgrade/proc/install(obj/vehicle/ridden/janicart/installee)
	return FALSE

/obj/item/janicart_upgrade/proc/uninstall(obj/vehicle/ridden/janicart/installee)
	return FALSE

/obj/item/janicart_upgrade/buffer
	name = "floor buffer upgrade"
	desc = "An upgrade for mobile janicarts which adds a floor buffer functionality."
	greyscale_colors = "#ffffff#6aa3ff#a2a2a2#d1d15f"

/obj/item/janicart_upgrade/buffer/install(obj/vehicle/ridden/janicart/installee)
	installee._AddElement(list(/datum/element/cleaning))

/obj/item/janicart_upgrade/buffer/uninstall(obj/vehicle/ridden/janicart/installee)
	installee._RemoveElement(list(/datum/element/cleaning))

/obj/item/janicart_upgrade/vacuum
	name = "vacuum upgrade"
	desc = "An upgrade for mobile janicarts which adds a vacuum functionality."
	greyscale_colors = "#ffffff#ffea6a#a2a2a2#d1d15f"

/obj/item/janicart_upgrade/vacuum/install(obj/vehicle/ridden/janicart/installee)
	installee._AddComponent(list(/datum/component/vacuum))
	if (installee.trash_bag)
		SEND_SIGNAL(installee, COMSIG_VACUUM_BAG_ATTACH, installee.trash_bag)

/obj/item/janicart_upgrade/vacuum/uninstall(obj/vehicle/ridden/janicart/installee)
	qdel(installee.GetComponent(/datum/component/vacuum))
