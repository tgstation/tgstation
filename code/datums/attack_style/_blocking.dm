/**
 * # Blocking
 *
 * Blocking incoming attacks, converting it to stamina damage.
 */
/datum/status_effect/blocking
	id = "blocking"
	alert_type = /atom/movable/screen/alert/status_effect/blocking
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = 1 SECONDS
	duration = -1

	VAR_FINAL/obj/item/blocking_with
	VAR_FINAL/mutable_appearance/shield_overlay

	var/blocking_icon = 'icons/effects/blocking.dmi'

/datum/status_effect/blocking/on_creation(mob/living/new_owner, obj/item/new_blocker)
	. = ..()
	if(!.)
		return
	if(!isnull(new_blocker))
		set_blocking_item(new_blocker)

	var/static/shield_offset_const = (0.8 * world.icon_size)
	shield_overlay = mutable_appearance(
		icon = blocking_icon,
		icon_state = "shield100",
		alpha = min(new_owner.alpha, 125),
		layer = new_owner.layer + 0.1,
	)
	SET_PLANE_EXPLICIT(shield_overlay, new_owner.plane, new_owner)
	shield_overlay.pixel_y = new_owner.pixel_y + shield_offset_const
	shield_overlay.color = LIGHT_COLOR_BABY_BLUE
	owner.add_overlay(shield_overlay)
	update_shield()

/datum/status_effect/blocking/on_apply()
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_attacked))
	RegisterSignals(owner, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_LIVING_HEALTH_UPDATE), PROC_REF(on_health_update))
	return TRUE

/datum/status_effect/blocking/refresh(effect, obj/item/new_blocker)
	if(isnull(new_blocker))
		if(!isnull(blocking_with))
			clear_blocking_item()
	else
		set_blocking_item(new_blocker)

/datum/status_effect/blocking/on_remove()
	owner.cut_overlay(shield_overlay)
	UnregisterSignal(owner, list(
		COMSIG_LIVING_CHECK_BLOCK,
		COMSIG_LIVING_HEALTH_UPDATE,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_MOB_APPLY_DAMAGE,
	))

/datum/status_effect/blocking/Destroy()
	if(blocking_with)
		clear_blocking_item()
	return ..()

/datum/status_effect/blocking/tick(seconds_per_tick, times_fired)
	if(iscarbon(owner))
		// every tick we will set the mob's stamina regen start time the next time this status effect will tick
		// this is so blocking prevents all stamina regen while active
		// (though we use a max to prevent memes like 1-tick blocking to reset stamina regen period)
		var/mob/living/carbon/carbon_owner = owner
		carbon_owner.stam_regen_start_time = max(carbon_owner.stam_regen_start_time , tick_interval)

	update_shield()

/datum/status_effect/blocking/proc/update_shield()
	if(QDELING(src))
		return

	var/percent = round(100 - ((owner.getStaminaLoss() / owner.maxHealth) * 100), 10)
	var/new_icon_state = "shield[percent]"
	if(percent <= 0)
		owner.visible_message(span_danger("[owner]'s guard is broken!"), span_userdanger("Your guard is broken!"))
		qdel(src)

	else if(shield_overlay.icon_state != new_icon_state)
		owner.cut_overlay(shield_overlay)
		shield_overlay.icon_state = "shield[percent]"
		owner.add_overlay(shield_overlay)


/datum/status_effect/blocking/proc/set_blocking_item(obj/item/new_blocker)
	blocking_with = new_blocker
	RegisterSignals(blocking_with, list(COMSIG_PARENT_QDELETING, COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), PROC_REF(stop_blocking))
	linked_alert.update_appearance(UPDATE_DESC)

/datum/status_effect/blocking/proc/clear_blocking_item()
	UnregisterSignal(blocking_with, list(
		COMSIG_PARENT_QDELETING,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
	))

	blocking_with = null
	if(!QDELETED(linked_alert))
		linked_alert.update_appearance(UPDATE_DESC)

/datum/status_effect/blocking/proc/stop_blocking(obj/item/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/blocking/proc/on_attacked(mob/living/source, atom/movable/hitby, damage, attack_text, attack_type, armour_penetration)
	SIGNAL_HANDLER

	// if(attack_type != MELEE_ATTACK && attack_type != UNARMED_ATTACK)
	//	return NONE

	if(isobj(hitby))
		var/obj/obj_hit = hitby
		if(obj_hit.damtype == STAMINA)
			// Stamina damage will go though blocking for now
			// Originally I intended for stam attacks to be blocked but not apply item defense multiplier
			// But I realized that it'd be identical anyways, so pointless to continue
			// Subject to change
			return NONE

	if(damage <= 0)
		return NONE

	// Depending on the item (or lack thereof) you are blocking with, the damage taken is converted to more (or maybe less!) stamina damage
	var/defense_multiplier = blocking_with ? blocking_with.blocking_ability : BARE_HAND_DEFENSE_MULTIPLIER
	var/final_damage = defense_multiplier * damage
	if(final_damage <= 0)
		return NONE

	source.apply_damage(final_damage, STAMINA, spread_damage = TRUE)
	// Stops all following effects of the attack.
	return SUCCESSFUL_BLOCK

/datum/status_effect/blocking/proc/on_health_update(mob/living/source)
	SIGNAL_HANDLER

	update_shield()

/atom/movable/screen/alert/status_effect/blocking
	name = "Blocking"
	desc = "You're blocking incoming attacks.\
		This will prevent you from taking physical damage, but drain your stamina.\
		You also won't regenerate stamina while blocking."
	icon = 'icons/effects/blocking.dmi'
	icon_state = "block_alert"

/atom/movable/screen/alert/status_effect/blocking/update_desc(updates)
	. = ..()
	desc = initial(desc)
	var/datum/status_effect/blocking/blocking_effect = attached_effect
	ASSERT(istype(blocking_effect))
	if(blocking_effect.blocking_with)
		desc += "You are blocking with [blocking_effect.blocking_with], \
			which has an effectiveness of [blocking_effect.blocking_with.blocking_ability]."
	else
		desc += "You are blocking with your bare hands, \
			which has an effectiveness of [BARE_HAND_DEFENSE_MULTIPLIER]."
