/**
 * Component which allows you to attach a bayonet to an item,
 * be it a piece of clothing or a tool.
 */
/datum/component/bayonet_attachable
	/// Whenever we can remove the bayonet with a screwdriver
	var/removable = TRUE
	/// If passed, we wil simply update our item's icon_state when a bayonet is attached.
	/// Formatted as parent_base_state-[bayonet_icon_state-state]
	var/bayonet_icon_state
	/// If passed, we will use a specific overlay instead of using the knife itself
	/// The state to take from the bayonet overlay icon if supplied.
	var/bayonet_overlay
	/// This is the icon file it grabs the overlay from.
	var/bayonet_overlay_icon
	/// Offsets for the bayonet overlay
	var/offset_x = 0
	var/offset_y = 0
	/// If this component allows sawing off the parent gun/should be deleted when the parent gun is sawn off
	var/allow_sawnoff = FALSE

	// Internal vars
	/// Currently attached bayonet
	var/obj/item/bayonet
	/// Static typecache of all knives that can become bayonets
	var/static/list/valid_bayonets = typecacheof(list(/obj/item/knife/combat))

/datum/component/bayonet_attachable/Initialize(
	obj/item/starting_bayonet,
	offset_x = 0,
	offset_y = 0,
	removable = TRUE,
	bayonet_icon_state = null,
	bayonet_overlay = "bayonet",
	bayonet_overlay_icon = 'icons/obj/weapons/guns/bayonets.dmi',
	allow_sawnoff = FALSE
)

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.removable = removable
	src.bayonet_icon_state = bayonet_icon_state
	src.bayonet_overlay = bayonet_overlay
	src.bayonet_overlay_icon = bayonet_overlay_icon
	src.offset_x = offset_x
	src.offset_y = offset_y
	src.allow_sawnoff = allow_sawnoff

	if (istype(starting_bayonet))
		add_bayonet(starting_bayonet)

/datum/component/bayonet_attachable/Destroy(force)
	if(bayonet)
		remove_bayonet()
	return ..()

/datum/component/bayonet_attachable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_OBJ_DECONSTRUCT, PROC_REF(on_parent_deconstructed))
	RegisterSignal(parent, COMSIG_ATOM_EXITED, PROC_REF(on_item_exit))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER), PROC_REF(on_screwdriver))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_update_overlays))
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_attackby))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_deleted))
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_pre_attack))
	RegisterSignal(parent, COMSIG_GUN_BEING_SAWNOFF, PROC_REF(on_being_sawnoff))
	RegisterSignal(parent, COMSIG_GUN_SAWN_OFF, PROC_REF(on_sawn_off))

/datum/component/bayonet_attachable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_OBJ_DECONSTRUCT,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_TOOL_ACT(TOOL_SCREWDRIVER),
		COMSIG_ATOM_UPDATE_ICON_STATE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_EXAMINE,
		COMSIG_QDELETING,
		COMSIG_ITEM_PRE_ATTACK,
		COMSIG_GUN_BEING_SAWNOFF,
		COMSIG_GUN_SAWN_OFF,
	))

/datum/component/bayonet_attachable/proc/on_examine(obj/item/source, mob/examiner, list/examine_list)
	SIGNAL_HANDLER

	if(isnull(bayonet))
		examine_list += "It has a <b>bayonet</b> lug on it."
		return

	examine_list += "It has \a [bayonet] [removable ? "" : "permanently "]affixed to it."
	if(removable)
		examine_list += span_info("[bayonet] looks like it can be <b>unscrewed</b> from [bayonet].")

/datum/component/bayonet_attachable/proc/on_pre_attack(obj/item/source, atom/target, mob/living/user, params)
	SIGNAL_HANDLER

	if (isnull(bayonet) || !user.combat_mode)
		return NONE

	INVOKE_ASYNC(bayonet, TYPE_PROC_REF(/obj/item, melee_attack_chain), user, target, params)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/bayonet_attachable/proc/on_attackby(obj/item/source, obj/item/attacking_item, mob/attacker, params)
	SIGNAL_HANDLER

	if(!is_type_in_typecache(attacking_item, valid_bayonets))
		return

	if(bayonet)
		source.balloon_alert(attacker, "already has \a [bayonet]!")
		return

	if(!attacker.transferItemToLoc(attacking_item, source))
		return

	add_bayonet(attacking_item, attacker)
	source.balloon_alert(attacker, "attached")
	return COMPONENT_NO_AFTERATTACK

/datum/component/bayonet_attachable/proc/add_bayonet(obj/item/new_bayonet, mob/attacher)
	if(bayonet)
		CRASH("[type] tried to add a new bayonet when it already had one.")

	bayonet = new_bayonet
	if(bayonet.loc != parent)
		bayonet.forceMove(parent)
	var/obj/item/item_parent = parent
	item_parent.update_appearance()

/datum/component/bayonet_attachable/proc/remove_bayonet()
	bayonet = null
	var/obj/item/item_parent = parent
	item_parent.update_appearance()

/datum/component/bayonet_attachable/proc/on_item_exit(obj/item/source, atom/movable/gone, direction)
	SIGNAL_HANDLER

	if(gone == bayonet)
		remove_bayonet()

/datum/component/bayonet_attachable/proc/on_parent_deconstructed(obj/item/source, disassembled)
	SIGNAL_HANDLER

	if(QDELETED(bayonet) || !removable)
		remove_bayonet()
		return

	bayonet.forceMove(source.drop_location())

/datum/component/bayonet_attachable/proc/on_screwdriver(obj/item/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	if(!bayonet || !removable)
		return

	INVOKE_ASYNC(src, PROC_REF(unscrew_bayonet), source, user, tool)
	return ITEM_INTERACT_BLOCKING

/datum/component/bayonet_attachable/proc/unscrew_bayonet(obj/item/source, mob/user, obj/item/tool)
	tool?.play_tool_sound(source)
	source.balloon_alert(user, "unscrewed [bayonet]")

	var/obj/item/to_remove = bayonet
	to_remove.forceMove(source.drop_location())
	if(source.Adjacent(user) && !issilicon(user))
		user.put_in_hands(to_remove)

/datum/component/bayonet_attachable/proc/on_update_overlays(obj/item/source, list/overlays)
	SIGNAL_HANDLER

	if(!bayonet_overlay || !bayonet_overlay_icon)
		return

	if(!bayonet)
		return

	var/mutable_appearance/bayonet_appearance = mutable_appearance(bayonet_overlay_icon, bayonet_overlay)
	bayonet_appearance.pixel_x = offset_x
	bayonet_appearance.pixel_y = offset_y
	overlays += bayonet_appearance

/datum/component/bayonet_attachable/proc/on_update_icon_state(obj/item/source)
	SIGNAL_HANDLER

	if(!bayonet_icon_state)
		return

	var/base_state = source.base_icon_state || initial(source.icon_state)
	if(bayonet)
		source.icon_state = "[base_state]-[bayonet_icon_state]"
	else if(source.icon_state != base_state)
		source.icon_state = base_state

/datum/component/bayonet_attachable/proc/on_parent_deleted(obj/item/source)
	SIGNAL_HANDLER
	QDEL_NULL(bayonet)

/datum/component/bayonet_attachable/proc/on_being_sawnoff(obj/item/source, mob/user)
	SIGNAL_HANDLER

	if (!bayonet || allow_sawnoff)
		return
	source.balloon_alert(user, "bayonet must be removed!")
	return COMPONENT_CANCEL_SAWING_OFF

/datum/component/bayonet_attachable/proc/on_sawn_off(obj/item/source, mob/user)
	SIGNAL_HANDLER
	if (!allow_sawnoff)
		qdel(src)
