/obj/item/beacon
	name = "\improper tracking beacon"
	desc = "A beacon used by a teleporter."
	icon = 'icons/obj/devices/tracker.dmi'
	icon_state = "beacon"
	inhand_icon_state = "beacon"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	var/enabled = TRUE
	var/renamed = FALSE

/obj/item/beacon/Initialize(mapload)
	. = ..()
	if (enabled)
		GLOB.teleportbeacons += src
	else
		icon_state = "beacon-off"
	register_context()

/obj/item/beacon/Destroy()
	GLOB.teleportbeacons -= src
	return ..()

/obj/item/beacon/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		context[SCREENTIP_CONTEXT_RMB] = "Toggle beacon"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/beacon/proc/turn_off()
	icon_state = "beacon-off"
	GLOB.teleportbeacons -= src
	SEND_SIGNAL(src, COMSIG_BEACON_DISABLED)

/obj/item/beacon/attack_self(mob/user)
	enabled = !enabled
	if (enabled)
		icon_state = "beacon"
		GLOB.teleportbeacons += src
	else
		turn_off()
	to_chat(user, span_notice("You [enabled ? "enable" : "disable"] the beacon."))
	return

/obj/item/beacon/attack_hand_secondary(mob/user, list/modifiers)
	attack_self(user)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/beacon/attackby(obj/item/W, mob/user)
	if(IS_WRITING_UTENSIL(W)) // needed for things that use custom names like the locator
		var/new_name = tgui_input_text(user, "What would you like the name to be?", "Beacon", max_length = MAX_NAME_LEN)
		if(!user.can_perform_action(src))
			return
		if(new_name)
			name = new_name
			renamed = TRUE
		return
	else
		return ..()
