/// Allows players to place hats on the atom this is attached to
/datum/component/hat_stabilizer
	/// Currently "stored" hat. No armor or function will be inherited, only the icon and cover flags.
	var/obj/item/clothing/head/attached_hat
	/// Original cover flags for the helmet, before a hat is placed
	var/former_flags
	var/former_visor_flags
	/// If true, add_overlay will use worn overlay instead of item appearance
	var/use_worn_icon = TRUE
	/// Pixel_y offset for the hat
	var/pixel_y_offset

/datum/component/hat_stabilizer/Initialize(add_overlay = FALSE, use_worn_icon = TRUE, pixel_y_offset = 0)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	src.use_worn_icon = use_worn_icon
	src.pixel_y_offset = pixel_y_offset
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_qdel))
	RegisterSignal(parent, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_secondary_attack_hand))
	RegisterSignals(parent, list(COMSIG_MODULE_GENERATE_WORN_OVERLAY, COMSIG_ITEM_GET_WORN_OVERLAYS), PROC_REF(get_worn_overlays))
	if (add_overlay)
		RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))

/datum/component/hat_stabilizer/UnregisterFromParent()
	if (attached_hat)
		remove_hat()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACKBY,
	COMSIG_ATOM_ATTACK_HAND_SECONDARY, COMSIG_MODULE_GENERATE_WORN_OVERLAY,
	COMSIG_ITEM_GET_WORN_OVERLAYS, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_QDELETING))

/datum/component/hat_stabilizer/proc/on_examine(datum/source, mob/user, list/base_examine)
	SIGNAL_HANDLER
	if(attached_hat)
		base_examine += span_notice("There's \a [attached_hat] placed on [parent]. Right-click to remove it.")
	else
		base_examine += span_notice("There's nothing placed on [parent]. Yet.")

/datum/component/hat_stabilizer/proc/get_worn_overlays(atom/movable/source, list/overlays, mutable_appearance/standing, isinhands, icon_file)
	SIGNAL_HANDLER
	if (isinhands)
		return
	if(attached_hat)
		var/mutable_appearance/worn_overlay = attached_hat.build_worn_icon(default_layer = ABOVE_BODY_FRONT_HEAD_LAYER-0.1, default_icon_file = 'icons/mob/clothing/head/default.dmi')
		worn_overlay.pixel_y = pixel_y_offset
		overlays += worn_overlay

/datum/component/hat_stabilizer/proc/on_update_overlays(atom/movable/source, list/overlays)
	SIGNAL_HANDLER
	var/mutable_appearance/worn_overlay = use_worn_icon ? attached_hat.build_worn_icon(default_layer = ABOVE_OBJ_LAYER, default_icon_file = 'icons/mob/clothing/head/default.dmi') : mutable_appearance(attached_hat, layer = ABOVE_OBJ_LAYER)
	worn_overlay.pixel_y = pixel_y_offset
	overlays += worn_overlay

/datum/component/hat_stabilizer/proc/on_qdel(atom/movable/source)
	SIGNAL_HANDLER

	if (attached_hat)
		QDEL_NULL(attached_hat)

/datum/component/hat_stabilizer/proc/on_attackby(datum/source, obj/item/hitting_item, mob/user)
	SIGNAL_HANDLER

	var/atom/movable/movable_parent = parent
	if(!istype(hitting_item, /obj/item/clothing/head))
		return

	if(attached_hat)
		movable_parent.balloon_alert(user, "hat already attached!")
		return

	var/obj/item/clothing/hat = hitting_item
	if(hat.clothing_flags & STACKABLE_HELMET_EXEMPT)
		movable_parent.balloon_alert(user, "invalid hat!")
		return

	if(!user.transferItemToLoc(hat, parent, force = FALSE, silent = TRUE))
		return
	attached_hat = hat
	RegisterSignal(hat, COMSIG_MOVABLE_MOVED, PROC_REF(remove_hat))
	movable_parent.balloon_alert(user, "hat attached, right-click to remove")

	if (!istype(parent, /obj/item/clothing))
		movable_parent.update_appearance()
		return

	var/obj/item/clothing/apparel = parent
	apparel.attach_clothing_traits(attached_hat.clothing_traits)
	former_flags = apparel.flags_cover
	former_visor_flags = apparel.visor_flags_cover
	apparel.flags_cover |= attached_hat.flags_cover
	apparel.visor_flags_cover |= attached_hat.visor_flags_cover
	apparel.update_appearance()
	if (ismob(apparel.loc))
		var/mob/wearer = apparel.loc
		wearer.update_clothing(wearer.get_slot_by_item(apparel))

/datum/component/hat_stabilizer/proc/on_secondary_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!attached_hat)
		return
	var/atom/movable/movable_parent = parent
	if (remove_hat(user))
		movable_parent.balloon_alert(user, "hat removed")
	else
		movable_parent.balloon_alert_to_viewers("the hat falls to the floor!")

/datum/component/hat_stabilizer/proc/remove_hat(mob/user)
	SIGNAL_HANDLER

	if(QDELETED(attached_hat))
		return

	var/atom/movable/movable_parent = parent
	UnregisterSignal(attached_hat, COMSIG_MOVABLE_MOVED)

	if (attached_hat.loc == parent)
		attached_hat.forceMove(movable_parent.drop_location())

	if(!isnull(user))
		. = user.put_in_active_hand(attached_hat)
	else
		movable_parent.balloon_alert_to_viewers("the hat falls to the floor!")

	if (!istype(parent, /obj/item/clothing))
		attached_hat = null
		movable_parent.update_appearance()
		return

	var/obj/item/clothing/apparel = parent
	apparel.detach_clothing_traits(attached_hat)
	apparel.flags_cover = former_flags
	apparel.visor_flags_cover = former_visor_flags
	apparel.update_appearance()
	attached_hat = null
	if (ismob(apparel.loc))
		var/mob/wearer = apparel.loc
		wearer.update_clothing(wearer.get_slot_by_item(apparel))
