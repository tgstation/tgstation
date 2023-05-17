GLOBAL_LIST_INIT(attack_styles, init_attack_styles())

/proc/init_attack_styles()
	var/list/styles = list()
	for(var/style_type in typesof(/datum/attack_style))
		styles[style_type] = new style_type()

	return styles

/datum/movespeed_modifier/attack_style_executed
	variable = TRUE

/**
 * # Attack style singleton
 *
 * Handles sticking behavior onto a weapon to make it attack a certain way
 */
/datum/attack_style
	/// Hitsound played on a successful attack hit
	/// If null, uses item hitsound.
	var/successful_hit_sound

	var/hit_volume = 50
	/// Hitsound played on if the attack fails to hit anyone
	var/miss_sound = 'sound/weapons/fwoosh.ogg'

	var/miss_volume = 50
	/// Click CD imparted by successful attacks
	/// Failed attacks still apply a click CD, but reduced
	var/cd = CLICK_CD_MELEE
	/// Movement slowdown applied on a successful attack
	var/slowdown = 1
	/// If TRUE, the list of affected turfs will be reversed if the attack is being sourced from the lefthand
	/// Used primarily for attacks like swings, where instead of travelling right to left they would instead go left to right
	var/reverse_for_lefthand = TRUE
	/// The number of mobs that can be hit per hit turf
	var/hits_per_turf_allowed = 1
	/// If TRUE, pacifists are completely disallowed from using this attack style
	/// If FALSE, pacifism is still checked, but it checks weapon force instead - any weapon with force > 0 will be disallowed
	var/pacifism_completely_banned = FALSE

/**
 * Process attack -> execute attack -> finalize attack
 *
 * Arguments
 * * attacker - the mob doing the attack
 * * weapon - optional, the item being attacked with.
 * * aimed_towards - what atom the attack is being aimed at, does not necessarily correspond to the atom being attacked,
 * but is also checked as a priority target if multiple mobs are on the same turf.
 * * right_clicking - whether the attack was done via r-click
 *
 * Implementation notes
 * * Do not override process attack
 * * You may extend execute attack with additonal checks, but call parent
 * * You can freely override finalize attack with whatever behavior you want
 *
 * Usage notes
 * * Does NOT check for nextmove, that should be checked before entering this
 * * DOES check for pacifism
 *
 * Return TRUE on success, and FALSE on failure
 */
/datum/attack_style/proc/process_attack(mob/living/attacker, obj/item/weapon, atom/aimed_towards, right_clicking = FALSE)
	SHOULD_NOT_OVERRIDE(TRUE)
	SHOULD_NOT_SLEEP(TRUE)

	weapon?.add_fingerprint(attacker)
	if(HAS_TRAIT(attacker, TRAIT_PACIFISM) && (pacifism_completely_banned || weapon?.force > 0))
		attacker.balloon_alert(attacker, "you don't want to attack!")
		return FALSE

	if(IS_BLOCKING(attacker))
		attacker.balloon_alert(attacker, "can't act while blocking!")
		return FALSE

	var/attack_direction = get_dir(attacker, get_turf(aimed_towards))
	var/list/affecting = select_targeted_turfs(attacker, attack_direction, right_clicking)
	if(reverse_for_lefthand)
		// Determine which hand the attacker is attacking from
		// If they are not holding the weapon passed / the weapon is null, default to active hand
		var/which_hand = (!isnull(weapon) && attacker.get_held_index_of_item(weapon)) || attacker.active_hand_index

		// Left hand will reverse the turfs list order
		if(which_hand % 2 == 1)
			reverse_range(affecting)

	// Prioritise the atom we clicked on initially, so if two mobs are on one turf, we hit the one we clicked on
	if(execute_attack(attacker, weapon, affecting, aimed_towards, right_clicking) & ATTACK_STYLE_CANCEL)
		// Just apply a small second CD so they don't spam failed attacks
		attacker.changeNext_move(0.33 SECONDS)
		return FALSE

	if(slowdown > 0)
		attacker.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/attack_style_executed, multiplicative_slowdown = slowdown)
		addtimer(CALLBACK(attacker, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/attack_style_executed), cd * 0.2)
	if(cd > 0)
		attacker.changeNext_move(cd)
	return TRUE

/datum/attack_style/proc/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	SHOULD_CALL_PARENT(TRUE)

	attack_effect_animation(attacker, weapon, affecting)

	var/attack_flag = NONE
	var/total_total_hit = 0
	for(var/turf/hitting as anything in affecting)
		// Unfortunately this makes mobs in dense or blocks turfs invincible. Fix that
		var/atom/blocking_us = hitting.is_blocked_turf(TRUE, attacker)
		if(blocking_us)
			attacker.visible_message(
				span_warning("[attacker]'s swing collides with [blocking_us]!"),
				span_warning("[blocking_us] blocks your swing partway!"),
			)
			playsound(hitting, 'sound/effects/glasshit.ogg', 90, TRUE)
			return attack_flag || ATTACK_STYLE_CANCEL // Purposeful use of || and not |, only sends CANCEL if no flags are set

#ifdef TESTING
		apply_testing_color(hitting, affecting.Find(hitting))
#endif

		var/list/mob/living/foes = list()
		for(var/mob/living/foes_in_turf in hitting)
			foes += foes_in_turf

		shuffle_inplace(foes)
		if(priority_target in foes)
			foes.Remove(priority_target)
			foes.Insert(1, priority_target) // to the front
		if(attacker in foes)
			foes.Remove(attacker)
			foes.Add(attacker) // to the end

		var/total_hit = 0
		for(var/mob/living/smack_who as anything in foes)
			var/new_results = finalize_attack(attacker, smack_who, weapon, right_clicking)
			if(!(new_results & ATTACK_STYLE_HIT))
				continue
			attack_flag |= new_results
			total_hit++
			total_total_hit++
			if(total_hit >= hits_per_turf_allowed)
				break

		if(attack_flag & ATTACK_STYLE_CANCEL)
			return ATTACK_STYLE_CANCEL
		if(attack_flag & ATTACK_STYLE_BLOCKED)
			break

	if(total_total_hit <= 0)
		// counts as a miss if we don't hit anyone, duh
		attack_flag |= ATTACK_STYLE_MISSED

	if(attack_flag & ATTACK_STYLE_HIT)
		var/hitsound_to_use = get_hit_sound(weapon)
		if(hitsound_to_use)
			playsound(attacker, hitsound_to_use, hit_volume, TRUE)

	else if(attack_flag & ATTACK_STYLE_MISSED)
		if(miss_sound)
			playsound(attacker, miss_sound, miss_volume, TRUE)

	return attack_flag

/datum/attack_style/proc/get_hit_sound(obj/item/weapon)
	return successful_hit_sound || weapon?.hitsound

/datum/attack_style/proc/select_targeted_turfs(mob/living/attacker, attack_direction, right_clicking)
	RETURN_TYPE(/list)
	return list(get_step(attacker, attack_direction))

/datum/attack_style/proc/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	if(isnull(weapon))
		return

	var/turf/midpoint = affecting[ROUND_UP(length(affecting) / 2)]

	attacker.do_attack_animation(midpoint, used_item = weapon)
	/*
	var/num_turfs_to_move = length(affecting)
	var/time_per_turf = 0.4 SECONDS
	var/final_animation_length = time_per_turf * num_turfs_to_move
	var/initial_angle = get_angle(attacker, affecting[1])
	var/final_angle = get_angle(attacker, affecting[num_turfs_to_move])

	var/image/attack_image = image(icon = weapon, loc = attacker, layer = attacker.layer + 0.1)
	var/matrix/base_transform = matrix(attack_image.transform)
	attack_image.alpha = 180
	attack_image.color = "#c4c4c4"
	attack_image.transform.Turn(initial_angle)
	var/matrix/final_transform = base_transform.Turn(final_angle)

	flick_overlay_global(attack_image, GLOB.clients, final_animation_length + time_per_turf)
	animate(attack_image, time = final_animation_length, alpha = 120, transform = final_transform)
	// animate(attack_image, time = time_per_turf, alpha = 0, easing = CIRCULAR_EASING|EASE_OUT)
	*/

/**
 * Finalize an attack on a single mob in one of the affected turfs
 *
 * Similar to melee attack chain, but with some guff cut out.
 *
 * You should call parent with this unless you know what you're doing and implementing your own attack business.
 */
/datum/attack_style/proc/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	SHOULD_CALL_PARENT(TRUE)

	. = NONE

	var/go_to_attack = !right_clicking
	if(right_clicking)
		switch(weapon.pre_attack_secondary(smacked, attacker))
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return ATTACK_STYLE_CANCEL
			if(SECONDARY_ATTACK_CALL_NORMAL)
				pass()
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				go_to_attack = TRUE
			else
				CRASH("pre_attack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")

	if(go_to_attack && weapon.pre_attack(smacked, attacker))
		return . | ATTACK_STYLE_CANCEL

	var/go_to_afterattack = !right_clicking
	if(right_clicking)
		switch(weapon.attack_secondary(smacked, attacker))
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return ATTACK_STYLE_CANCEL
			if(SECONDARY_ATTACK_CALL_NORMAL)
				pass()
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				go_to_afterattack = TRUE
			else
				CRASH("attack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")

	if(go_to_afterattack && weapon.attack_wrapper(smacked, attacker))
		return . | ATTACK_STYLE_CANCEL

	// Hitsound happens here

	smacked.lastattacker = attacker.real_name
	smacked.lastattackerckey = attacker.ckey

	if(attacker == smacked && attacker.client)
		attacker.client.give_award(/datum/award/achievement/misc/selfouch, attacker)

	// !! ACTUAL DAMAGE GETS APPLIED HERE !!
	. |= smacked.attacked_by(weapon, attacker)
	log_combat(attacker, smacked, "attacked", weapon.name, "(STYLE: [type]) (DAMTYPE: [uppertext(weapon.damtype)])")

	// Attack animation

	if(. & (ATTACK_STYLE_BLOCKED|ATTACK_STYLE_CANCEL|ATTACK_STYLE_SKIPPED))
		return .

	if(right_clicking)
		switch(weapon.afterattack_secondary(smacked, attacker, /* proximity_flag = */TRUE))
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return . | ATTACK_STYLE_CANCEL
			if(SECONDARY_ATTACK_CALL_NORMAL)
				pass()
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				return .
			else
				CRASH("afterattack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")

	// Don't really care about the return value of after attack.
	weapon.afterattack(smacked, attacker, /* proximity_flag = */TRUE)
	return .

#ifdef TESTING
/datum/attack_style/proc/apply_testing_color(turf/hit, index = -1)
	hit.add_atom_colour(COLOR_RED, TEMPORARY_COLOUR_PRIORITY)
	hit.maptext = MAPTEXT("[index]")
	animate(hit, 1 SECONDS, color = null)
	addtimer(CALLBACK(src, PROC_REF(clear_testing_color), hit), 1 SECONDS)
#endif

#ifdef TESTING
/datum/attack_style/proc/clear_testing_color(turf/hit)
	hit.remove_atom_colour(TEMPORARY_COLOUR_PRIORITY, COLOR_RED)
	hit.maptext = null
#endif

/**
 * Unarmed attack styles work slightly differently
 *
 * For normal attack styles, the style should not be handling the damage whatsoever, it should be handled by the weapon.
 *
 * But since we have no weapon for these, we kinda hvae to do it ourselves.
 */
/datum/attack_style/unarmed
	reverse_for_lefthand = FALSE
	successful_hit_sound = 'sound/weapons/punch1.ogg'
	miss_sound = 'sound/weapons/punchmiss.ogg'

	/// Used for playing a little animation over the turf
	var/attack_effect = ATTACK_EFFECT_PUNCH

/datum/attack_style/unarmed/execute_attack(mob/living/attacker, obj/item/bodypart/weapon, list/turf/affecting, atom/priority_target, right_clicking)
	ASSERT(isnull(weapon) || istype(weapon, /obj/item/bodypart))
	return ..()

/datum/attack_style/unarmed/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("No narmed interaction for [type]!")

/datum/attack_style/unarmed/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affecting)
	if(attack_effect)
		attacker.do_attack_animation(affecting[1], attack_effect)

// Overhead swings, bypass blocks / targets heads
/datum/attack_style/overhead
