/mob/living
	var/rogue_dual_paired = FALSE

/mob/living/carbon/human
	var/rogue_dual_count = 0
	var/rogue_dual_finisher = FALSE
	var/rogue_dual_reset_at = 0

/mob/living/carbon/human/proc/rogue_can_dual_wield(obj/item/mainhand, obj/item/offhand)
	if(!mainhand || !offhand)
		return FALSE
	for(var/obj/item/held as anything in list(mainhand, offhand))
		if(istype(held, /obj/item/rogueweapon/shield) || istype(held, /obj/item/flashlight))
			return FALSE
		if(held.rogue_wielded || held.w_class >= WEIGHT_CLASS_HUGE || held.wlength >= WLENGTH_GREAT || held.force < ROGUE_DUAL_WIELD_MIN_FORCE)
			return FALSE
		if(held.associated_skill && rogue_weapon_rank(held) < ROGUE_DUAL_WIELD_RANK)
			return FALSE
	return TRUE

/mob/living/carbon/human/proc/rogue_arm_grabbed(hand_index)
	var/side = IS_RIGHT_INDEX(hand_index) ? "r" : "l"
	var/mob/living/carbon/human/grabber = pulledby
	if(!istype(grabber))
		return FALSE
	for(var/obj/item/hand_item/rogue_grab/grip in grabber.held_items)
		if(grip.grabbed == src && (grip.zone == "[side]_arm" || grip.zone == "[side]_hand"))
			return TRUE
	return FALSE

/mob/living/carbon/human/proc/rogue_dual_wield_step(obj/item/weapon)
	if(!HAS_TRAIT(src, TRAIT_DUALWIELDER) || rogue_dual_paired)
		return FALSE
	if(weapon)
		var/obj/item/offhand = get_inactive_held_item()
		if(!offhand || weapon == offhand || weapon != get_active_held_item() || rogue_arm_grabbed(get_inactive_hand_index()) || !rogue_can_dual_wield(weapon, offhand))
			return FALSE
	else if(get_active_held_item() || get_inactive_held_item())
		return FALSE
	if(world.time > rogue_dual_reset_at)
		rogue_dual_count = 0
		rogue_dual_finisher = FALSE
	rogue_dual_reset_at = world.time + ROGUE_DUAL_WIELD_RESET
	if(rogue_dual_finisher)
		rogue_dual_finisher = FALSE
		swap_hand(get_inactive_hand_index())
		return TRUE
	if(++rogue_dual_count >= ROGUE_DUAL_WIELD_COMBO)
		rogue_dual_count = 0
		rogue_dual_finisher = TRUE
	if(weapon)
		swap_hand(get_inactive_hand_index())
	return FALSE

/mob/living/carbon/human/proc/rogue_paired_strike(mob/living/target)
	var/obj/item/paired_weapon = get_active_held_item()
	if(QDELETED(target) || incapacitated || !target.IsReachableBy(src, paired_weapon ? paired_weapon.reach : 1))
		return
	var/datum/intent/intent = rogue_strike_intent(paired_weapon)
	if(!intent || intent.no_attack || intent.tranged || get_stamina_loss() + ROGUE_DUAL_WIELD_STAMINA >= max_stamina)
		return
	adjust_stamina_loss(ROGUE_DUAL_WIELD_STAMINA)
	balloon_alert_to_viewers("dual hit!!")
	to_chat(src, span_notice("I strike twice!"))
	to_chat(target, span_warning("I am hit twice!"))
	rogue_dual_paired = TRUE
	rogue_strike(target, paired_weapon, intent)
	rogue_dual_paired = FALSE
	playsound_local(get_turf(target), 'modular_redtard/rockhill/sound/combat/polearm_woosh.ogg', 75, FALSE)
	playsound_local(get_turf(target), 'modular_redtard/rockhill/sound/combat/rend_hit.ogg', 75, FALSE)
