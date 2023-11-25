// A collection of pre-set uplinks, for admin spawns.

// Radio-like uplink; not an actual radio because this uplink is most commonly
// used for nuke ops, for whom opening the radio GUI and the uplink GUI
// simultaneously is an annoying distraction.
/obj/item/uplink
	name = "station bounced radio"
	icon = 'icons/obj/device.dmi'
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
	/// If the uplink is lockable, which defaults to false which most subtypes of this item are for debug reasons
	var/lockable_uplink = FALSE

/obj/item/uplink/Initialize(mapload, owner, tc_amount = 20, datum/uplink_handler/uplink_handler_override = null)
	. = ..()
	AddComponent(\
		/datum/component/uplink, \
		owner = owner, \
		lockable = lockable_uplink, \
		enabled = TRUE, \
		uplink_flag = uplink_flag, \
		starting_tc = tc_amount, \
		uplink_handler_override = uplink_handler_override, \
	)

/obj/item/uplink/debug
	name = "debug uplink"

/obj/item/uplink/debug/Initialize(mapload, owner, tc_amount = 9000, datum/uplink_handler/uplink_handler_override = null)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "debug uplink"
	hidden_uplink.uplink_handler.debug_mode = TRUE

/obj/item/uplink/nuclear
	uplink_flag = UPLINK_NUKE_OPS

/obj/item/uplink/nuclear/debug
	name = "debug nuclear uplink"
	uplink_flag = UPLINK_NUKE_OPS

/obj/item/uplink/nuclear/debug/Initialize(mapload, owner, tc_amount = 9000, datum/uplink_handler/uplink_handler_override = null)
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

/obj/item/uplink/old/Initialize(mapload, owner, tc_amount = 10, datum/uplink_handler/uplink_handler_override = null)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	hidden_uplink.name = "dusty radio"

// Uplink subtype used as replacement uplink
/obj/item/uplink/replacement
	lockable_uplink = TRUE

/obj/item/uplink/replacement/Initialize(mapload, owner, tc_amount = 10, datum/uplink_handler/uplink_handler_override = null)
	. = ..()
	var/datum/component/uplink/hidden_uplink = GetComponent(/datum/component/uplink)
	var/mob/living/replacement_needer = owner
	if(!istype(replacement_needer))
		return
	var/datum/antagonist/traitor/traitor_datum = replacement_needer?.mind.has_antag_datum(/datum/antagonist/traitor)
	hidden_uplink.unlock_code = traitor_datum?.replacement_uplink_code
	become_hearing_sensitive()

/obj/item/uplink/replacement/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	balloon_alert(user, "deconstructing...")
	if (!do_after(user, 3 SECONDS, target = src))
		return FALSE
	qdel(src)
	return TRUE

/obj/item/uplink/replacement/examine(mob/user)
	. = ..()
	if(!IS_TRAITOR(user))
		return
	. += span_notice("You can destroy this device with a screwdriver.")

// Multitool uplink
/obj/item/multitool/uplink/Initialize(mapload, owner, tc_amount = 20, datum/uplink_handler/uplink_handler_override = null)
	. = ..()
	AddComponent(/datum/component/uplink, owner, FALSE, TRUE, UPLINK_TRAITORS, tc_amount)

// Pen uplink
/obj/item/pen/uplink/Initialize(mapload, owner, tc_amount = 20, datum/uplink_handler/uplink_handler_override = null)
	. = ..()
	AddComponent(/datum/component/uplink, owner, TRUE, FALSE, UPLINK_TRAITORS, tc_amount)
