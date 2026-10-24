/datum/component/detonatable_by_hammer
	/// The mob currently holding this casing in a hand.
	var/mob/living/registered_holder
	/// Set before firing so multi-pellet casings cannot be triggered more than once.
	var/activated = FALSE
	/// The radius of the directional flame backblast.
	var/backblast_flame_range = 2
	/// Sound played when the casing fires.
	var/discharge_sound = 'sound/items/weapons/gun/general/grenade_launch.ogg'

/datum/component/detonatable_by_hammer/Initialize(backblast_flame_range = 2, discharge_sound = 'sound/items/weapons/gun/general/grenade_launch.ogg')
	if(!istype(parent, /obj/item/ammo_casing)) //only those who can be shot may pass
		return COMPONENT_INCOMPATIBLE
	if(backblast_flame_range < 0)
		return COMPONENT_INCOMPATIBLE
	src.backblast_flame_range = backblast_flame_range
	src.discharge_sound = discharge_sound

/datum/component/detonatable_by_hammer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_casing_item_interaction))
	RegisterSignal(parent, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_casing_requesting_context))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_parent_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_parent_dropped))

	// Components can be added after an item has already been equipped.
	var/obj/item/ammo_casing/casing = parent
	casing.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	if(istype(casing.loc, /mob/living))
		var/mob/living/holder = casing.loc
		if(casing in holder.get_held_items())
			register_holder(holder)

/datum/component/detonatable_by_hammer/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		COMSIG_ITEM_EQUIPPED,
		COMSIG_ITEM_DROPPED,
	))
	if(registered_holder)
		UnregisterSignal(registered_holder, list(
			COMSIG_ATOM_ITEM_INTERACTION,
			COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		))
		registered_holder = null

/// Register for interactions with the mob while this casing is held in a hand.
/datum/component/detonatable_by_hammer/proc/on_parent_equipped(obj/item/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	if(!(slot & ITEM_SLOT_HANDS))
		return
	register_holder(equipper)

/// Stop listening when the casing leaves its holder.
/datum/component/detonatable_by_hammer/proc/on_parent_dropped(obj/item/source, mob/living/dropper)
	SIGNAL_HANDLER
	if(registered_holder != dropper)
		return
	UnregisterSignal(dropper, list(
		COMSIG_ATOM_ITEM_INTERACTION,
		COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
	))
	registered_holder = null

/datum/component/detonatable_by_hammer/proc/register_holder(mob/living/holder)
	if(registered_holder == holder)
		return
	if(registered_holder)
		UnregisterSignal(registered_holder, list(
			COMSIG_ATOM_ITEM_INTERACTION,
			COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM,
		))
	registered_holder = holder
	holder.flags_1 |= HAS_CONTEXTUAL_SCREENTIPS_1
	RegisterSignal(holder, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(on_holder_item_interaction))
	RegisterSignal(holder, COMSIG_ATOM_REQUESTING_CONTEXT_FROM_ITEM, PROC_REF(on_holder_requesting_context))

/// Handle non-combat use of a claw hammer on the casing directly.
/datum/component/detonatable_by_hammer/proc/on_casing_item_interaction(obj/item/ammo_casing/casing, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(!istype(tool, /obj/item/crowbar/hammer) || user.combat_mode)
		return
	if(!casing.loaded_projectile || activated)
		return
	if(activate_casing(casing, user))
		return ITEM_INTERACT_SUCCESS

/// Handle non-combat use of a claw hammer on someone holding a live casing.
/datum/component/detonatable_by_hammer/proc/on_holder_item_interaction(mob/living/holder, mob/living/user, obj/item/tool, list/modifiers)
	SIGNAL_HANDLER
	if(holder != registered_holder || !istype(tool, /obj/item/crowbar/hammer) || user.combat_mode)
		return
	var/obj/item/ammo_casing/selected_casing = get_selected_live_casing(holder)
	if(!selected_casing)
		return
	if(parent != selected_casing)
		return
	var/obj/item/ammo_casing/casing = parent
	if(!activate_casing(casing, user, holder))
		return
	return ITEM_INTERACT_SUCCESS

/// Add a contextual hint when hovering over a live shell with a claw hammer.
/datum/component/detonatable_by_hammer/proc/on_casing_requesting_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	SIGNAL_HANDLER
	if(!istype(held_item, /obj/item/crowbar/hammer) || user.combat_mode)
		return NONE
	var/obj/item/ammo_casing/casing = parent
	if(!casing.loaded_projectile || activated)
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Strike shell"
	return CONTEXTUAL_SCREENTIP_SET

/// Add a contextual hint when hovering over someone holding a live shell with a claw hammer.
/datum/component/detonatable_by_hammer/proc/on_holder_requesting_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	SIGNAL_HANDLER
	if(!istype(held_item, /obj/item/crowbar/hammer) || user.combat_mode)
		return NONE
	var/mob/living/holder = source
	if(holder != registered_holder || !get_selected_live_casing(holder))
		return NONE
	context[SCREENTIP_CONTEXT_LMB] = "Strike held shell"
	return CONTEXTUAL_SCREENTIP_SET

/// Pick the active-hand casing first, then the other hand, considering only casings with this component.
/datum/component/detonatable_by_hammer/proc/get_selected_live_casing(mob/living/holder)
	var/obj/item/ammo_casing/casing = get_live_attached_casing(holder.get_active_held_item())
	if(casing)
		return casing

	casing = get_live_attached_casing(holder.get_inactive_held_item())
	if(casing)
		return casing
	return null

/// Return a live casing only when it has this component.
/datum/component/detonatable_by_hammer/proc/get_live_attached_casing(obj/item/held_item)
	if(!istype(held_item, /obj/item/ammo_casing))
		return null
	var/obj/item/ammo_casing/casing = held_item
	var/datum/component/detonatable_by_hammer/casing_component = casing.GetComponent(/datum/component/detonatable_by_hammer)
	if(!casing.loaded_projectile || !casing_component || casing_component.activated)
		return null
	return casing

/// Fire this casing's own projectile and apply the handling backfire.
/datum/component/detonatable_by_hammer/proc/activate_casing(obj/item/ammo_casing/casing, mob/living/hitter, mob/living/holder)
	if(activated || !casing.loaded_projectile || !istype(hitter))
		return FALSE

	var/turf/launch_turf = get_turf(casing)
	if(!launch_turf)
		return FALSE
	var/firing_direction = holder ? holder.dir : casing.dir
	var/turf/target_turf = get_ranged_target_turf(launch_turf, firing_direction, 50)
	if(!target_turf)
		return FALSE

	// Lock before firing: flak pellet creation can leave the casing live until async projectile setup runs, not epic.
	activated = TRUE
	if(holder)
		holder.visible_message(
			span_danger("[hitter] strikes [casing] in [holder]'s hand, setting it off!"),
			span_userdanger("[hitter] strikes the [casing] in your hand, setting it off!"),
		)
	else
		hitter.visible_message(span_danger("[hitter] strikes [casing] with a claw hammer, setting it off!"))

	playsound(launch_turf, discharge_sound, 80, TRUE)
	if(!casing.fire_casing(target_turf, hitter, null, 0, FALSE, BODY_ZONE_CHEST, 0, launch_turf))
		activated = FALSE
		return FALSE

	///nerf this *backblasts*
	var/backblast_direction = get_angle(target_turf, launch_turf)
	explosion(
		casing,
		flame_range = backblast_flame_range,
		adminlog = FALSE,
		protect_epicenter = TRUE,
		explosion_direction = backblast_direction,
		explosion_arc = 60,
	)

	if(holder)
		holder.apply_damage(15, BRUTE, BODY_ZONE_CHEST, attacking_item = casing)
		holder.apply_damage(15, BURN, BODY_ZONE_CHEST, attacking_item = casing)
	hitter.apply_damage(25, BRUTE, BODY_ZONE_CHEST, attacking_item = casing)
	hitter.apply_damage(25, BURN, BODY_ZONE_CHEST, attacking_item = casing)
	return TRUE
