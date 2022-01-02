/obj/item/binoculars
	name = "binoculars"
	desc = "Used for long-distance surveillance."
	inhand_icon_state = "binoculars"
	icon_state = "binoculars"
	worn_icon_state = "binoculars"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	/// The amount to increase the size of the FoV.
	var/zoom_out_amt = 5.5
	/// The amount displace the FoV in the direction the user is facing.
	var/zoom_amt = 10

/obj/item/binoculars/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)

/obj/item/binoculars/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=8, force_wielded=12)

/**
 * Handles zooming the user out when they look through the binoculars.
 *
 * Arguments:
 * - [source][/obj/item]: The source of the signal. Equivalent to src.
 * - [user][/mob]: The mob that has wielded this pair of binoculars.
 */
/obj/item/binoculars/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	RegisterSignal(user, COMSIG_MOB_CLIENT_MOVED, .proc/on_walk)
	RegisterSignal(user, COMSIG_ATOM_DIR_CHANGE, .proc/rotate)
	user.visible_message(span_notice("[user] holds [src] up to [user.p_their()] eyes."), span_notice("You hold [src] up to your eyes."))
	inhand_icon_state = "binoculars_wielded"
	user.regenerate_icons()
	user.client.view_size.zoomOut(zoom_out_amt, zoom_amt, user.dir)

/**
 * Handles zooming the user back in when they lower the binoculars.
 *
 * Arguments:
 * - [source][/obj/item]: The source of the signal. Equivalent to src.
 * - [user][/mob]: The mob that has unwielded this pair of binoculars.
 */
/obj/item/binoculars/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, list(
		COMSIG_MOB_CLIENT_MOVED,
		COMSIG_ATOM_DIR_CHANGE,
	))
	user.visible_message(span_notice("[user] lowers [src]."), span_notice("You lower [src]."))
	inhand_icon_state = "binoculars"
	user.regenerate_icons()
	user.client.view_size.zoomIn()


/**
 * Handles rotating the user's view when they turn while looking through the binoculars.
 *
 * Arguments:
 * - [lad][/mob]: The source of the signal. The person using the binoculars.
 * - old_dir: The direction the user was facing.
 * - new_dir: The direction the user is now facing.
 */
/obj/item/binoculars/proc/rotate(mob/lad, old_dir, new_dir)
	SIGNAL_HANDLER
	lad.regenerate_icons()
	lad.client.view_size.zoomOut(zoom_out_amt, zoom_amt, new_dir)

/**
 * Handles lowering the binoculars when the person using them tries to move.
 *
 * Arguments:
 * - [user][/mob]: The mob using this pair of binoculars that moved.
 */
/obj/item/binoculars/proc/on_walk(mob/user)
	SIGNAL_HANDLER
	attack_self(user) //Yes I have sinned, why do you ask?
