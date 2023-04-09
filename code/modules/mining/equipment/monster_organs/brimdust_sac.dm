/// Interval between passively gaining stacks on lavaland if organ is implanted
#define BRIMDUST_LIFE_APPLY_COOLDOWN (30 SECONDS)
/// Number of stacks to add over time
#define BRIMDUST_STACKS_ON_LIFE 1
/// Number of stacks to add if you activate the item in hand
#define BRIMDUST_STACKS_ON_USE 3

/**
 * Gives you three stacks of Brimdust Coating, when you get hit by anything it will make a short ranged explosion.
 * If this happens on the station it does much less damage, and slows down the bearer.
 * If implanted, you can shake off a cloud of brimdust to give this buff to people around you.area
 * It will also automatically grant you one stack every 30 seconds if you are on lavaland.
 */
/obj/item/organ/internal/monster_core/brimdust_sac
	name = "brimdust sac"
	desc = "A strange organ from a brimdemon. You can shake it out to coat yourself in explosive powder."
	icon_state = "brim_sac"
	icon_state_preserved = "brim_sac_stable"
	icon_state_inert = "brim_sac_decayed"
	desc_preserved = "A strange organ from a brimdemon. It is preserved, allowing you to coat yourself in its explosive contents at your leisure."
	desc_inert = "A decayed brimdemon organ. There's nothing usable left inside it."
	user_status = /datum/status_effect/stacking/brimdust_coating
	actions_types = list(/datum/action/cooldown/monster_core_action/exhale_brimdust)
	/// You will gain a stack of the buff every x seconds
	COOLDOWN_DECLARE(brimdust_auto_apply_cooldown)

/obj/item/organ/internal/monster_core/brimdust_sac/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/explodable, light_impact_range = 1)

/obj/item/organ/internal/monster_core/brimdust_sac/apply_to(mob/living/target, mob/user)
	target.apply_status_effect(user_status, BRIMDUST_STACKS_ON_USE)
	qdel(src)

// Every x seconds, if on lavaland, add one stack
/obj/item/organ/internal/monster_core/brimdust_sac/on_life(delta_time, times_fired)
	. = ..()
	if(!COOLDOWN_FINISHED(src, brimdust_auto_apply_cooldown))
		return
	if(!lavaland_equipment_pressure_check(get_turf(owner)))
		return
	COOLDOWN_START(src, brimdust_auto_apply_cooldown, BRIMDUST_LIFE_APPLY_COOLDOWN)
	owner.apply_status_effect(user_status, BRIMDUST_STACKS_ON_LIFE)

/// Make a cloud which applies brimdust to everyone nearby
/obj/item/organ/internal/monster_core/brimdust_sac/on_triggered_internal()
	var/turf/origin_turf = get_turf(owner)
	do_smoke(range = 2, holder = owner, location = origin_turf, smoke_type = /obj/effect/particle_effect/fluid/smoke/bad/brimdust)

/// Smoke which applies brimdust to you, and is also bad for your lungs
/obj/effect/particle_effect/fluid/smoke/bad/brimdust
	lifetime = 8 SECONDS
	color = "#383838"

/obj/effect/particle_effect/fluid/smoke/bad/brimdust/smoke_mob(mob/living/carbon/smoker)
	if(!istype(smoker))
		return FALSE
	if(lifetime < 1)
		return FALSE
	if(smoker.smoke_delay)
		return FALSE
	smoker.apply_status_effect(/datum/status_effect/stacking/brimdust_coating, BRIMDUST_STACKS_ON_LIFE)
	return ..()

/**
 * If you take brute damage with this buff, hurt and push everyone next to you.
 * If you catch fire and or on the space station, detonate all remaining stacks in a way which hurts you.
 * Washes off if you get wet.
 */
/datum/status_effect/stacking/brimdust_coating
	id = "brimdust_coating"
	stacks = 0
	max_stacks = 3
	tick_interval = -1
	consumed_on_threshold = FALSE
	alert_type = /atom/movable/screen/alert/status_effect/brimdust_coating
	status_type = STATUS_EFFECT_REFRESH // Allows us to add one stack at a time by just applying the effect
	/// Damage to deal on explosion
	var/blast_damage = 40
	/// Damage reduction when not in a mining pressure area
	var/pressure_modifier = 0.25
	/// Time to wait between consuming stacks
	var/delay_between_explosions = 5 SECONDS
	/// Cooldown between explosions
	COOLDOWN_DECLARE(explosion_cooldown)
	/// Overlay effect added to mob when buff is present
	var/mutable_appearance/dust_overlay

/atom/movable/screen/alert/status_effect/brimdust_coating
	name = "Brimdust Coating"
	desc = "You %STACKS% explosive dust, kinetic impacts will cause it to detonate! \
		The explosion will not harm you as long as you're not under atmospheric pressure."

/atom/movable/screen/alert/status_effect/brimdust_coating/MouseEntered(location,control,params)
	desc = initial(desc)
	var/datum/status_effect/stacking/brimdust_coating/dust = attached_effect
	var/dust_amount_string
	switch(dust.stacks)
		if (3)
			dust_amount_string = "are heavily caked in"
		if (2)
			dust_amount_string = "have a generous coating of"
		if (1)
			dust_amount_string = "are lightly sprinkled with"

	desc = replacetext(desc, "%STACKS%", dust_amount_string)
	return ..()

/datum/status_effect/stacking/brimdust_coating/refresh(effect, stacks_to_add)
	. = ..()
	add_stacks(stacks_to_add)

/datum/status_effect/stacking/brimdust_coating/add_stacks(stacks_added)
	. = ..()
	if (stacks == 0)
		return
	linked_alert.icon_state = "brimdemon_[stacks]"

/datum/status_effect/stacking/brimdust_coating/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	linked_alert?.icon_state = "brimdemon_[stacks]"

/datum/status_effect/stacking/brimdust_coating/on_apply()
	. = ..()

	dust_overlay = mutable_appearance('icons/effects/weather_effects.dmi', "ash_storm")
	dust_overlay.blend_mode = BLEND_INSET_OVERLAY
	owner.add_overlay(dust_overlay)
	RegisterSignal(owner, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_cleaned))
	RegisterSignal(owner, COMSIG_MOB_APPLY_DAMAGE, PROC_REF(on_take_damage))

/datum/status_effect/stacking/brimdust_coating/on_remove()
	. = ..()
	owner.cut_overlay(dust_overlay)
	UnregisterSignal(owner, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_COMPONENT_CLEAN_ACT))

/// When you are cleaned, wash off the buff
/datum/status_effect/stacking/brimdust_coating/proc/on_cleaned()
	SIGNAL_HANDLER
	owner.remove_status_effect(/datum/status_effect/stacking/brimdust_coating)
	return COMPONENT_CLEANED

/// When you take brute damage, schedule an explosion
/datum/status_effect/stacking/brimdust_coating/proc/on_take_damage(datum/source, damage, damagetype)
	SIGNAL_HANDLER
	if(damagetype != BRUTE)
		return
	if(!COOLDOWN_FINISHED(src, explosion_cooldown))
		return
	owner.visible_message(span_boldwarning("The brimstone dust surrounding [owner] ignites!"))
	addtimer(CALLBACK(src, PROC_REF(explode)), 0.25 SECONDS)
	COOLDOWN_START(src, explosion_cooldown, delay_between_explosions)

/**
 * Hurts everything in a circle around you. Hurts less if in a pressurised environment.
 */
/datum/status_effect/stacking/brimdust_coating/proc/explode()
	var/turf/origin_turf = get_turf(owner)
	playsound(origin_turf, 'sound/effects/pop_expl.ogg', 50)
	new /obj/effect/temp_visual/explosion/fast(origin_turf)

	var/damage_dealt = blast_damage
	var/list/possible_targets = range(1, origin_turf)
	if(lavaland_equipment_pressure_check(origin_turf))
		possible_targets -= owner
	else
		damage_dealt *= pressure_modifier
		owner.apply_status_effect(/datum/status_effect/brimdust_concussion)

	for(var/mob/living/target in possible_targets)
		var/armor = target.run_armor_check(attack_flag = BOMB)
		target.apply_damage(damage_dealt, damagetype = BURN, blocked = armor, spread_damage = TRUE)

	add_stacks(-1)

/// Slowdown applied when you are detonated on the space station
/datum/status_effect/brimdust_concussion
	id = "brimdust_concussion"
	duration = 4 SECONDS
	alert_type = null // Short lived enough not to matter

/datum/status_effect/brimdust_concussion/on_apply()
	. = ..()
	owner.add_movespeed_modifier(/datum/movespeed_modifier/status_effect/brimdust_concussion)
	to_chat(owner, span_warning("You are knocked off balance by the explosion!"))

/datum/status_effect/brimdust_concussion/on_remove()
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/status_effect/brimdust_concussion)
	to_chat(owner, span_notice("You find your balance."))

/// Action used by the brimdust sac
/datum/action/cooldown/monster_core_action/exhale_brimdust
	name = "Exhale Brimdust"
	desc = "Cough out a choking cloud of explosive brimdust to coat those nearby."
	button_icon_state = "brim_sac_stable"
	cooldown_time = 90 SECONDS

#undef BRIMDUST_LIFE_APPLY_COOLDOWN
#undef BRIMDUST_STACKS_ON_LIFE
#undef BRIMDUST_STACKS_ON_USE
