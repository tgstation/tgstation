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

	/// A pool of blocking overlay effects, to save on re-creating effects.
	var/static/list/obj/effect/blocking_effect/pooled_overlays = list()

	/// What we're blocking with currently
	var/obj/item/blocking_with
	/// A ref to our active shile doverlay
	var/obj/effect/blocking_effect/shield_overlay

/datum/status_effect/blocking/nextmove_modifier()
	// Next move CD is 2x as long while blocking.
	// You are unable to attack while blocking but this handles stuff like
	// interfacing with your backpack or other actions.
	return 2

/datum/status_effect/blocking/proc/provide_blocking_effect()
	var/obj/effect/blocking_effect/shield
	for(var/obj/effect/blocking_effect/stored_shield as anything in pooled_overlays)
		if(ismob(shield.loc))
			continue
		shield = stored_shield
		break

	if(isnull(shield))
		shield = new(owner)
		var/static/shield_offset_const = (0.8 * world.icon_size)
		shield.pixel_y += shield_offset_const
		pooled_overlays += shield
	else
		shield.forceMove(owner)

	shield.color = owner.chat_color || LIGHT_COLOR_BLUE
	shield.alpha = min(owner.alpha, 200)
	shield.layer = owner.layer + 0.1 // melbert todo: hides under mobs 1 tile up (not z wise)
	owner.vis_contents += shield_overlay
	return shield

/datum/status_effect/blocking/proc/hide_blocking_effect()
	owner.vis_contents -= shield_overlay
	shield_overlay.moveToNullspace()
	shield_overlay = null

/datum/status_effect/blocking/on_creation(mob/living/new_owner, obj/item/new_blocker)
	. = ..()
	if(!.)
		return
	if(!isnull(new_blocker))
		set_blocking_item(new_blocker)

	shield_overlay = provide_blocking_effect()
	update_shield()

/datum/status_effect/blocking/on_apply()
	hide_blocking_effect()
	RegisterSignal(owner, COMSIG_LIVING_CHECK_BLOCK, PROC_REF(on_attacked))
	RegisterSignals(owner, list(COMSIG_MOB_APPLY_DAMAGE, COMSIG_LIVING_HEALTH_UPDATE), PROC_REF(on_health_update))
	owner.add_movespeed_modifier(/datum/movespeed_modifier/blocking)
	owner.add_actionspeed_modifier(/datum/actionspeed_modifier/blocking)
	ADD_TRAIT(owner, TRAIT_CANNOT_HEAL_STAMINA, id)
	return TRUE

/datum/status_effect/blocking/refresh(effect, obj/item/new_blocker)
	if(isnull(new_blocker))
		if(!isnull(blocking_with))
			clear_blocking_item()
	else
		set_blocking_item(new_blocker)

/datum/status_effect/blocking/on_remove()
	QDEL_NULL(shield_overlay)
	UnregisterSignal(owner, list(
		COMSIG_LIVING_CHECK_BLOCK,
		COMSIG_LIVING_HEALTH_UPDATE,
		COMSIG_MOB_APPLY_DAMAGE,
	))
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/blocking)
	owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/blocking)
	REMOVE_TRAIT(owner, TRAIT_CANNOT_HEAL_STAMINA, id)

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
		carbon_owner.stam_regen_start_time = max(carbon_owner.stam_regen_start_time, tick_interval)

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
		shield_overlay.icon_state = "shield[percent]"

/datum/status_effect/blocking/proc/set_blocking_item(obj/item/new_blocker)
	blocking_with = new_blocker
	RegisterSignals(blocking_with, list(COMSIG_QDELETING, COMSIG_ITEM_DROPPED, COMSIG_ITEM_EQUIPPED), PROC_REF(stop_blocking))
	linked_alert.update_appearance(UPDATE_DESC)

/datum/status_effect/blocking/proc/clear_blocking_item()
	UnregisterSignal(blocking_with, list(
		COMSIG_QDELETING,
		COMSIG_ITEM_DROPPED,
		COMSIG_ITEM_EQUIPPED,
	))

	blocking_with = null
	if(!QDELETED(linked_alert))
		linked_alert.update_appearance(UPDATE_DESC)

/datum/status_effect/blocking/proc/stop_blocking(obj/item/source)
	SIGNAL_HANDLER

	qdel(src)

/datum/status_effect/blocking/proc/on_attacked(mob/living/source, atom/movable/hitby, damage, attack_text, attack_type, armour_penetration, damage_type)
	SIGNAL_HANDLER

	if(blocking_with)
		if(!(blocking_with.can_block_flags & attack_type))
			return NONE

	else if(!(BLOCK_ALL_MELEE & attack_type))
		return NONE

	// Depending on the item (or lack thereof) you are blocking with, the damage taken is converted to more (or maybe less!) stamina damage
	var/defense_multiplier = blocking_with ? blocking_with.get_blocking_ability(source, hitby, damage, attack_type, damage_type) : BARE_HAND_DEFENSE_MULTIPLIER
	if(defense_multiplier < 0)
		return NONE
	if(damage_type == STAMINA)
		// This is kinda a "anti-noobtrap" measure.
		// If you are hit with an attack that does pure stamina damage (no side effects), like disabler fire,
		// blocking it would serve you no gain and instead harm you by *increasing* the stamina damage you take.
		// So instead of just disallowing users from blocking stamina attacks, we'll just cap it at 1x.
		defense_multiplier = min(defense_multiplier, 1)

	var/final_damage = defense_multiplier * damage
	var/mob/living/attacker = GET_ASSAILANT(hitby)
	if(istype(attacker) && HAS_TRAIT(attacker, TRAIT_HULK))
		final_damage *= 1.25 // Hulk attacks are harder to stop
	if(source.body_position == LYING_DOWN)
		final_damage *= 1.25 // Harder to block while lying down
	if(final_damage > 0)
		// If you fail to take the damage, no block allowed
		if(!source.apply_damage(final_damage, STAMINA, spread_damage = TRUE))
			return NONE

	// Stamcrit = failed
	if(HAS_TRAIT(source, TRAIT_INCAPACITATED))
		return NONE

	// Stops all following effects of the attack.
	if(isnull(blocking_with) || !blocking_with.on_successful_block(source, hitby, damage, attack_text, attack_type, damage_type))
		source.visible_message(
			span_danger("[source] blocks [attack_text][blocking_with ? " with [blocking_with]" : ""]!"),
			span_danger("You block [attack_text][blocking_with ? " with [blocking_with]" : ""]!"),
		)
	if(final_damage > 0)
		source.add_movespeed_modifier(/datum/movespeed_modifier/successful_block)
		addtimer(CALLBACK(source, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/successful_block), 0.5 SECONDS)
	if(istype(attacker))
		attacker.add_movespeed_modifier(/datum/movespeed_modifier/successful_block)
		addtimer(CALLBACK(attacker, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/successful_block), 0.8 SECONDS)
		attacker.apply_damage(5, STAMINA, spread_damage = TRUE)

	if(!QDELETED(src))
		animate(shield_overlay, time = 0.15 SECONDS, pixel_x = 2, easing = BACK_EASING|EASE_OUT)
		animate(time = 0.20 SECONDS, pixel_x = -2, easing = BACK_EASING|EASE_OUT)
		animate(time = 0.15 SECONDS, pixel_x = 0, easing = BACK_EASING|EASE_OUT)

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
	var/effectiveness = blocking_effect.blocking_with?.blocking_ability || BARE_HAND_DEFENSE_MULTIPLIER
	var/effectiveness_verb = ""
	switch(effectiveness)
		if(-1)
			effectiveness_verb = "can't block a thing!"
		if(0)
			effectiveness_verb = "can bare any attack!"
		if(0 to 1)
			effectiveness_verb = "can block very well!"
		if(1 to 1.5)
			effectiveness_verb = "can block moderately well."
		if(1.5 to 2)
			effectiveness_verb = "can block decently."
		if(2 to 3)
			effectiveness_verb = "is not very good at blocking..."
		if(3 to INFINITY)
			effectiveness_verb = "is terrible at blocking!"
		else
			effectiveness_verb = "is blocking with an unknown effectiveness, perhaps report this as a bug?"

	desc += "\n\nYou are blocking with [blocking_effect.blocking_with || "your bare hands"], which [effectiveness_verb]"

/obj/effect/blocking_effect
	icon = 'icons/effects/blocking.dmi'
	icon_state = "shield100"
	anchored = TRUE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/blocking_effect/Initialize(mapload)
	. = ..()
	color = loc.chat_color || LIGHT_COLOR_BLUE
	alpha = min(loc.alpha, 200)
	layer = loc.layer + 0.1

/datum/movespeed_modifier/blocking
	multiplicative_slowdown = 0.5

/datum/movespeed_modifier/successful_block
	multiplicative_slowdown = 0.25

/datum/actionspeed_modifier/blocking
	multiplicative_slowdown = 1
