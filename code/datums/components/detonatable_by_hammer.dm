/// Key in attack_modifiers used to remember which casing was selected for this attack.
#define DETONATABLE_BY_HAMMER_SELECTED_CASING "detonatable_by_hammer_selected_casing"

/datum/component/detonatable_by_hammer
	/// The mob currently holding this casing in a hand.
	var/mob/living/registered_holder
	/// Set before firing so multi-pellet casings cannot be triggered more than once.
	var/activated = FALSE

/datum/component/detonatable_by_hammer/Initialize()
	if(!istype(parent, /obj/item/ammo_casing)) //only those who can be shot may pass
		return COMPONENT_INCOMPATIBLE

/datum/component/detonatable_by_hammer/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_casing_attackby))
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_parent_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_parent_dropped))

	// Components can be added after an item has already been equipped.
	var/obj/item/ammo_casing/casing = parent
	var/mob/living/holder = casing.loc
	if(istype(holder) && casing in holder.get_held_items())
		register_holder(holder)

/datum/component/detonatable_by_hammer/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ATOM_ATTACKBY, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))
	if(registered_holder)
		UnregisterSignal(registered_holder, COMSIG_ATOM_ATTACKBY)
		registered_holder = null

/// Register for attacks against the mob while this casing is held in a hand.
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
	UnregisterSignal(dropper, COMSIG_ATOM_ATTACKBY)
	registered_holder = null

/datum/component/detonatable_by_hammer/proc/register_holder(mob/living/holder)
	if(registered_holder == holder)
		return
	if(registered_holder)
		UnregisterSignal(registered_holder, COMSIG_ATOM_ATTACKBY)
	registered_holder = holder
	RegisterSignal(holder, COMSIG_ATOM_ATTACKBY, PROC_REF(on_holder_attackby))

/// Handle a claw hammer striking the casing directly.
/datum/component/detonatable_by_hammer/proc/on_casing_attackby(obj/item/ammo_casing/casing, obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER
	if(!istype(attacking_item, /obj/item/crowbar/hammer))
		return
	if(!casing.loaded_projectile || activated)
		return
	if(activate_casing(casing, user))
		return COMPONENT_NO_AFTERATTACK

/// Intercept the holder's attack-by signal before the claw hammer's normal attack runs.
/datum/component/detonatable_by_hammer/proc/on_holder_attackby(mob/living/holder, obj/item/attacking_item, mob/living/attacker, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER
	if(holder != registered_holder || !istype(attacking_item, /obj/item/crowbar/hammer))
		return
	if(!istype(attacker) || attacker.combat_mode || attacker.zone_selected != BODY_ZONE_PRECISE_MOUTH)
		return
	if(!islist(attack_modifiers))
		return
	var/obj/item/ammo_casing/selected_casing = attack_modifiers[DETONATABLE_BY_HAMMER_SELECTED_CASING]
	if(!selected_casing)
		selected_casing = get_selected_live_casing(holder)
		if(!selected_casing)
			return
		// This list is shared through the attack chain. Cache the choice so another casing listener cannot select a second casing after this one discharges.
		attack_modifiers[DETONATABLE_BY_HAMMER_SELECTED_CASING] = selected_casing
	if(parent != selected_casing)
		return
	var/obj/item/ammo_casing/casing = parent
	if(!activate_casing(casing, attacker, holder))
		return
	return COMPONENT_NO_AFTERATTACK

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
	if(!casing.loaded_projectile || !casing.GetComponent(/datum/component/detonatable_by_hammer))
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
			span_danger("[hitter] swings at [holder]'s mouth, but [casing] in [holder.p_their()] hand discharges!"),
			span_userdanger("[hitter] swings at your mouth, but [casing] in your hand discharges!"),
		)
	else
		hitter.visible_message(span_danger("[hitter] strikes [casing] with a claw hammer, setting it off!"))

	playsound(launch_turf, 'sound/items/weapons/gun/general/grenade_launch.ogg', 80, TRUE)
	if(!casing.fire_casing(target_turf, hitter, null, 0, FALSE, BODY_ZONE_CHEST, 0, launch_turf))
		activated = FALSE
		return FALSE

	///nerf this *backblasts*
	var/backblast_direction = get_angle(target_turf, launch_turf)
	explosion(
		casing,
		light_impact_range = 0,
		flame_range = 2,
		adminlog = FALSE,
		protect_epicenter = TRUE,
		explosion_direction = backblast_direction,
		explosion_arc = 60,
	)

	if(holder)
		holder.apply_damage(15, BRUTE, BODY_ZONE_CHEST, forced = TRUE, attacking_item = casing)
		holder.apply_damage(15, BURN, BODY_ZONE_CHEST, forced = TRUE, attacking_item = casing)
	hitter.apply_damage(25, BRUTE, BODY_ZONE_CHEST, forced = TRUE, attacking_item = casing)
	hitter.apply_damage(25, BURN, BODY_ZONE_CHEST, forced = TRUE, attacking_item = casing)
	return TRUE

#undef DETONATABLE_BY_HAMMER_SELECTED_CASING
