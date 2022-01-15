/**
 * ### hat stacker element!
 *
 * Non bespoke element (1 in existence) that lets helmets stack hats on top of themselves!
 * If someone wants to change this list to include stuff that fits on one thing and not on the mod helmets, convert this to a bespoke element,
 * and make pre-defined lists to apply whenever we want.
 * Will also be a good time to kill PLASMAMAN_HELMET_EXEMPT
 */

///Trait applied when a hat is currently stacked on another hat; used for tracking
#define TRAIT_HATSTACKED 1

/datum/element/hatstacker
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
	///Whitelist of attachable hats, supplied as argument 2
	var/list/attachable_hats_list

/datum/element/hatstacker/Attach(datum/target, list/attachable_hats_list)
	. = ..()
	if(!istype(target, /obj/item/clothing/head))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/clothing/head/valid_target = target

	RegisterSignal(valid_target, COMSIG_PARENT_EXAMINE, .proc/add_examine)
	RegisterSignal(valid_target, COMSIG_PARENT_ATTACKBY, .proc/place_hat)
	RegisterSignal(valid_target, COMSIG_ATOM_ATTACK_HAND_SECONDARY, .proc/remove_hat)

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

/datum/element/hatstacker/proc/add_examine(obj/item/clothing/head/target, mob/user, list/base_examine)
	SIGNAL_HANDLER
	var/obj/item/clothing/head/attached_hat = find_stacked_hat(target)
	if(attached_hat)
		base_examine += span_notice("There's \a [attached_hat] placed on the helmet. Right-click to remove it.")
	else
		base_examine += span_notice("There's nothing placed on the helmet. Yet.")

/datum/element/hatstacker/proc/place_hat(obj/item/clothing/head/target, obj/item/hitting_item, mob/user)
	SIGNAL_HANDLER
	var/obj/item/clothing/head/attached_hat = find_stacked_hat(target)
	if(!istype(hitting_item, /obj/item/clothing/head))
		return
	if(attached_hat)
		target.balloon_alert(user, "hat already attached!")
		return
	if(!is_type_in_list(hitting_item, attachable_hats_list))
		target.balloon_alert(user, "this hat won't fit!")
		return
	//MODsuit check, if its trying to place on a MODsuit helmet and the MOD isnt active, scream
	if(istype(target, /obj/item/clothing/head/mod))
		var/obj/item/clothing/head/mod/target_helm = target	//This lets us get the helm's attached mod, and thus check if its active
		if(!target_helm.mod.active)
			target.balloon_alert(user, "suit must be active!")
			return
	ADD_TRAIT(hitting_item, TRAIT_HATSTACKED, ELEMENT_TRAIT(src))
	if(user.transferItemToLoc(hitting_item, src, force = FALSE, silent = TRUE))
		attached_hat = hitting_item
		target.balloon_alert(user, "hat attached, right click to remove")
		//MODs all route thru the back. So this check needs to make sure the update is done on the back.
		if(istype(target, /obj/item/clothing/head/mod))
			var/icon_to_use = attached_hat.build_worn_icon(default_layer = ABOVE_BODY_FRONT_HEAD_LAYER-0.1, default_icon_file = 'icons/mob/clothing/head.dmi')
			user.update_inv_back(icon_to_use)	//The user should really be the only one placing the item in this case; helmet can only be deployed by a worn suit, after all.
		else
			var/icon_to_use = attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head.dmi')
			target.update_appearance(icon_to_use)

// /datum/element/hatstacker/generate_worn_overlay()
// 	. = ..()
// 	if(attached_hat)
// 		. += attached_hat.build_worn_icon(default_layer = ABOVE_BODY_FRONT_HEAD_LAYER-0.1, default_icon_file = 'icons/mob/clothing/head.dmi')

/datum/element/hatstacker/proc/remove_hat(obj/item/clothing/head/target, mob/user)
	SIGNAL_HANDLER
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/clothing/head/attached_hat = find_stacked_hat(target)
	if(!attached_hat)
		return
	attached_hat.forceMove(user.drop_location())
	if(user.put_in_active_hand(attached_hat))
		target.balloon_alert(user, "hat removed")
	else
		target.balloon_alert_to_viewers("the hat falls to the floor!")
	attached_hat = null
	//MODs all route thru the back. So this check needs to make sure the update is done on the back.
	if(istype(target, /obj/item/clothing/head/mod))
		user.update_inv_back()	//The user should really be the only one placing the item. I hope.
	else
		user.update_inv_head()
