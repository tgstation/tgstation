GLOBAL_LIST_INIT(attack_styles, init_attack_styles())

/proc/init_attack_styles()
	var/list/styles = list()
	for(var/style_type in subtypesof(/datum/attack_style))
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
	/// Volume of hitsound
	var/hit_volume = 50
	/// Hitsound played on if the attack fails to hit anyone
	var/miss_sound = 'sound/weapons/fwoosh.ogg'
	/// Volume of miss sound
	var/miss_volume = 50
	/// Click CD imparted by successful attacks
	/// Failed attacks still apply a click CD, but reduced
	var/cd = CLICK_CD_MELEE
	/// Movement slowdown applied on an attack
	var/slowdown = 1
	/// The max total mob size that can be hit in a single turf.
	/// If multiple humans are stacked on the same turf, it'll only hit one (by default),
	/// but if there's multiple bees or other small mobs, you could hit multiple.
	var/total_mob_size_hit_allowed = MOB_SIZE_HUMAN
	/// How long does it take for the attack to travel between turfs?
	/// Essentually, this is "swing speed". Does nothing for attacks which only hit a single turf.
	var/time_per_turf = 0 SECONDS
	/// Whether the swing can hit the swing-er itself
	var/can_hit_self = FALSE

#ifndef TESTING
/datum/attack_style/vv_edit_var(var_name, var_value)
	// do not allow editing the global singletons
	// admins can still create custom styles via VV dropdown
	if(GLOB.attack_styles[type] == src)
		return FALSE
	return ..()
#endif

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

	weapon?.add_fingerprint(attacker)

	if(!can_attack(attacker, weapon, right_clicking))
		attacker.changeNext_move(0.25 SECONDS)
		return FALSE

	var/attack_direction = NONE
	if(get_turf(attacker) != get_turf(aimed_towards))
		// This gives a little bit of leeway for angling attacks.
		// If we straight up use dir, then the window for doing a NSEW attack
		// is far smaller than the window for NE/SE/SW/NW attacks.
		attack_direction = angle2dir(get_angle(attacker, aimed_towards))

	var/list/turf/affected_turfs = select_targeted_turfs(attacker, weapon, attack_direction, right_clicking)

	// Make sure they can't attack while swinging if our swing sleeps
	if(time_per_turf > 0 SECONDS)
		attacker.changeNext_move(cd + (time_per_turf * (length(affected_turfs) - 1)))

	// Last chance for components to interrupt before we execute the attack
	if (SEND_SIGNAL(attacker, COMSIG_LIVING_ATTACK_STYLE_PREPROCESS, src, weapon, affected_turfs) & CANCEL_ATTACK_PREPROCESS)
		return ATTACK_SWING_CANCEL

	// Make sure they don't rotate while swinging on the move
	var/pre_set_dir = attacker.set_dir_on_move
	attacker.set_dir_on_move = FALSE
	var/attack_result = execute_attack(attacker, weapon, affected_turfs, priority_target = aimed_towards, right_clicking = right_clicking)
	attacker.set_dir_on_move = pre_set_dir

	var/successful_attack = !(attack_result & ATTACK_SWING_CANCEL)
	if(successful_attack)
		if(slowdown > 0)
			var/slowdown_mult = (attack_result & ATTACK_SWING_MISSED) ? 0.66 : 1
			attacker.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/attack_style_executed, multiplicative_slowdown = slowdown * slowdown_mult)
			addtimer(CALLBACK(attacker, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/attack_style_executed), cd * 0.2)
		if(cd > 0)
			var/cd_mult = (attack_result & ATTACK_SWING_MISSED) ? 0.66 : 1
			attacker.changeNext_move(attacker.get_swing_nextmove(cd, cd_mult))

	SEND_SIGNAL(attacker, COMSIG_LIVING_ATTACK_STYLE_PROCESSED, weapon, attack_result, src)
	if(!isnull(weapon)) // wepaon can be null (mob attack). it can also be a bodypart if an unarmed attack.
		SEND_SIGNAL(weapon, COMSIG_ITEM_ATTACK_STYLE_PROCESESD, attacker, attack_result, src)
	return attack_result

/// Check if the attacker can execute this attack style
/datum/attack_style/proc/can_attack(mob/living/attacker, obj/item/weapon, right_clicking)
	SHOULD_CALL_PARENT(TRUE)

	if(HAS_TRAIT(attacker, TRAIT_PACIFISM) && check_pacifism(attacker, weapon, right_clicking))
		attacker.balloon_alert(attacker, "you don't want to attack!")
		return FALSE

	if(IS_BLOCKING(attacker))
		attacker.balloon_alert(attacker, "can't act while blocking!")
		return FALSE

	var/sigreturn = NONE
	if(!isnull(weapon))
		sigreturn |= SEND_SIGNAL(weapon, COMSIG_ITEM_ATTACK_STYLE_CHECK, attacker)

	if(sigreturn & ATTACK_SWING_CANCEL)
		return FALSE

	return TRUE

/datum/attack_style/proc/execute_attack(
	mob/living/attacker,
	obj/item/weapon,
	list/turf/affected_turfs,
	atom/priority_target,
	right_clicking,
)
	SHOULD_CALL_PARENT(TRUE)
	PROTECTED_PROC(TRUE)

	attack_effect_animation(attacker, weapon, affected_turfs)

	var/attack_result = NONE

	// The index of the turf we're currently hitting
	var/affecting_index = 1
	// This tracks if this attack was initiated with a weapon,
	// so we can check if it's still being held for swings that have travel time
	// This will break for unarmed attacks that are multi-tile. Future problem
	var/started_holding = !isnull(weapon) && attacker.is_holding(weapon)
	// This tracks the loc the swing started at,
	// so we can re-generate the affecting turfs list for swings that have travel time if the attacker moves
	var/turf/starting_loc = attacker.loc
	// A list of mobs that have already been hit by this attack to prevent double dipping
	var/list/mob/living/already_hit = list()
	if(!can_hit_self)
		already_hit[attacker] = TRUE
	// The dir the attacker was facing when the attack started,
	// so changing dir mid swing for attacks with travel time don't change the direction of the attack
	var/starting_dir = attacker.dir

	// Main attack loop starts here.
	while(affecting_index <= length(affected_turfs))
		var/turf/hitting = affected_turfs[affecting_index]
		// Check for continguous reach between the current and the starting location OR the last hit turf
		if(!hitting.Adjacent(starting_loc) && (affecting_index == 1 || !hitting.Adjacent(affected_turfs[affecting_index - 1])))
			break
		// melbert todo : STILL need to figure out border objects

#ifdef TESTING
		apply_testing_color(hitting, affecting_index)
#endif

		affecting_index += 1
		// melbert todo : border objects SUCK, needs to be addressed
		attack_result |= swing_enters_turf(attacker, weapon, hitting, already_hit, priority_target, right_clicking)
		if(attack_result & ATTACK_SWING_CANCEL)
			// Cancel attacks stop outright
			return attack_result

		if(!isnull(weapon))
			attack_result |= SEND_SIGNAL(weapon, COMSIG_ITEM_SWING_ENTERS_TURF, attack_result, attacker, hitting, affected_turfs, already_hit, priority_target, right_clicking)
		if(attack_result & ATTACK_SWING_BLOCKED)
			// Blocked attacks do not continue to the next turf
			break

		// Travel time.
		if(time_per_turf > 0 && length(affected_turfs) <= affecting_index)
			sleep(time_per_turf) // probably shouldn't use stoplag? May result in undesired behavior during high load

			// Sanity checking. We don't need to care about the other flags set if these fail.
			if(QDELETED(attacker) || attacker.incapacitated())
				return ATTACK_SWING_CANCEL
			if(started_holding && (QDELETED(weapon) || !attacker.is_holding(weapon)))
				return ATTACK_SWING_CANCEL
			if(attacker.loc != starting_loc)
				if(!isturf(attacker.loc))
					return ATTACK_SWING_CANCEL

				// At this point we've moved a turf but can continue attacking, so we'll
				// soft restart the swing from this point at the new turf.
				starting_loc = attacker.loc
				affected_turfs = select_targeted_turfs(attacker, weapon, starting_dir, right_clicking)

	if(!(attack_result & (ATTACK_SWING_BLOCKED|ATTACK_SWING_HIT)))
		// counts as a miss by default if we don't hit anyone
		attack_result |= ATTACK_SWING_MISSED

	if(attack_result & ATTACK_SWING_MISSED)
		playsound(attacker, miss_sound, hit_volume, TRUE)

	return attack_result

/// Called when the swing enters a turf.
/datum/attack_style/proc/swing_enters_turf(
	mob/living/attacker,
	obj/item/weapon,
	turf/hitting,
	list/mob/living/already_hit,
	atom/priority_target,
	right_clicking,
)
	SHOULD_CALL_PARENT(TRUE)
	var/attack_result = NONE
	// Gathers up all mobs in the turf being struck. Each mob will have a priority assigned.
	// Intuitively an attacker will not want to attack certain mobs, such as their friends, or unconscious people over conscious people.
	// While this doesn't completley mitigate the chance of friendly fire, it does make it less likely.
	var/list/mob/living/foes = list()
	for(var/mob/living/foe_in_turf in hitting)
		if(already_hit[foe_in_turf])
			continue

		var/foe_prio = rand(4, 8) // assign a random priority so it's non-deterministic
		if(foe_in_turf == priority_target)
			foe_prio = 10
		else if(foe_in_turf == attacker)
			foe_prio = -10
		else if(foe_in_turf.stat != CONSCIOUS)
			foe_prio = 2 // very de-prio folk who can't fight back

		if(length(foe_in_turf.faction & attacker.faction))
			foe_prio -= 2 // de-prio same factions

		foes[foe_in_turf] = foe_prio

	// Sorts by priority
	sortTim(foes, cmp = /proc/cmp_numeric_dsc, associative = TRUE)

	var/total_hit = 0
	// Here is where we go into finalize attack, to actually cause damage.
	// This is where attack swings enter attack chain.
	for(var/mob/living/smack_who as anything in foes)
		already_hit[smack_who] = TRUE
		attack_result |= finalize_attack(attacker, smack_who, weapon, right_clicking)
		if(attack_result & ATTACK_SWING_CANCEL)
			return attack_result
		if(attack_result & (ATTACK_SWING_MISSED|ATTACK_SWING_SKIPPED))
			continue
		if(attack_result & (ATTACK_SWING_BLOCKED|ATTACK_SWING_HIT))
			total_hit += max(smack_who.mob_size, 0.25)
		if(total_hit >= total_mob_size_hit_allowed)
			break

	// Right after dealing damage we handle getting blocked by dense stuff
	// If there's something dense in the turf the rest of the swing is cancelled
	// This means wide arc swinging weapons can't hit in tight corridors
	var/atom/blocking_us = hitting.is_blocked_turf(exclude_mobs = TRUE, source_atom = weapon, check_obscured = TRUE)
	if(blocking_us)
		attack_result |= collide_with_solid_atom(blocking_us, weapon, attacker)

	if(attack_result & (ATTACK_SWING_BLOCKED|ATTACK_SWING_HIT)) // melbert todo check this
		playsound(attacker, get_hit_sound(weapon, attack_result), hit_volume, TRUE)

	return attack_result

/**
 * Gets the soound to play when the attack successfully hits another mob
 *
 * * weapon - The weapon being used, can be null or a non-held item depending on the attack style
 */
/datum/attack_style/proc/get_hit_sound(obj/item/weapon, attack_result)
	return successful_hit_sound || weapon?.hitsound

/**
 * Used to determine what turfs this attack is going to hit when executed.
 *
 * All turfs supplied are expected to be continguously adjacent.
 * If any are not, the swing will stop at the last-most contiguous turf.
 *
 * * attacker - The mob doing the attacking
 * * attack_direction - The direction the attack is coming from
 * * right_clicking - Whether the attack was initiated via right click
 *
 * Return a list of turfs with nulls filtered out
 */
/datum/attack_style/proc/select_targeted_turfs(mob/living/attacker, obj/item/weapon, attack_direction, right_clicking)
	RETURN_TYPE(/list)
	return list(get_step(attacker, attack_direction))

/**
 * Called when the attacker has the pacifism trait.
 *
 * * attacker - The mob doing the attacking
 * * weapon - The weapon being used, can be null or a non-held item depending on the attack style
 *
 * Return TRUE to stop the attack
 * Return FALSE to allow the attack
 */
/datum/attack_style/proc/check_pacifism(mob/living/attacker, obj/item/weapon, right_clicking)
	return FALSE

/**
 * Plays an animation for the attack.
 *
 * * attacker - The mob doing the attacking
 * * weapon - The weapon being used, can be null or a non-held item depending on the attack style
 * * affecting - The list of turfs being affected by the attack
 */
/datum/attack_style/proc/attack_effect_animation(mob/living/attacker, obj/item/weapon, list/turf/affected_turfs)
	attacker.do_attack_animation(get_movable_to_layer_effect_over(affected_turfs))

/// Can be used in [proc/attack_effect_animation] to select some atom
/// in the list of affecting turfs to play the attack animation over
/datum/attack_style/proc/get_movable_to_layer_effect_over(list/turf/affected_turfs)
	var/turf/midpoint = affected_turfs[ROUND_UP(length(affected_turfs) / 2)]
	var/atom/movable/current_pick = midpoint
	for(var/atom/movable/thing as anything in midpoint)
		if(isProbablyWallMounted(thing))
			continue
		if(thing.invisibility > 0 || thing.alpha < 50) // skipping lightly transparent things.
			continue
		if(thing.layer > current_pick.layer)
			current_pick = thing

	return current_pick

/// Determines behavior when we collide with a solid / dense atom mid swing.
/datum/attack_style/proc/collide_with_solid_atom(atom/blocking_us, obj/item/weapon, mob/living/attacker)
	return NONE
/*
	if(!blocking_us.uses_integrity)
		// This is stuff like walls - essentially does this swing get stopped by hitting a wall?
		return NONE

	attacker.visible_message(
		span_warning("[attacker]'s attack collides with [blocking_us]!"),
		span_warning("[blocking_us] blocks your attack!"),
	)
	blocking_us.attacked_by(weapon, attacker)
	return ATTACK_SWING_BLOCKED
*/

/**
 * Finalize an attack on a single mob in one of the affected turfs
 *
 * * attacker - The mob doing the attacking
 * * smacked - The mob being attacked
 * * weapon - The weapon being used, can be null or a non-held item depending on the attack style
 * * right_clicking - Whether the attack was initiated via right click
 */
/datum/attack_style/proc/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	PROTECTED_PROC(TRUE)
	return

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

/datum/attack_style/melee_weapon
	/// Params passed onto attack chain when left clicking
	VAR_FINAL/left_click_params
	/// Params passed onto attack chain when right clicking
	VAR_FINAL/right_click_params

	/// The attack effect is scaled by this amount
	var/sprite_size_multiplier = 1

/datum/attack_style/melee_weapon/New()
	. = ..()
	left_click_params = list2params(list(LEFT_CLICK = TRUE, BUTTON = LEFT_CLICK))
	right_click_params = list2params(list(RIGHT_CLICK = TRUE, BUTTON = RIGHT_CLICK))

/datum/attack_style/melee_weapon/check_pacifism(mob/living/attacker, obj/item/weapon, right_clicking)
	return weapon.force > 0 && weapon.damtype != STAMINA

/datum/attack_style/melee_weapon/proc/get_swing_description(has_alt_style)
	return "Swings at one tile in the direction you are attacking."

/datum/attack_style/melee_weapon/execute_attack(mob/living/attacker, obj/item/weapon, list/turf/affected_turfs, atom/priority_target, right_clicking)
	ASSERT(istype(weapon))
	var/params_to_use = right_clicking ? right_click_params : left_click_params

	var/turf/midpoint = affected_turfs[ROUND_UP(length(affected_turfs) / 2)]
	var/call_pre_attack = !right_clicking
	if(right_clicking)
		switch(weapon.pre_attack_secondary(midpoint, attacker, params_to_use))
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return ATTACK_SWING_CANCEL // Stops entire swing
			if(SECONDARY_ATTACK_CALL_NORMAL)
				call_pre_attack = TRUE // call normal preattack
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				// pass() // go to attack
			else
				CRASH("pre_attack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")

	if(call_pre_attack && weapon.pre_attack(midpoint, attacker, params_to_use))
		return ATTACK_SWING_CANCEL

	return ..()

/datum/attack_style/melee_weapon/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	// Blocking is checked here. Does NOT calculate final damage when passing to check block (IE, ignores armor / physiology)
	if(smacked.check_block(weapon, weapon.force, "the [weapon.name]", MELEE_ATTACK, weapon.armour_penetration, weapon.damtype, MELEE))
		return ATTACK_SWING_BLOCKED

	var/attack_result = NONE
	var/params_to_use = right_clicking ? right_click_params : left_click_params
	var/call_attack = !right_clicking
	if(right_clicking)
		switch(weapon.attack_secondary(smacked, attacker, params_to_use))
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return ATTACK_SWING_CANCEL // Stops entire swing
			if(SECONDARY_ATTACK_CALL_NORMAL)
				call_attack = TRUE // call normal attack
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				// pass() // go to afterattack
			else
				CRASH("attack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")

	if(call_attack)
		attack_result |= weapon.attack_wrapper(smacked, attacker, params_to_use)
		if(attack_result & ATTACK_SWING_CANCEL)
			return attack_result

	if(!(attack_result & ATTACK_SWING_SKIPPED))
		UPDATE_LAST_ATTACKER(smacked, attacker)

		if(attacker == smacked && attacker.client)
			attacker.client.give_award(/datum/award/achievement/misc/selfouch, attacker)

		log_combat(attacker, smacked, "attacked", weapon.name, "(STYLE: [type]) (DAMTYPE: [uppertext(weapon.damtype)])")

		// !! ACTUAL DAMAGE GETS APPLIED HERE !!
		if(smacked.attacked_by(weapon, attacker))
			attack_result |= ATTACK_SWING_HIT

	if(right_clicking)
		switch(weapon.afterattack_secondary(smacked, attacker, /* proximity_flag = */TRUE, params_to_use))
			if(SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
				return attack_result | ATTACK_SWING_CANCEL // Stops entire swing - If you only want to skip, add a new define
			if(SECONDARY_ATTACK_CALL_NORMAL)
				// pass() // call normal afterattack
			if(SECONDARY_ATTACK_CONTINUE_CHAIN)
				return attack_result // "continue", but there's nowhere else to go, so just return
			else
				CRASH("afterattack_secondary must return an SECONDARY_ATTACK_* define, please consult code/__DEFINES/combat.dm")

	// We don't really care about the return value of after attack.
	weapon.afterattack(smacked, attacker, /* proximity_flag = */TRUE, params_to_use)
	return attack_result

/// Creates an image for use in attack animations
/datum/attack_style/melee_weapon/proc/create_attack_image(mob/living/attacker, obj/item/weapon, turf/initial_loc, angle)
	if(isnull(initial_loc))
		initial_loc = attacker.loc
	if(isnull(angle))
		angle = -weapon.weapon_sprite_angle + get_angle(attacker, initial_loc)

	var/image/attack_image = image(icon = weapon, loc = attacker, layer = attacker.layer + 0.1)
	attack_image.transform = turn(attack_image.transform, angle)
	attack_image.transform *= sprite_size_multiplier
	attack_image.pixel_x = (initial_loc.x - attacker.x) * 16
	attack_image.pixel_y = (initial_loc.y - attacker.y) * 16
	return attack_image

/**
 * Unarmed attack styles work slightly differently
 *
 * For normal attack styles, the style should not be handling the damage whatsoever, it should be handled by the weapon.
 *
 * But since we have no weapon for these, we kinda hvae to do it ourselves.
 */
/datum/attack_style/unarmed
	successful_hit_sound = 'sound/weapons/punch1.ogg'
	miss_sound = 'sound/weapons/punchmiss.ogg'

	/// Used for playing a little animation over the turf
	var/attack_effect = ATTACK_EFFECT_PUNCH
	/// Whether martial arts triggers off of these attacks
	var/martial_arts_compatible = TRUE

/datum/attack_style/unarmed/check_pacifism(mob/living/attacker, obj/item/weapon, right_clicking)
	return FALSE

/// Important to ntoe for unarmed attacks:
/// If the attacker's a carbon, the weapon is the bodypart being used to strike with.
/// But if the attacker is a simplemob, it will be null.
/datum/attack_style/unarmed/execute_attack(mob/living/attacker, obj/item/bodypart/weapon, list/turf/affected_turfs, atom/priority_target, right_clicking)
	ASSERT(isnull(weapon) || istype(weapon, /obj/item/bodypart))
	return ..()

/datum/attack_style/unarmed/finalize_attack(mob/living/attacker, mob/living/smacked, obj/item/weapon, right_clicking)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("No unarmed interaction for [type]! You must implement this.")

/// Unarmed subtypes allow an override effect to be passed down.
/datum/attack_style/unarmed/attack_effect_animation(mob/living/attacker, obj/item/bodypart/weapon, list/turf/affected_turfs, override_effect)
	var/selected_effect = override_effect || attack_effect
	if(selected_effect)
		attacker.do_attack_animation(get_movable_to_layer_effect_over(affected_turfs), selected_effect)

/datum/attack_style/unarmed/collide_with_solid_atom(atom/blocking_us, obj/item/weapon, mob/living/attacker)
	return ATTACK_SWING_SKIPPED
