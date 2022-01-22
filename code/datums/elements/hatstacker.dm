/**
 * ### Hat Stacker element!
 *
 * Bespoke element (1-per-unique-argument in existence) that lets helmets stack hats on top of themselves!
 */
/datum/element/hatstacker
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///Whitelist of attachable hats, supplied as argument 2
	var/list/attachable_hats_list

/datum/element/hatstacker/Attach(datum/target, list/hat_whitelist)
	. = ..()
	if(!hat_whitelist)
		attachable_hats_list = subtypesof(/obj/item/clothing/head)	//PLACEHOLDER - TODO - Add pre-defined list of stackable hats
	else
		attachable_hats_list = hat_whitelist
	if(!istype(target, /obj/item/clothing/head))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_PARENT_EXAMINE, .proc/add_examine)
	if(!istype(target, /obj/item/clothing/head/mod))	//Check if its a MOD helmet, which needs some special updating fyuckery
		RegisterSignal(target, COMSIG_PARENT_ATTACKBY, .proc/place_hat)
		RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY, .proc/remove_hat)
	else
		RegisterSignal(target, COMSIG_PARENT_ATTACKBY, .proc/mod_place_hat)
		RegisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY, .proc/mod_remove_hat)

/datum/element/hatstacker/Detach(datum/target)
	. = ..()
	var/obj/item/clothing/head/attached_hat = find_stacked_hat(target)
	if(attached_hat)	//knock off the helmet if its on their head. Or, technically, auto-rightclick it for them; that way it saves us code, AND gives them the bubble
		remove_hat()
	UnregisterSignal(target, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(target, COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(target, COMSIG_ATOM_ATTACK_HAND_SECONDARY)

/datum/element/hatstacker/proc/find_stacked_hat(obj/item/clothing/head/target)
	for(var/obj/item/clothing/head/possibly_stacked in target)
		if(HAS_TRAIT(possibly_stacked, TRAIT_HATSTACKED))
			return possibly_stacked

/**
* Adds a span_notice(blue) examine to the target, saying if anything is/can be stacked on it
*
* target = what's examined
* user = who examined it
* base_examine = target's original examine, which we add our addition to the bottom of
**/
/datum/element/hatstacker/proc/add_examine(obj/item/clothing/head/target, mob/user, list/base_examine)
	SIGNAL_HANDLER
	var/obj/item/clothing/head/attached_hat = find_stacked_hat(target)
	if(attached_hat)
		base_examine += span_notice("There's \a [attached_hat] placed on the helmet. Right-click to remove it.")
	else
		base_examine += span_notice("There's nothing placed on the helmet. Yet.")

/**
* Attempts to place the attacking item, if a hat, atop the targetted hat. To be called by the ACTUAL place_hat procs; this cuts back copy-paste code
*
* target = the bottom-most, attacked hat
* hitting_item = the attacking item, hopefully a hat
* user = the one trying to stack the hats
**/
/datum/element/hatstacker/proc/attempt_place_hat(obj/item/clothing/head/target, obj/item/hitting_item, mob/user)
	var/obj/item/clothing/head/attached_hat = find_stacked_hat(target)
	if(!istype(hitting_item, /obj/item/clothing/head))
		return
	if(attached_hat)
		target.balloon_alert(user, "hat already attached!")
		return
	if(!is_type_in_list(hitting_item, attachable_hats_list))
		target.balloon_alert(user, "this hat won't fit!")
		return
	if(user.transferItemToLoc(hitting_item, target, force = FALSE, silent = TRUE))
		ADD_TRAIT(hitting_item, TRAIT_HATSTACKED, ELEMENT_TRAIT(src))
		attached_hat = hitting_item
		target.balloon_alert(user, "hat attached, right click to remove")

/**
* Calls Attempt_Place_Hat, then updates the icon
*
* target = the bottom-most, attacked hat
* hitting_item = the attacking item, hopefully a hat
* user = the one trying to stack the hats
**/
/datum/element/hatstacker/proc/place_hat(obj/item/clothing/head/target, obj/item/hitting_item, mob/user)
	SIGNAL_HANDLER
	var/hat_to_place = attempt_place_hat(target, hitting_item, user)
	var/icon_to_use = hitting_item.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head.dmi')
	//TO-DO: get icon_to_use actually added to the overlay list. Somehow.
	user.update_inv_head(icon_to_use)
	return hat_to_place ? COMPONENT_CANCEL_ATTACK_CHAIN : NONE

/**
* Calls Attempt_Place_Hat, then updates the icon of the MOD backpack (which, inturn, updates the helmet)
* Same as the normal place_hat proc aside from the backpack
**/
/datum/element/hatstacker/proc/mod_place_hat(obj/item/clothing/head/mod/target, obj/item/hitting_item, mob/user)
	SIGNAL_HANDLER
	var/hat_to_place = attempt_place_hat(target, hitting_item, user)
	var/icon_to_use = hitting_item.build_worn_icon(default_layer = ABOVE_BODY_FRONT_HEAD_LAYER-0.1, default_icon_file = 'icons/mob/clothing/head.dmi')
	//TO-DO: get icon_to_use actually added to the overlay list. Somehow.
	target.mod.wearer.update_inv_back(icon_to_use)	//Because we've set target as a head/mod, it gets to check for the wearer
	return hat_to_place ? COMPONENT_CANCEL_ATTACK_CHAIN : NONE

/**
* Attempts to remove a stacked hat on right-click
*
* target = the bottom-most hat in the stack; we're trying to remove a hat FROM this target
* user = the one attempting to remove the hat
**/
/datum/element/hatstacker/proc/attempt_remove_hat(obj/item/clothing/head/target, mob/user)
	var/obj/item/clothing/head/attached_hat = find_stacked_hat(target)
//	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!attached_hat)
		return FALSE
	if(user.put_in_active_hand(attached_hat))
		target.balloon_alert(user, "hat removed")
	else
		attached_hat.forceMove(attached_hat.drop_location())
		target.balloon_alert_to_viewers("the hat falls to the floor!")
	attached_hat = null

/**
* Attempts to remove a hat from another hat
**/
/datum/element/hatstacker/proc/remove_hat(obj/item/clothing/head/target, mob/user)
	SIGNAL_HANDLER
	var/hat_to_remove = attempt_remove_hat(target, user)
	user.update_inv_head()
	return hat_to_remove ? COMPONENT_CANCEL_ATTACK_CHAIN : NONE

/**
* Attempts to remove a hat from a MODsuit helmet
**/
/datum/element/hatstacker/proc/mod_remove_hat(obj/item/clothing/head/mod/target, mob/user)
	SIGNAL_HANDLER
	var/hat_to_remove = attempt_remove_hat(target, user)
	target.mod.wearer.update_inv_back()
	return hat_to_remove ? COMPONENT_CANCEL_ATTACK_CHAIN : NONE
