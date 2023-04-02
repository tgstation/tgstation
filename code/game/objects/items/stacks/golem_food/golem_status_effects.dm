/// Abstract holder for golem status effects, you should never have more than one of these active
/datum/status_effect/golem
	id = "golem_status"
	status_type = STATUS_EFFECT_REFRESH
	duration = 30 SECONDS
	/// Icon state prefix for overlay to display on golem limbs
	var/overlay_state_prefix
	/// Maximum time to extend buff for
	var/max_duration = 5 MINUTES
	/// Name of the mineral we ate to get this
	var/mineral_name = ""
	/// Text to display on buff application
	var/applied_fluff = ""
	/// Overlays we have applied to our mob
	var/list/active_overlays = list()

/datum/status_effect/golem/on_apply()
	. = ..()
	if (!ishuman(owner))
		return FALSE
	if (owner.has_status_effect(/datum/status_effect/golem) )
		return FALSE
	if (applied_fluff)
		to_chat(owner, span_notice(applied_fluff))
	if (!overlay_state_prefix || !iscarbon(owner))
		return TRUE
	var/mob/living/carbon/golem_owner = owner
	for (var/obj/item/bodypart/part in golem_owner.bodyparts)
		if (part.limb_id != SPECIES_GOLEM)
			continue
		var/datum/bodypart_overlay/simple/golem_overlay/overlay = new()
		overlay.add_to_bodypart(overlay_state_prefix, part)
		active_overlays += overlay
	golem_owner.update_body_parts()
	return TRUE

// Add 30 seconds up until we reach 5 minutess
/datum/status_effect/golem/refresh(effect)
	duration = min(duration + initial(duration), world.time + max_duration)

/datum/status_effect/golem/on_remove()
	to_chat(owner, span_warning("The effect of the [mineral_name] fades."))
	QDEL_LIST(active_overlays)
	return ..()

/// Body part overlays applied by golem status effects
/datum/bodypart_overlay/simple/golem_overlay
	icon = 'icons/mob/species/golems.dmi'
	layers = ALL_EXTERNAL_OVERLAYS
	///The bodypart that the overlay is currently applied to
	var/datum/weakref/attached_bodypart

/datum/bodypart_overlay/simple/golem_overlay/proc/add_to_bodypart(prefix, obj/item/bodypart/part)
	icon_state = "[prefix]_[part.body_zone]"
	attached_bodypart = WEAKREF(part)
	part.add_bodypart_overlay(src)

/datum/bodypart_overlay/simple/golem_overlay/Destroy(force)
	var/obj/item/bodypart/referenced_bodypart = attached_bodypart.resolve()
	if(!referenced_bodypart)
		return ..()
	referenced_bodypart.remove_bodypart_overlay(src)
	if(referenced_bodypart.owner) //Keep in mind that the bodypart could have been severed from the owner by now
		referenced_bodypart.owner.update_body_parts()
	else
		referenced_bodypart.update_icon_dropped()
	return ..()

/// Freezes hunger for the duration
/datum/status_effect/golem/uranium
	overlay_state_prefix = "uranium"
	mineral_name = "uranium"
	applied_fluff = "Glowing crystals sprout from your body. You feel energised!"

/datum/status_effect/golem/uranium/on_apply()
	. = ..()
	if (!.)
		return FALSE
	ADD_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/golem_hunger)
	owner.remove_status_effect(/datum/status_effect/golem_statued) // Instant fix!
	return TRUE

/datum/status_effect/golem/uranium/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NOHUNGER, TRAIT_STATUS_EFFECT(id))
	return ..()

/// Magic immunity
/datum/status_effect/golem/silver
	overlay_state_prefix = "silver"
	mineral_name = "silver"
	applied_fluff = "Shining plates grace your shoulders. You feel holy!"

/datum/status_effect/golem/silver/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.add_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem/silver/on_remove()
	owner.remove_traits(list(TRAIT_ANTIMAGIC, TRAIT_HOLY), TRAIT_STATUS_EFFECT(id))
	return ..()

/// Heat immunity, turns heat damage into local power
/datum/status_effect/golem/plasma
	overlay_state_prefix = "plasma"
	mineral_name = "plasma"
	applied_fluff = "Plasma cooling rods sprout from your body. You can take the heat!"
	/// What do we multiply our damage by to convert it into power?
	var/power_multiplier = 5
	/// Multiplier to apply to burn damage, not 0 so that we can reverse it more easily
	var/burn_multiplier = 0.05

/datum/status_effect/golem/plasma/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.add_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTHEAT), TRAIT_STATUS_EFFECT(id))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_burned))
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.burn_mod *= burn_multiplier
	return TRUE

/datum/status_effect/golem/plasma/on_remove()
	owner.remove_traits(list(TRAIT_RESISTHIGHPRESSURE, TRAIT_RESISTHEAT), TRAIT_STATUS_EFFECT(id))
	UnregisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE)
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.burn_mod /= burn_multiplier
	return ..()

/// When we take fire damage (or... technically also cold damage, we don't differentiate), zap a nearby APC
/datum/status_effect/golem/plasma/proc/on_burned(datum/source, damage, damagetype)
	SIGNAL_HANDLER
	if(damagetype != BURN)
		return

	var/power = damage * power_multiplier
	var/obj/machinery/power/energy_accumulator/ground = get_closest_atom(/obj/machinery/power/energy_accumulator, view(4, owner), owner)
	if (ground)
		zap_effect(ground)
		ground.zap_act(damage, ZAP_GENERATES_POWER)
		return
	var/area/our_area = get_area(owner)
	var/obj/machinery/power/apc/our_apc = our_area.apc
	if (!our_apc)
		return
	zap_effect(our_apc)
	our_apc.cell?.give(power)

/// Shoot a beam at the target atom
/datum/status_effect/golem/plasma/proc/zap_effect(atom/target)
	owner.Beam(target, icon_state="lightning[rand(1,12)]", time = 0.5 SECONDS)
	playsound(owner, 'sound/magic/lightningshock.ogg', vol = 50, vary = TRUE)

/// Makes you spaceproof
/datum/status_effect/golem/plasteel
	overlay_state_prefix = "iron"
	mineral_name = "plasteel"
	applied_fluff = "Plasteel plates seal you tight. You feel insulated!"

/datum/status_effect/golem/plasteel/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.add_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), TRAIT_STATUS_EFFECT(id))
	return TRUE

/datum/status_effect/golem/plasteel/on_remove()
	owner.remove_traits(list(TRAIT_RESISTLOWPRESSURE, TRAIT_RESISTCOLD), TRAIT_STATUS_EFFECT(id))
	return ..()

/// Makes you reflect energy projectiles
/datum/status_effect/golem/gold
	overlay_state_prefix = "gold"
	mineral_name = "gold"
	applied_fluff = "Shining plates form across your body. You feel reflective!"

/datum/status_effect/golem/gold/on_apply()
	. = ..()
	if (!.)
		return FALSE
	owner.flags_ricochet = RICOCHET_SHINY
	return TRUE

/datum/status_effect/golem/gold/on_remove()
	owner.flags_ricochet = NONE
	return ..()

/// Makes you hard to see
/datum/status_effect/golem/diamond
	overlay_state_prefix = "diamond"
	mineral_name = "diamonds"
	applied_fluff = "Sparkling gems bend light around you. You feel stealthy!"
	tick_interval = 0.25 SECONDS
	/// Alpha to remove per second while stood still
	var/alpha_per_tick = 25
	/// Alpha to apply while moving
	var/moving_alpha = 150
	/// List of arms we have updated
	var/list/modified_arms

/datum/status_effect/golem/diamond/on_apply()
	. = ..()
	if (!.)
		return FALSE
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	owner.alpha = moving_alpha
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/light_speed)

	var/mob/living/carbon/carbon_owner = owner
	for (var/obj/item/bodypart/arm/arm in carbon_owner.bodyparts)
		if (arm.limb_id != SPECIES_GOLEM)
			continue
		set_arm_fluff(arm)
	return TRUE

/datum/status_effect/golem/diamond/tick(delta_time, times_fired)
	owner.alpha = max(owner.alpha - alpha_per_tick, 0)

/// Reset alpha to starting value
/datum/status_effect/golem/diamond/proc/on_move()
	SIGNAL_HANDLER
	owner.alpha = moving_alpha

/// Make our arm do slashing effects
/datum/status_effect/golem/diamond/proc/set_arm_fluff(obj/item/bodypart/arm/arm)
	arm.unarmed_attack_verb = "slash"
	arm.unarmed_attack_effect = ATTACK_EFFECT_CLAW
	arm.unarmed_attack_sound = 'sound/weapons/slash.ogg'
	arm.unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'
	LAZYADD(modified_arms, WEAKREF(arm))

/datum/status_effect/golem/diamond/on_remove()
	owner.alpha = initial(owner.alpha)
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/light_speed)
	UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
	for (var/datum/weakref/weak_arm as anything in modified_arms)
		reset_arm_fluff(weak_arm.resolve())
	LAZYCLEARLIST(modified_arms)
	return ..()

/// Make our arm do whatever it originally did
/datum/status_effect/golem/diamond/proc/reset_arm_fluff(obj/item/bodypart/arm/arm)
	if (!arm)
		return
	arm.unarmed_attack_verb = initial(arm.unarmed_attack_verb)
	arm.unarmed_attack_effect = initial(arm.unarmed_attack_effect)
	arm.unarmed_attack_sound = initial(arm.unarmed_attack_sound)
	arm.unarmed_miss_sound = initial(arm.unarmed_miss_sound)

/// Makes you tougher
/datum/status_effect/golem/titanium
	overlay_state_prefix = "platinum"
	mineral_name = "titanium"
	applied_fluff = "Titanium rings burst from your arms. You feel ready to take on the world!"
	/// Amount to reduce brute damage by
	var/brute_modifier = 0.5
	/// How much extra damage do we do with our fists?
	var/damage_increase = 5
	/// List of arms we have updated
	var/list/modified_arms

/datum/status_effect/golem/titanium/on_apply()
	. = ..()
	if (!.)
		return FALSE
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.brute_mod *= brute_modifier
	for (var/obj/item/bodypart/arm/arm in human_owner.bodyparts)
		if (arm.limb_id != SPECIES_GOLEM)
			continue
		buff_arm(arm)

/// Make the targeted arm big and strong
/datum/status_effect/golem/titanium/proc/buff_arm(obj/item/bodypart/arm/arm)
	arm.unarmed_damage_low += damage_increase
	arm.unarmed_damage_high += damage_increase
	arm.unarmed_stun_threshold += damage_increase // We don't want to make knockdown more likely
	LAZYADD(modified_arms, WEAKREF(arm))

/datum/status_effect/golem/titanium/on_remove()
	var/mob/living/carbon/human/human_owner = owner
	human_owner.physiology.brute_mod /= brute_modifier
	for (var/datum/weakref/weak_arm as anything in modified_arms)
		debuff_arm(weak_arm.resolve())
	LAZYCLEARLIST(modified_arms)
	return ..()

/// Make the targeted arm small and weak
/datum/status_effect/golem/titanium/proc/debuff_arm(obj/item/bodypart/arm/arm)
	if (!arm)
		return
	arm.unarmed_damage_low -= damage_increase
	arm.unarmed_damage_high -= damage_increase
	arm.unarmed_stun_threshold -= damage_increase

/// Makes you slippery
/datum/status_effect/golem/bananium
	overlay_state_prefix = "banana"
	mineral_name = "bananium"
	applied_fluff = "Bananium veins ooze from your crags. You feel a little funny!"
	var/datum/component/slippery/slipperiness

/datum/status_effect/golem/bananium/on_apply()
	. = ..()
	if (!.)
		return
	owner.AddElement(/datum/element/waddling)
	ADD_TRAIT(owner, TRAIT_NO_SLIP_WATER, TRAIT_STATUS_EFFECT(id))
	slipperiness = owner.AddComponent(/datum/component/slippery, knockdown = 12 SECONDS, lube_flags = NO_SLIP_WHEN_WALKING)

/datum/status_effect/golem/bananium/on_remove()
	REMOVE_TRAIT(owner, TRAIT_NO_SLIP_WATER, TRAIT_STATUS_EFFECT(id))
	owner.RemoveElement(/datum/element/waddling)
	QDEL_NULL(slipperiness)
	return ..()
