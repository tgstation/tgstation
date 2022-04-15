/**
 * Hat attacher component
 */
/datum/component/hat_attacher
	var/obj/item/clothing/head/attached_hat

/datum/component/hat_attacher/Initialize()
	if(!istype(parent, /obj/item/clothing/head))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/clothing/head/hat_parent = parent

	RegisterSignal(hat_parent, COMSIG_PARENT_EXAMINE, .proc/add_examine)
	RegisterSignal(hat_parent, COMSIG_ITEM_WORN_OVERLAYS, .proc/overlay_update)
	if(!istype(hat_parent, /obj/item/clothing/head/mod))
		RegisterSignal(hat_parent, COMSIG_PARENT_ATTACKBY, .proc/attach_hat)
		RegisterSignal(hat_parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, .proc/remove_hat)
//	else
//		RegisterSignal(hat_parent, COMSIG_PARENT_ATTACKBY, .proc/mod_attach_hat)
//		RegisterSignal(hat_parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, .proc/mod_remove_hat)


/datum/component/hat_attacher/Destroy()
	QDEL_NULL(attached_hat)
	return ..()


/**
* Adds a span_notice(blue) examine to the source, saying if anything is/can be stacked on it
*
* source = what's examined
* user = who examined it
* base_examine = source's original examine, which we add our addition to the bottom of
**/
/datum/component/hat_attacher/proc/add_examine(datum/source, mob/user, list/base_examine)
	SIGNAL_HANDLER
	if(attached_hat)
		base_examine += span_notice("There's \a [attached_hat] placed on the helmet. Right-click to remove it.")
	else
		base_examine += span_notice("There's nothing placed on the helmet. Yet.")

//component should be:
// hold hat attached to helmet:
// // put it on (player uses hat on helmet on head) DONE
// // take it off (player right clicks helmet with empty hand) DONE
// show on examine that the hat is attached DONE
// update the sprite to show hat on top DONE
// DO ALL OF THIS TO FUCKING MODSUITS

/datum/component/hat_attacher/proc/attach_hat(datum/source, obj/item/attach_item, mob/living/user, params)
	SIGNAL_HANDLER
	if(!istype(attach_item, /obj/item/clothing/head))
		return
	if(attached_hat)
		to_chat(user, span_notice("There's already something placed on helmet!"))
		return
	attached_hat = attach_item
	attach_item.forceMove(parent)
	var/obj/item/clothing/head/hat_parent = parent
	hat_parent.update_appearance()

/datum/component/hat_attacher/proc/remove_hat(datum/source, mob/living/user, list/modifiers)
	SIGNAL_HANDLER
	if(!attached_hat)
		return
	user.put_in_active_hand(attached_hat)
	to_chat(user, span_notice("You removed [attached_hat.name] from helmet!"))
	attached_hat = null
	var/obj/item/clothing/head/hat_parent = parent
	hat_parent.update_appearance()
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/hat_attacher/proc/overlay_update(datum/source, list/worn_overlays)
	SIGNAL_HANDLER
	if(!attached_hat)
		return
	worn_overlays += attached_hat.build_worn_icon(default_layer = HEAD_LAYER, default_icon_file = 'icons/mob/clothing/head.dmi')
