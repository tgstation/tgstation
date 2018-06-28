// A collection of pre-set uplinks, for admin spawns.

// Radio-like uplink; not an actual radio because this uplink is most commonly
// used for nuke ops, for whom opening the radio GUI and the uplink GUI
// simultaneously is an annoying distraction.
/obj/item/uplink
	name = "station bounced radio"
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	item_state = "walkietalkie"
	desc = "A basic handheld radio that communicates with local telecommunication networks."
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	dog_fashion = /datum/dog_fashion/back

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, null, tc_amount)

/obj/item/uplink/nuclear/Initialize()
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/uplink/nuclear_restricted/Initialize()
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.allow_restricted = FALSE
	hidden_uplink.set_gamemode(/datum/game_mode/nuclear)

/obj/item/uplink/clownop/Initialize()
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.set_gamemode(/datum/game_mode/nuclear/clown_ops)

/obj/item/uplink/old
	name = "dusty radio"
	desc = "A dusty looking radio."

/obj/item/uplink/old/Initialize(mapload, owner, tc_amount = 10)
	. = ..()
	GET_COMPONENT(hidden_uplink, /datum/component/uplink)
	hidden_uplink.name = "dusty radio"

// Multitool uplink
/obj/item/multitool/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, null, tc_amount)

// Pen uplink
/obj/item/pen/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, TRUE, FALSE, null, tc_amount)
	traitor_unlock_degrees = 360
