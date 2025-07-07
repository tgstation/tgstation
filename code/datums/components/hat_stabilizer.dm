/// Allows players to place hats on the atom this is attached to
/datum/component/hat_stabilizer
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	/// Currently "stored" hat. No armor or function will be inherited, only the icon and cover flags.
	var/obj/item/clothing/head/attached_hat
	/// If TRUE, the hat will fall to the ground when the owner does so. It can also be shot off.
	var/loose_hat = FALSE
	/// Original cover flags for the helmet, before a hat is placed
	var/former_flags
	var/former_visor_flags
	/// If true, add_overlay will use worn overlay instead of item appearance
	var/use_worn_icon = TRUE
	/// Pixel z offset for the hat
	var/pixel_z_offset

/datum/component/hat_stabilizer/Initialize(use_worn_icon = FALSE, pixel_z_offset = 0, loose_hat = FALSE)
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	var/atom/movable/source = parent
	source.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1

	src.use_worn_icon = use_worn_icon
	src.pixel_z_offset = pixel_z_offset
	src.loose_hat = loose_hat
	// Examine signals
	RegisterSignal(source, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(source, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_requesting_context_from_item))

	// Equip signals, used to drop loose hats
	RegisterSignal(source, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(source, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

	// Wear & Remove
	RegisterSignal(source, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(source, COMSIG_ATOM_ATTACK_HAND_SECONDARY, PROC_REF(on_secondary_attack_hand))

	// Overlays
	RegisterSignal(source, COMSIG_MODULE_GENERATE_WORN_OVERLAY, PROC_REF(get_worn_overlays))
	RegisterSignal(source, COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, PROC_REF(get_separate_worn_overlays))

	RegisterSignal(source, COMSIG_QDELETING, PROC_REF(on_qdel))

// Inherit the new values passed to the component
/datum/component/hat_stabilizer/InheritComponent(datum/component/hat_stabilizer/new_comp, original, use_worn_icon, pixel_z_offset, loose_hat)
	if(!original)
		return

	if(!isnull(use_worn_icon))
		src.use_worn_icon = use_worn_icon
	if(!isnull(use_worn_icon))
		src.use_worn_icon = use_worn_icon
	if(!isnull(pixel_z_offset))
		src.pixel_z_offset = pixel_z_offset
	if(!isnull(loose_hat))
		src.loose_hat = loose_hat

/datum/component/hat_stabilizer/UnregisterFromParent()
	if (attached_hat)
		remove_hat()
	UnregisterSignal(parent, list(COMSIG_ATOM_EXAMINE, COMSIG_ATOM_ATTACKBY,
	COMSIG_ATOM_ATTACK_HAND_SECONDARY, COMSIG_MODULE_GENERATE_WORN_OVERLAY,
	COMSIG_ITEM_GET_SEPARATE_WORN_OVERLAYS, COMSIG_ATOM_UPDATE_OVERLAYS, COMSIG_QDELETING,
	COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/datum/component/hat_stabilizer/proc/on_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!loose_hat)
		return

	var/obj/item/our_item = parent
	if(!(slot & our_item.slot_flags))
		return
	RegisterSignals(equipper, list(COMSIG_MOB_SLIPPED, COMSIG_LIVING_SLAPPED, COMSIG_MOVABLE_POST_THROW), PROC_REF(throw_hat))
	RegisterSignal(equipper, COMSIG_LIVING_THUD, PROC_REF(drop_hat))

/datum/component/hat_stabilizer/proc/on_drop(datum/source, mob/dropper)
	SIGNAL_HANDLER
	UnregisterSignal(dropper, list(COMSIG_MOB_SLIPPED, COMSIG_LIVING_SLAPPED, COMSIG_MOVABLE_POST_THROW, COMSIG_LIVING_THUD))

/datum/component/hat_stabilizer/proc/throw_hat(mob/hatless)
	SIGNAL_HANDLER
	if(!loose_hat)
		return
	var/obj/item/hat = remove_hat()
	if(!hat)
		return
	hat.visible_message(span_danger("[hat] goes flying off [hatless]'s head!"))
	hat.throw_at(get_edge_target_turf(get_turf(hat), pick(GLOB.alldirs)), 2, 1, spin = TRUE)

/datum/component/hat_stabilizer/proc/drop_hat(mob/hatless)
	SIGNAL_HANDLER
	if(!loose_hat)
		return
	remove_hat()

/datum/component/hat_stabilizer/proc/on_examine(datum/source, mob/user, list/base_examine)
	SIGNAL_HANDLER
	if(attached_hat)
		base_examine += span_notice("There's \a [attached_hat] [loose_hat ? "loosely" : ""] placed on [parent].")
	else
		base_examine += span_notice("There's nothing placed on [parent]. Yet.")

/datum/component/hat_stabilizer/proc/get_worn_overlays(atom/movable/source, list/overlays, mutable_appearance/standing, isinhands, icon_file)
	SIGNAL_HANDLER
	if(isinhands)
		return
	if(!attached_hat)
		return
	var/mutable_appearance/worn_overlay = attached_hat.build_worn_icon(default_layer = ABOVE_BODY_FRONT_HEAD_LAYER - 0.1, default_icon_file = 'icons/mob/clothing/head/default.dmi')
	worn_overlay.appearance_flags |= RESET_COLOR
	// loose hats are slightly angled
	if(loose_hat)
		var/matrix/tilt_trix = matrix(worn_overlay.transform)
		var/angle = 5
		tilt_trix.Turn(angle * pick(1, -1))
		worn_overlay.transform = tilt_trix
	worn_overlay.pixel_z = pixel_z_offset + attached_hat.worn_y_offset
	overlays += worn_overlay

/datum/component/hat_stabilizer/proc/get_separate_worn_overlays(atom/movable/source, list/overlays, mutable_appearance/standing, mutable_appearance/draw_target, isinhands, icon_file)
	SIGNAL_HANDLER
	if (isinhands)
		return
	if(!attached_hat)
		return
	var/mutable_appearance/worn_overlay = attached_hat.build_worn_icon(default_layer = ABOVE_BODY_FRONT_HEAD_LAYER - 0.1, default_icon_file = 'icons/mob/clothing/head/default.dmi')
	for (var/mutable_appearance/overlay in worn_overlay.overlays)
		overlay.layer = -ABOVE_BODY_FRONT_HEAD_LAYER + 0.1
	// loose hats are slightly angled
	if(loose_hat)
		var/matrix/tilt_trix = matrix(worn_overlay.transform)
		var/angle = 5
		tilt_trix.Turn(angle * pick(1, -1))
		worn_overlay.transform = tilt_trix
	worn_overlay.pixel_z = pixel_z_offset + attached_hat.worn_y_offset
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

	attach_hat(hat, user)

/datum/component/hat_stabilizer/proc/attach_hat(obj/item/clothing/hat, mob/user)
	var/atom/movable/movable_parent = parent
	attached_hat = hat
	RegisterSignal(hat, COMSIG_MOVABLE_MOVED, PROC_REF(on_hat_movement))

	if (!isnull(user))
		movable_parent.balloon_alert(user, "hat attached")

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

/datum/component/hat_stabilizer/proc/on_hat_movement(obj/hat, mob/user)
	SIGNAL_HANDLER
	remove_hat(user)

/datum/component/hat_stabilizer/proc/on_secondary_attack_hand(datum/source, mob/user)
	SIGNAL_HANDLER
	. = COMPONENT_CANCEL_ATTACK_CHAIN
	if(!attached_hat)
		return
	var/atom/movable/movable_parent = parent
	if (remove_hat(user))
		movable_parent.balloon_alert(user, "hat removed")
	else
		movable_parent.balloon_alert_to_viewers("the hat falls to the floor!")

/datum/component/hat_stabilizer/proc/on_retraction()

/datum/component/hat_stabilizer/proc/remove_hat(mob/user)
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

	var/former_hat = attached_hat
	var/obj/item/clothing/apparel = parent
	apparel.detach_clothing_traits(attached_hat.clothing_traits)
	apparel.flags_cover = former_flags
	apparel.visor_flags_cover = former_visor_flags
	apparel.update_appearance()
	attached_hat = null
	if (ismob(apparel.loc))
		var/mob/wearer = apparel.loc
		wearer.update_clothing(wearer.get_slot_by_item(apparel))

	return former_hat

/datum/component/hat_stabilizer/proc/on_requesting_context_from_item(atom/source, list/context, obj/item/held_item, mob/user)
	SIGNAL_HANDLER

	if(attached_hat && !held_item)
		context[SCREENTIP_CONTEXT_RMB] = "Remove hat"
		return CONTEXTUAL_SCREENTIP_SET

	if(istype(held_item, /obj/item/clothing/head))
		context[SCREENTIP_CONTEXT_LMB] = "Attach hat"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE
