
/obj/item/gps
	name = "global positioning system"
	desc = "Helping lost spacemen find their way through the planets since 2016."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "gps-c"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	obj_flags = UNIQUE_RENAME
	sound_vary = TRUE
	pickup_sound = SFX_GENERIC_DEVICE_PICKUP
	drop_sound = SFX_GENERIC_DEVICE_DROP
	var/gpstag
	var/tracking_on = TRUE
	var/debug_mode = FALSE
	var/overlay_icon = "working"

/obj/item/gps/Initialize(mapload)
	. = ..()
	add_gps_component()

/// Adds the GPS component to this item.
/obj/item/gps/proc/add_gps_component()
	AddComponent(/datum/component/gps/item, gpstag, tracking_on, overlay_state = overlay_icon, debug = debug_mode)

/obj/item/gps/spaceruin
	gpstag = SPACE_SIGNAL_GPSTAG

/obj/item/gps/science
	icon_state = "gps-s"
	gpstag = "SCI0"

/obj/item/gps/engineering
	icon_state = "gps-e"
	gpstag = "ENG0"

/obj/item/gps/mining
	icon_state = "gps-m"
	gpstag = "MINE0"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/obj/item/gps/cyborg
	icon_state = "gps-b"
	gpstag = "BORG0"
	desc = "A mining cyborg internal positioning system. Used as a recovery beacon for damaged cyborg assets, or a collaboration tool for mining teams."

/obj/item/gps/mining/internal
	icon_state = "gps-m"
	gpstag = "MINER"
	desc = "A positioning system helpful for rescuing trapped or injured miners, keeping one on you at all times while mining might just save your life."

/*
 * GPS for pAIS, which only allows access if it's contained within the user.
 */
/obj/item/gps/pai
	gpstag = "PAI0"

/obj/item/gps/pai/add_gps_component()
	AddComponent(/datum/component/gps/item, gpstag, state = GLOB.inventory_state)

/obj/item/gps/visible_debug
	name = "visible GPS"
	gpstag = "ADMIN"
	desc = "This admin-spawn GPS unit leaves the coordinates visible \
		on any turf that it passes over while being dragged on the floor. Especially useful \
		for marking the area around the transition edges."
	tracking_on = FALSE
	debug_mode = TRUE
	overlay_icon = FALSE
