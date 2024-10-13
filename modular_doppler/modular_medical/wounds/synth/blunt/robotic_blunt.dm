/// The multiplier put against our movement effects if our victim has the determined reagent
#define ROBOTIC_WOUND_DETERMINATION_MOVEMENT_EFFECT_MOD 0.7
/// The multiplier of stagger intensity on hit if our victim has the determined reagent
#define ROBOTIC_WOUND_DETERMINATION_STAGGER_MOVEMENT_MULT 0.7

/// The multiplier put against our movement effects if our limb is grasped
#define ROBOTIC_BLUNT_GRASPED_MOVEMENT_MULT 0.7

/datum/wound/blunt/robotic
	name = "Robotic Blunt (Screws and bolts) Wound"
	wound_flags = (ACCEPTS_GAUZE|SPLINT_OVERLAY|CAN_BE_GRASPED)

	default_scar_file = METAL_SCAR_FILE

	/// If we suffer severe head booboos, we can get brain traumas tied to them
	var/datum/brain_trauma/active_trauma
	/// What brain trauma group, if any, we can draw from for head wounds
	var/brain_trauma_group
	/// If we deal brain traumas, when is the next one due?
	var/next_trauma_cycle
	/// How long do we wait +/- 20% for the next trauma?
	var/trauma_cycle_cooldown

	/// The ratio stagger score will be multiplied against for determining the final chance of moving away from the attacker.
	var/stagger_movement_chance_ratio = 1
	/// The ratio stagger score will be multiplied against for determining the amount of pixelshifting we will do when we are hit.
	var/stagger_shake_shift_ratio = 0.05

	/// The ratio of stagger score to shake duration during a stagger() call
	var/stagger_score_to_shake_duration_ratio = 0.1

	/// In the stagger aftershock, the stagger score will be multiplied against for determining the chance of dropping held items.
	var/stagger_drop_chance_ratio = 1.25
	/// In the stagger aftershock, the stagger score will be multiplied against for determining the chance of falling over.
	var/stagger_fall_chance_ratio = 1

	/// In the stagger aftershock, the stagger score will be multiplied against for determining how long we are knocked down for.
	var/stagger_aftershock_knockdown_ratio = 0.5
	/// In the stagger after shock, the stagger score will be multiplied against this (if caused by movement) for determining how long we are knocked down for.
	var/stagger_aftershock_knockdown_movement_ratio = 0.1

	/// If the victim stops moving before the aftershock, aftershock effects will be multiplied against this.
	var/aftershock_stopped_moving_score_mult = 0.1

	/// The ratio damage applied will be multiplied against for determining our stagger score.
	var/chest_attacked_stagger_mult = 2.5
	/// The minimum score an attack must do to trigger a stagger.
	var/chest_attacked_stagger_minimum_score = 5
	/// The ratio of damage to stagger chance on hit.
	var/chest_attacked_stagger_chance_ratio = 2

	/// The base score given to stagger() when we successfully stagger on a move.
	var/base_movement_stagger_score = 30
	/// The base chance of moving to trigger stagger().
	var/chest_movement_stagger_chance = 1

	/// The base duration of a stagger()'s sprite shaking.
	var/base_stagger_shake_duration = 1.5 SECONDS
	/// The base duration of a stagger()'s sprite shaking if caused by movement.
	var/base_stagger_movement_shake_duration = 1.5 SECONDS

	/// The ratio of stagger score to camera shake chance.
	var/stagger_camera_shake_chance_ratio = 0.75
	/// The base duration of a stagger's aftershock's camerashake.
	var/base_aftershock_camera_shake_duration = 1.5 SECONDS
	/// The base strength of a stagger's aftershock's camerashake.
	var/base_aftershock_camera_shake_strength = 0.5

	/// The amount of x and y pixels we will be shaken around by during a movement stagger.
	var/movement_stagger_shift = 1

	/// If we are currently oscillating. If true, we cannot stagger().
	var/oscillating = FALSE

	/// % chance for hitting our limb to fix something.
	var/percussive_maintenance_repair_chance = 10
	/// Damage must be under this to proc percussive maintenance.
	var/percussive_maintenance_damage_max = 7
	/// Damage must be over this to proc percussive maintenance.
	var/percussive_maintenance_damage_min = 0

	/// The time, in world time, that we will be allowed to do another movement shake. Useful because it lets us prioritize attacked shakes over movement shakes.
	var/time_til_next_movement_shake_allowed = 0

	/// The percent our limb must get to max possible damage by burn damage alone to count as malleable if it has no T2 burn wound.
	var/limb_burn_percent_to_max_threshold_for_malleable = 0.8 // must be 75% to max damage by burn damage alone

	/// The last time our victim has moved. Used for determining if we should increase or decrease the chance of having stagger aftershock.
	var/last_time_victim_moved = 0

	processes = TRUE
	/// Whenever an oscillation is triggered by movement, we wait 4 seconds before trying to do another.
	COOLDOWN_DECLARE(movement_stagger_cooldown)

/datum/wound_pregen_data/blunt_metal
	abstract = TRUE
	required_limb_biostate = BIO_METAL
	wound_series = WOUND_SERIES_METAL_BLUNT_BASIC
	required_wounding_types = list(WOUND_BLUNT)

/datum/wound_pregen_data/blunt_metal/generate_scar_priorities()
	return list("[BIO_METAL]")

/datum/wound/blunt/robotic/set_victim(new_victim)
	if(victim)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(victim, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	if(new_victim)
		RegisterSignal(new_victim, COMSIG_MOVABLE_MOVED, PROC_REF(victim_moved))
		RegisterSignal(new_victim, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(victim_attacked))

	return ..()

/datum/wound/blunt/robotic/get_limb_examine_description()
	return span_warning("This limb looks loosely held together.")

// this wound is unaffected by cryoxadone and pyroxadone
/datum/wound/blunt/robotic/on_xadone(power)
	return

/datum/wound/blunt/robotic/wound_injury(datum/wound/old_wound, attack_direction)
	. = ..()

	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	if(limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group)
		processes = TRUE
		active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

	var/obj/item/held_item = victim.get_item_for_held_index(limb.held_index || 0)
	if(held_item && (disabling || prob(30 * severity)))
		if(istype(held_item, /obj/item/offhand))
			held_item = victim.get_inactive_held_item()
		if(held_item && victim.dropItemToGround(held_item))
			victim.visible_message(span_danger("[victim] drops [held_item] in shock!"), span_warning("<b>The force on your [limb.plaintext_zone] causes you to drop [held_item]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)

/datum/wound/blunt/robotic/remove_wound(ignore_limb, replaced)
	. = ..()

	QDEL_NULL(active_trauma)

/datum/wound/blunt/robotic/handle_process(seconds_per_tick, times_fired)
	. = ..()

	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS))
		return

	if (limb.body_zone == BODY_ZONE_HEAD && brain_trauma_group && world.time > next_trauma_cycle)
		if (active_trauma)
			QDEL_NULL(active_trauma)
		else
			active_trauma = victim.gain_trauma_type(brain_trauma_group, TRAUMA_RESILIENCE_WOUND)
		next_trauma_cycle = world.time + (rand(100-WOUND_BONE_HEAD_TIME_VARIANCE, 100+WOUND_BONE_HEAD_TIME_VARIANCE) * 0.01 * trauma_cycle_cooldown)

/// If true, allows our superstructure to be modified if we are T3. RCDs can always fix our superstructure.
/datum/wound/blunt/robotic/proc/limb_malleable()
	if (!isnull(get_overheat_wound()))
		return TRUE
	var/burn_damage_to_max = (limb.burn_dam / limb.max_damage) // only exists for the weird case where it cant get a overheat wound
	if (burn_damage_to_max >= limb_burn_percent_to_max_threshold_for_malleable)
		return TRUE
	return FALSE

/// If we have one, returns a robotic overheat wound of severe severity or higher. Null otherwise.
/datum/wound/blunt/robotic/proc/get_overheat_wound()
	RETURN_TYPE(/datum/wound/burn/robotic/overheat)
	for (var/datum/wound/found_wound as anything in limb.wounds)
		var/datum/wound_pregen_data/pregen_data = found_wound.get_pregen_data()
		if (pregen_data.wound_series == WOUND_SERIES_METAL_BURN_OVERHEAT && found_wound.severity >= WOUND_SEVERITY_MODERATE) // meh solution but whateva
			return found_wound
	return null

/// If our victim is lying down and is attacked in the chest, effective oscillation damage is multiplied against this.
#define OSCILLATION_ATTACKED_LYING_DOWN_EFFECT_MULT 0.5

/// If the attacker is wearing a diag hud, chance of percussive maintenance succeeding is multiplied against this.
#define PERCUSSIVE_MAINTENANCE_DIAG_HUD_CHANCE_MULT 1.5
/// If our wound has been scanned by a wound analyzer, chance of percussive maintenance succeeding is multiplied against this.
#define PERCUSSIVE_MAINTENANCE_WOUND_SCANNED_CHANCE_MULT 1.5
/// If the attacker is NOT our victim, chance of percussive maintenance succeeding is multiplied against this.
#define PERCUSSIVE_MAINTENANCE_ATTACKER_NOT_VICTIM_CHANCE_MULT 2.5

/// Signal handler proc to when our victim has damage applied via apply_damage(), which is a external attack.
/datum/wound/blunt/robotic/proc/victim_attacked(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if (def_zone != limb.body_zone) // use this proc since receive damage can also be called for like, chems and shit
		return
	if(!victim)
		return

	var/effective_damage = (damage - blocked)

	var/obj/item/stack/gauze = limb.current_gauze
	if(gauze)
		effective_damage *= gauze.splint_factor

	switch (limb.body_zone)

		if(BODY_ZONE_CHEST)
			var/oscillation_mult = 1
			if (victim.body_position == LYING_DOWN)
				oscillation_mult *= OSCILLATION_ATTACKED_LYING_DOWN_EFFECT_MULT
			var/oscillation_damage = effective_damage
			var/stagger_damage = oscillation_damage * chest_attacked_stagger_mult
			if (victim.has_status_effect(/datum/status_effect/determined))
				oscillation_damage *= ROBOTIC_WOUND_DETERMINATION_STAGGER_MOVEMENT_MULT
			if ((stagger_damage >= chest_attacked_stagger_minimum_score) && prob(oscillation_damage * chest_attacked_stagger_chance_ratio))
				stagger(stagger_damage * oscillation_mult, attack_direction, attacking_item, shift = stagger_damage * stagger_shake_shift_ratio)

	if(!uses_percussive_maintenance() || damage < percussive_maintenance_damage_min || damage > percussive_maintenance_damage_max || damagetype != BRUTE || sharpness)
		return
	var/success_chance_mult = 1
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		success_chance_mult *= PERCUSSIVE_MAINTENANCE_WOUND_SCANNED_CHANCE_MULT
	var/mob/living/user
	if (isatom(attacking_item))
		var/atom/attacking_atom = attacking_item
		user = attacking_atom.loc // nullable

		if (istype(user))
			if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
				success_chance_mult *= PERCUSSIVE_MAINTENANCE_DIAG_HUD_CHANCE_MULT

		if (user != victim)
			success_chance_mult *= PERCUSSIVE_MAINTENANCE_ATTACKER_NOT_VICTIM_CHANCE_MULT // encourages people to get other people to beat the shit out of their limbs
	if (prob(percussive_maintenance_repair_chance * success_chance_mult))
		handle_percussive_maintenance_success(attacking_item, user)
	else
		handle_percussive_maintenance_failure(attacking_item, user)

#undef OSCILLATION_ATTACKED_LYING_DOWN_EFFECT_MULT
#undef PERCUSSIVE_MAINTENANCE_DIAG_HUD_CHANCE_MULT
#undef PERCUSSIVE_MAINTENANCE_WOUND_SCANNED_CHANCE_MULT
#undef PERCUSSIVE_MAINTENANCE_ATTACKER_NOT_VICTIM_CHANCE_MULT

/// The percent, in decimal, of a stagger's shake() duration, that will be used in a addtimer() to queue aftershock().
#define STAGGER_PERCENT_OF_SHAKE_DURATION_TO_AFTERSHOCK_DELAY 0.65 // 1 = happens at the end, .5 = happens halfway through

/// Causes an oscillation, which 1. has a chance to move our victim away from the attacker, and 2. after a delay, calls aftershock().
/datum/wound/blunt/robotic/proc/stagger(stagger_score, attack_direction, obj/item/attacking_item, from_movement, shake_duration = base_stagger_shake_duration, shift, knockdown_ratio = stagger_aftershock_knockdown_ratio)
	if (oscillating)
		return

	var/self_message = "Your [limb.plaintext_zone] oscillates"
	var/message = "[victim]'s [limb.plaintext_zone] oscillates"
	if (attacking_item)
		message += " from the impact"
	else if (from_movement)
		message += " from the movement"
	message += "!"
	self_message += "! You might be able to avoid an aftershock by stopping and waiting..."

	if (isnull(attack_direction) && !isnull(attacking_item))
		attack_direction = get_dir(victim, attacking_item)

	if (!isnull(attack_direction) && prob(stagger_score * stagger_movement_chance_ratio))
		to_chat(victim, span_warning("The force of the blow sends you reeling!"))
		var/turf/target_loc = get_step(victim, attack_direction)
		victim.Move(target_loc)

	victim.visible_message(span_warning(message), ignored_mobs = victim)
	to_chat(victim, span_warning(self_message))
	victim.balloon_alert(victim, "oscillation! stop moving")

	victim.Shake(pixelshiftx = shift, pixelshifty = shift, duration = shake_duration)
	var/aftershock_delay = (shake_duration * STAGGER_PERCENT_OF_SHAKE_DURATION_TO_AFTERSHOCK_DELAY)
	var/knockdown_time = stagger_score * knockdown_ratio
	addtimer(CALLBACK(src, PROC_REF(aftershock), stagger_score, attack_direction, attacking_item, world.time, knockdown_time), aftershock_delay)
	oscillating = TRUE

#undef STAGGER_PERCENT_OF_SHAKE_DURATION_TO_AFTERSHOCK_DELAY

#define AFTERSHOCK_GRACE_THRESHOLD_PERCENT 0.33 // lower mult = later grace period = more forgiving

/**
 * Timer proc from stagger().
 *
 * Based on chance, causes items to be dropped, knockdown to be applied, and/or screenshake to occur.
 * Chance is massively reduced if the victim isn't moving.
 */
/datum/wound/blunt/robotic/proc/aftershock(stagger_score, attack_direction, obj/item/attacking_item, stagger_starting_time, knockdown_time)
	if (!still_exists())
		return FALSE

	var/message = "The oscillations from your [limb.plaintext_zone] spread, "
	var/limb_message = "causing "
	var/limb_affected

	var/stopped_moving_grace_threshold = (world.time - ((world.time - stagger_starting_time) * AFTERSHOCK_GRACE_THRESHOLD_PERCENT))
	var/victim_stopped_moving = (last_time_victim_moved <= stopped_moving_grace_threshold)
	if (victim_stopped_moving)
		stagger_score *= aftershock_stopped_moving_score_mult

	if (prob(stagger_score * stagger_drop_chance_ratio))
		limb_message += "your <b>hands</b>"
		victim.drop_all_held_items()
		limb_affected = TRUE

	if (prob(stagger_score * stagger_fall_chance_ratio))
		if (limb_affected)
			limb_message += " and "
		limb_message += "your <b>legs</b>"
		victim.Knockdown(knockdown_time)
		limb_affected = TRUE

	if (prob(stagger_score * stagger_camera_shake_chance_ratio))
		if (limb_affected)
			limb_message += " and "
		limb_message += "your <b>head</b>"
		shake_camera(victim, base_aftershock_camera_shake_duration, base_aftershock_camera_shake_strength)
		limb_affected = TRUE

	if (limb_affected)
		message += "[limb_message] to shake uncontrollably!"
	else
		message += "but pass harmlessly"
		if (victim_stopped_moving)
			message += " thanks to your stillness"
		message += "."

	to_chat(victim, span_danger(message))
	victim.balloon_alert(victim, "oscillation over")

	oscillating = FALSE

#undef AFTERSHOCK_GRACE_THRESHOLD_PERCENT

/// Called when percussive maintenance succeeds at its random roll.
/datum/wound/blunt/robotic/proc/handle_percussive_maintenance_success(attacking_item, mob/living/user)
	victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] rattles from the impact, but looks a lot more secure!"), \
		span_green("Your [limb.plaintext_zone] rattles into place!"))
	remove_wound()

/// Called when percussive maintenance fails at its random roll.
/datum/wound/blunt/robotic/proc/handle_percussive_maintenance_failure(attacking_item, mob/living/user)
	to_chat(victim, span_warning("Your [limb.plaintext_zone] rattles around, but you don't sense any sign of improvement."))

/// If our victim has no gravity, the effects of movement are multiplied by this.
#define VICTIM_MOVED_NO_GRAVITY_EFFECT_MULT 0.5
/// If our victim is resting, or is walking and isnt forced to move, the effects of movement are multiplied by this.
#define VICTIM_MOVED_CAREFULLY_EFFECT_MULT 0.25

/// Signal handler proc that applies movements affect to our victim if they were moved.
/datum/wound/blunt/robotic/proc/victim_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/overall_mult = 1

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		overall_mult *= gauze.splint_factor
	if (!victim.has_gravity(get_turf(victim)))
		overall_mult *= VICTIM_MOVED_NO_GRAVITY_EFFECT_MULT
	else if (victim.body_position == LYING_DOWN || (!forced && victim.move_intent == MOVE_INTENT_WALK))
		overall_mult *= VICTIM_MOVED_CAREFULLY_EFFECT_MULT
	if (victim.has_status_effect(/datum/status_effect/determined))
		overall_mult *= ROBOTIC_WOUND_DETERMINATION_MOVEMENT_EFFECT_MOD
	if (limb.grasped_by)
		overall_mult *= ROBOTIC_BLUNT_GRASPED_MOVEMENT_MULT

	overall_mult *= get_buckled_movement_consequence_mult(victim.buckled)

	if (limb.body_zone == BODY_ZONE_CHEST && COOLDOWN_FINISHED(src, movement_stagger_cooldown))
		var/stagger_chance = chest_movement_stagger_chance * overall_mult
		if (prob(stagger_chance))
			COOLDOWN_START(src, movement_stagger_cooldown, 4 SECONDS)
			stagger(base_movement_stagger_score, shake_duration = base_stagger_movement_shake_duration, from_movement = TRUE, shift = movement_stagger_shift, knockdown_ratio = stagger_aftershock_knockdown_movement_ratio)

	last_time_victim_moved = world.time

#undef VICTIM_MOVED_NO_GRAVITY_EFFECT_MULT
#undef VICTIM_MOVED_CAREFULLY_EFFECT_MULT

/// If our victim is buckled to a generic object, movement effects will be multiplied against this.
#define VICTIM_BUCKLED_BASE_MOVEMENT_EFFECT_MULT 0.5
/// If our victim is buckled to a medical bed (e.g. rollerbed), movement effects will be multiplied against this.
#define VICTIM_BUCKLED_ROLLER_BED_MOVEMENT_EFFECT_MULT 0.05

/// Returns a multiplier to our movement effects based on what our victim is buckled to.
/datum/wound/blunt/robotic/proc/get_buckled_movement_consequence_mult(atom/movable/buckled_to)
	if (!buckled_to)
		return 1

	if (istype(buckled_to, /obj/structure/bed/medical))
		return VICTIM_BUCKLED_ROLLER_BED_MOVEMENT_EFFECT_MULT
	else
		return VICTIM_BUCKLED_BASE_MOVEMENT_EFFECT_MULT

#undef VICTIM_BUCKLED_BASE_MOVEMENT_EFFECT_MULT
#undef VICTIM_BUCKLED_ROLLER_BED_MOVEMENT_EFFECT_MULT

/// If this wound can be treated in its current state by just hitting it with a low force object. Exists for conditional logic, e.g. "Should we respond
/// to percussive maintenance right now?". Critical blunt uses this to only react when the limb is malleable and superstructure is broken.
/datum/wound/blunt/robotic/proc/uses_percussive_maintenance()
	return FALSE

#undef ROBOTIC_WOUND_DETERMINATION_MOVEMENT_EFFECT_MOD
#undef ROBOTIC_WOUND_DETERMINATION_STAGGER_MOVEMENT_MULT

#undef ROBOTIC_BLUNT_GRASPED_MOVEMENT_MULT
