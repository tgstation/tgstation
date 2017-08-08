// A collection of pre-set uplinks, for admin spawns.
/obj/item/device/radio/uplink/Initialize(mapload, owner_key)
	. = ..()
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	AddComponent(/datum/component/uplink, owner_key, FALSE, TRUE)

/obj/item/device/radio/uplink/nuclear/Initialize(mapload, owner_key)
	. = ..()
	GET_COMPONENT(uplink, /datum/component/uplink)
	uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/device/multitool/uplink/Initialize(mapload, owner_key)
	. = ..()
	AddComponent(/datum/component/uplink, owner_key, FALSE, TRUE)

/obj/item/weapon/pen/uplink/Initialize(mapload, owner_key)
	. = ..()
	AddComponent(/datum/component/uplink, owner_key)
	traitor_unlock_degrees = 360

/obj/item/device/radio/uplink/old
	name = "dusty radio"
	desc = "A dusty looking radio."

/obj/item/device/radio/uplink/old/Initialize(mapload, owner_key)
	. = ..()
	GET_COMPONENT(uplink, /datum/component/uplink, owner_key)
	uplink.telecrystals = 10
