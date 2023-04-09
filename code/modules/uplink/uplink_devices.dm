// A collection of pre-set uplinks, for admin spawns.

// Radio-like uplink; not an actual radio because this uplink is most commonly
// used for nuke ops, for whom opening the radio GUI and the uplink GUI
// simultaneously is an annoying distraction.
/obj/item/uplink
	name = "station bounced radio"
	icon = 'icons/obj/radio.dmi'
	icon_state = "radio"
	inhand_icon_state = "radio"
	worn_icon_state = "radio"
	desc = "A basic handheld radio that communicates with local telecommunication networks."
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	dog_fashion = /datum/dog_fashion/back

	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_SMALL

	/// The uplink flag for this type.
	/// See [`code/__DEFINES/uplink.dm`]
	var/uplink_flag = UPLINK_TRAITORS

/obj/item/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, uplink_flag, tc_amount)

/obj/item/uplink/debug
	name = "debug uplink"

/obj/item/uplink/debug/Initialize(mapload, owner, tc_amount = 9000)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "debug uplink"
	hidden_uplink.uplink_handler.debug_mode = TRUE

/obj/item/uplink/nuclear
	uplink_flag = UPLINK_NUKE_OPS

/obj/item/uplink/nuclear/debug
	name = "debug nuclear uplink"
	uplink_flag = UPLINK_NUKE_OPS

/obj/item/uplink/nuclear/debug/Initialize(mapload, owner, tc_amount = 9000)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "debug nuclear uplink"
	hidden_uplink.uplink_handler.debug_mode = TRUE

/obj/item/uplink/nuclear_restricted
	uplink_flag = UPLINK_NUKE_OPS

/obj/item/uplink/nuclear_restricted/Initialize(mapload)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.allow_restricted = FALSE

/obj/item/uplink/clownop
	uplink_flag = UPLINK_CLOWN_OPS

/obj/item/uplink/old
	name = "dusty radio"
	desc = "A dusty looking radio."

/obj/item/uplink/old/Initialize(mapload, owner, tc_amount = 10)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "dusty radio"

// Multitool uplink
/obj/item/multitool/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, UPLINK_TRAITORS, tc_amount)

// Pen uplink
/obj/item/pen/uplink/Initialize(mapload, owner, tc_amount = 20)
	. = ..()
	AddComponent(/datum/component/uplink, owner, TRUE, FALSE, UPLINK_TRAITORS, tc_amount)
