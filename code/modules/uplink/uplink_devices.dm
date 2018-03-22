
// A collection of pre-set uplinks, for admin spawns.
/obj/item/device/radio/uplink/Initialize(mapload, _owner, _tc_amount = 20)
	. = ..()
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	AddComponent(/datum/component/uplink, _owner, FALSE, TRUE, null, _tc_amount)

/obj/item/device/radio/uplink/nuclear/Initialize()
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/device/multitool/uplink/Initialize(mapload, _owner, _tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, _owner, FALSE, TRUE, null, _tc_amount)

/obj/item/pen/uplink/Initialize(mapload, _owner, _tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink)
	traitor_unlock_degrees = 360

/obj/item/device/radio/uplink/old
	name = "dusty radio"
	desc = "A dusty looking radio."

/obj/item/device/radio/uplink/old/Initialize(mapload, _owner, _tc_amount = 10)
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.name = "dusty radio"
