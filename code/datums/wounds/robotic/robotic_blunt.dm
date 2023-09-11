/**
 * Level 1:
 * Easy to get, relatively easy to treat, low impact
 *
 * Head: If attacked, cause modest shake. No movement shake, or very rare/weak movement shake.
 * Arms: Interaction delay. No drop chance/Rare drop chance.
 * Legs: Slight limp. Low knockdown chance, low knockdown duration.
 * Chest: Quite low chance to gain nausea when moving, modest chance when hit, and either no or very rare organ damage.
 *
 * Screw the limb, or hit it with low force attacks
 *
 * Level 2:
 * Hard-ish to get, and not easy to get rid of (Ghetto a bad solution, or go in for surgery. No self surgery)
 *
 * Head: If attacked, severe shake. Somewhat disruptive movement shake.
 * Arms: Large interaction delay. Moderate drop chance.
 * Legs: Strong limp. Medium knockdown chance, low/medium duration
 * Chest: Low/Medium chance to gain nausea when moving, High chance when hit, medium chance for organ damage when hit, low/very low when moving
 *
 * Secure internals via screwdriver/wrench or by pouring in bone gel and waiting a while, then weld
 *
 * Level 3:
 * Quite hard to get, hard to get rid of (You need a long-ish surgery)
 *
 * Head: If attacked, extreme shake. Very disruptive movement shake.
 * Arms: Extreme interaction delay. High drop chance.
 * Legs: Extreme limp/Unusable. Large knockdown chance, medium duration.
 * Chest: High chance to gain nausea when moving, and high chance when hit. High chance for organ damage when hit, low/medium when moving.
 *
 * Heat limb (Or use RCD), then mold it with blunt damage, aggrograb, or plunger, then secure internals as T2
 */

/// If a incoming attack is blunt, we increase the daze amount by this amount
#define BLUNT_ATTACK_DAZE_MULT 1.5

/// Percent chance for any hit to repair a wound with percussive maintenance
#define PERCUSSIVE_MAINTENANCE_REPAIR_CHANCE 20
/// Any incoming attacks must be below this value to count as percussive maintenance
#define PERCUSSIVE_MAINTENANCE_DAMAGE_THRESHOLD 8

/// Cost of an RCD to quickly fix our broken superstructure
#define ROBOTIC_T3_BLUNT_WOUND_RCD_COST 25

#define ROBOTIC_WOUND_DETERMINATION_MOVEMENT_EFFECT_MOD 0.5
#define ROBOTIC_WOUND_DETERMINATION_HIT_DAZE_MULT ROBOTIC_WOUND_DETERMINATION_MOVEMENT_EFFECT_MOD
#define ROBOTIC_WOUND_DETERMINATION_HIT_NAUSEA_MULT 0.5

/datum/wound/blunt/robotic
	name = "Robotic Blunt (Screws and bolts) Wound"
	wound_flags = (ACCEPTS_GAUZE)

	default_scar_file = METAL_SCAR_FILE

	/// The minimum effective damage our limb must sustain before we try to daze our victim.
	var/daze_attacked_minimum_score = 8

	/// How much effective damage is multiplied against for purposes of determining our camerashake's duration when we are hit on the head.
	var/head_attacked_shake_duration_ratio = 0.3
	/// How much effective damage is multiplied against for purposes of determining our camerashake's intensity when we are hit on the head.
	var/head_attacked_shake_intensity_ratio = 0.2

	/// How much effective damage is multiplied against for purposes of determining how much dizziness a strike to the head will add.
	var/head_attacked_dizzy_duration_ratio = 0.2

	/// The base chance, in percent, for moving to shake our camera. Multiplied against many local modifiers, such as resting, being gauzed, etc.
	var/head_movement_shake_chance = 100
	/// The base chance, in percent, for moving to increase dizziness. Multiplied against many local modifiers, such as resting, being gauzed, etc.
	var/head_movement_dizzy_chance = 100

	/// The base duration, in deciseconds, for our camera shake on movement.
	var/head_movement_base_shake_duration = 1
	/// The base intensity, in tiles, for our camera shake on movement.
	var/head_movement_base_shake_intensity = 1

	/// The base duration increment, in deciseconds, for our dizziness to be increased by when we move.
	var/head_movement_dizzy_base_duration = 1

	/// The maximum time in deciseconds daze() may cause dizziness for
	var/daze_dizziness_maximum_duration = 20 SECONDS

	/// The maximum duration our nausea will last for. See _stomach.dm for the various levels of nausea.
	var/max_nausea_duration = 20 SECONDS
	/// The base amount of nausea we apply to our victim on movement.
	var/chest_movement_base_nausea_score = 0.2 SECONDS
	/// Percent chance, every time we move, to attempt to increase nausea of the victim if we are on the chest.
	var/chest_movement_nausea_chance = 0

	/// The minimum damage the chest must sustain before we try to increase their nausea.
	var/chest_attacked_nausea_minimum_score = 7
	/// Assuming we sustain more damage than our minimum, this is the chance for a given attack to proc a nausea attempt.
	var/chest_attacked_nausea_chance = 25
	/// Damage the chest takes is multiplied against this for determining the amount of nausea to apply.
	var/chest_attacked_nausea_mult = 0.25 // saw = 15, 1.5 seconds of disgust at x1

	/// Percent chance, every time we move, to attempt to damage random organs if we are on the chest.
	var/chest_movement_organ_damage_chance = 0
	/// The minimum total damage we can roll when doing random movement organ damage.
	var/chest_movement_organ_damage_min = 1
	/// The maximum total damage we can roll when doing random movement organ damage.
	var/chest_movement_organ_damage_max = 3
	/// The max amount of damage any specific organ can take from being randomly damaged on movement.
	var/chest_movement_organ_damage_individual_max = 2

	/// The max amount of damage any specific organ can take from being randomly damaged on attacked.
	var/attacked_organ_damage_individual_max = 10
	/// The chance for the internal organs of our limb to be damaged when the limb is attacked.
	var/attacked_organ_damage_chance = 0
	/// Score mult for overall organ damage on hit
	var/attacked_organ_damage_mult = 0.5
	/// Minimum score required to damage random organs on hit
	var/attacked_organ_damage_minimum_score = 5

	/// Our current counter for gel + gauze regeneration
	var/regen_time_elapsed = 0 SECONDS
	/// Time needed for gel to secure internals.
	var/regen_time_needed = 30 SECONDS

	/// If we have used bone gel to secure internals.
	var/gelled = FALSE
	/// Total brute damage taken over the span of [regen_time_needed] deciseconds when we gel our limb.
	var/gel_damage = 40 // brute in total

	/// If we are ready to begin screwdrivering or gelling our limb.
	var/ready_to_secure_internals = FALSE
	/// If internals are secured, and we are ready to weld our limb closed and end the wound
	var/ready_to_ghetto_weld = TRUE

	/// % chance for hitting our limb to fix something.
	var/percussive_maintenance_repair_chance = 10
	/// Damage must be over this to proc percussive maintenance.
	var/percussive_maintenance_damage_threshold = 7

	/// If true, when we move, we can attempt to shake the camera of our victim.
	var/can_do_movement_shake = TRUE
	/// The time, in world time, that we will be allowed to do another movement shake. Useful because it lets us prioritize attacked shakes over movement shakes.
	var/time_til_next_movement_shake_allowed // nulled by default

	/// Multiplies the camera shake by this for the purposes of deciding if we should override dizziness.
	var/head_movement_shake_dizziness_overtake_mult = 1

	/// The percent our limb must get to max damage by burn damage alone to count as malleable if it has no T2 burn wound.
	var/limb_burn_percent_to_max_threshold_for_malleable = 0.8 // must be 75% to max damage by burn damage alone

/datum/wound_pregen_data/blunt_metal
	abstract = TRUE

	required_limb_biostate = BIO_METAL

	wound_series = WOUND_SERIES_METAL_BLUNT_BASIC
	required_wounding_types = list(WOUND_BLUNT)

/datum/wound_pregen_data/blunt_metal/generate_scar_priorities()
	return list("[BIO_METAL]")

/datum/wound/blunt/robotic/set_victim(new_victim)
	if (victim)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(victim, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_MOVABLE_MOVED, PROC_REF(victim_moved))
		RegisterSignal(new_victim, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(victim_attacked))

	return ..()

/datum/wound/blunt/robotic/handle_process(seconds_per_tick, times_fired)
	. = ..() // this is all only really relevant for T1-T2 since they can get gelled

	if (!victim || IS_IN_STASIS(victim))
		return

	if (!gelled)
		processes = FALSE
		CRASH("handle_process called when gelled was false!")

	update_next_movement_shake()

	regen_time_elapsed += ((seconds_per_tick SECONDS) / 2)
	if(victim.body_position == LYING_DOWN)
		if(SPT_PROB(30, seconds_per_tick))
			regen_time_elapsed += 1 SECONDS
		if(victim.IsSleeping() && SPT_PROB(30, seconds_per_tick))
			regen_time_elapsed += 1 SECONDS

	var/effective_damage = ((gel_damage / (regen_time_needed / 10)) * seconds_per_tick)
	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		effective_damage *= gauze.splint_factor
	limb.receive_damage(effective_damage, wound_bonus = CANT_WOUND, damage_source = src)
	if(effective_damage && prob(33))
		var/gauze_text = (gauze?.splint_factor ? ", although the [gauze] helps to prevent some of the leakage" : "")
		to_chat(victim, span_danger("Your [limb.plaintext_zone] sizzles as some gel leaks and warps the exterior metal[gauze_text]..."))

	if(regen_time_elapsed > regen_time_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, span_notice("The gel within your [limb.plaintext_zone] has fully hardened, allowing you to re-solder it!"))
		processes = FALSE
		ready_to_ghetto_weld = TRUE
		ready_to_secure_internals = FALSE
		set_disabling(FALSE)

/datum/wound/blunt/robotic/modify_desc_before_span(desc)
	. = ..()

	if (!limb.current_gauze && gelled)
		. += ", [span_notice("with fizzling blue surgical gel holding them in place")]!"

/datum/wound/blunt/robotic/get_limb_examine_description()
	return span_warning("This limb looks loosely held together.")

/datum/wound/blunt/robotic/get_xadone_progress_to_qdel()
	return INFINITY

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
		if (pregen_data.wound_series == WOUND_SERIES_METAL_BURN_OVERHEAT && found_wound.severity >= WOUND_SEVERITY_SEVERE) // meh solution but whateva
			return found_wound
	return null

/datum/wound/blunt/robotic/treat(obj/item/item, mob/user)
	if (ready_to_secure_internals)
		if (istype(item, /obj/item/stack/medical/bone_gel))
			return apply_gel(item, user)
		else if (item_can_secure_internals(item))
			return secure_internals_normally(item, user)
	else if (ready_to_ghetto_weld && (item.tool_behaviour == TOOL_WELDER) || (item.tool_behaviour == TOOL_CAUTERY))
		return resolder(item, user)

/datum/wound/blunt/robotic/proc/victim_attacked(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if (def_zone != limb.body_zone) // use this proc since receive damage can also be called for like, chems and shit
		return

	if(!victim)
		return

	var/effective_damage = (damage - blocked)

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		effective_damage *= gauze.splint_factor

	switch (limb.body_zone)
		if (BODY_ZONE_HEAD)
			var/daze_damage = effective_damage
			if (!sharpness)
				daze_damage *= BLUNT_ATTACK_DAZE_MULT
			if (victim.has_status_effect(/datum/status_effect/determined))
				daze_damage *= ROBOTIC_WOUND_DETERMINATION_HIT_DAZE_MULT
			if (daze_damage < daze_attacked_minimum_score)
				return
			var/strength = (daze_damage * head_attacked_shake_intensity_ratio)
			var/duration = (daze_damage * head_attacked_shake_duration_ratio)
			if (can_shake_camera(strength, duration))
				shake_camera(victim, duration = duration, strength = strength)
				time_til_next_movement_shake_allowed = (world.time + (duration SECONDS))
				victim.adjust_dizzy_up_to(daze_damage * head_attacked_dizzy_duration_ratio, daze_dizziness_maximum_duration)

		if (BODY_ZONE_CHEST)
			var/nausea_prob_mult = 1
			if (victim.body_position == LYING_DOWN)
				nausea_prob_mult *= 0.5
			var/nausea_damage = effective_damage
			if (victim.has_status_effect(/datum/status_effect/determined))
				nausea_damage *= ROBOTIC_WOUND_DETERMINATION_HIT_NAUSEA_MULT
			if ((nausea_damage >= chest_attacked_nausea_minimum_score) && prob(chest_attacked_nausea_chance * nausea_prob_mult))
				victim.adjust_disgust(nausea_damage * chest_attacked_nausea_mult, max_nausea_duration)
				to_chat(victim, span_warning("You feel a wave of nausea as your [limb.plaintext_zone]'s internals jostle from the impact!"))

	if (limb_essential() && (effective_damage >= attacked_organ_damage_minimum_score) && prob(attacked_organ_damage_chance))
		attack_random_organs((effective_damage * attacked_organ_damage_mult), attacked_organ_damage_individual_max)

	if (!uses_percussive_maintenance() || damage <= 0 || damage > percussive_maintenance_damage_threshold || damagetype != BRUTE || sharpness)
		return
	var/chance_mult = 1
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance_mult *= 1.5
	if (isatom(attacking_item))
		var/atom/attacking_atom = attacking_item

		if (isliving(attacking_atom.loc))
			var/mob/living/living_user = attacking_atom.loc
			if (HAS_TRAIT(living_user, TRAIT_DIAGNOSTIC_HUD))
				chance_mult *= 1.5

		if (attacking_atom.loc != victim)
			chance_mult *= 3 // encourages people to get other people to beat the shit out of their limbs
	if (prob(percussive_maintenance_repair_chance * chance_mult))
		handle_percussive_maintenance_success(attacking_item)
	else
		handle_percussive_maintenance_failure(attacking_item)

/// Called when percussive maintenance succeeds at its random roll.
/datum/wound/blunt/robotic/proc/handle_percussive_maintenance_success(attacking_item)
	victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] rattles from the impact, but looks a lot more secure!"), \
		span_green("Your [limb.plaintext_zone] rattles into place!"))
	remove_wound()

/// Called when percussive maintenance faisl at its random roll.
/datum/wound/blunt/robotic/proc/handle_percussive_maintenance_failure(attacking_item)
	to_chat(victim, span_warning("Your [limb.plaintext_zone] rattles around, but you don't sense any sign of improvement."))

/datum/wound/blunt/robotic/proc/victim_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/overall_mult = 1

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		overall_mult *= gauze.splint_factor
	if (!victim.has_gravity(get_turf(victim)))
		overall_mult *= 0.5
	else if (victim.body_position == LYING_DOWN || (!forced && victim.move_intent == MOVE_INTENT_WALK))
		overall_mult *= 0.25
	if (victim.has_status_effect(/datum/status_effect/determined))
		overall_mult *= ROBOTIC_WOUND_DETERMINATION_MOVEMENT_EFFECT_MOD

	overall_mult *= get_buckled_movement_consequence_mult(victim.buckled)

	if (can_daze())
		var/shake_chance = head_movement_shake_chance
		var/dizzy_chance = head_movement_dizzy_chance

		shake_chance *= overall_mult
		dizzy_chance *= overall_mult
		var/daze_mult = LERP(1, 1.2, rand())

		var/duration = (daze_mult * head_movement_base_shake_duration)
		var/strength = (daze_mult * head_movement_base_shake_intensity)

		if (can_do_movement_shake && can_shake_camera(duration, strength * head_movement_shake_dizziness_overtake_mult) && prob(shake_chance))
			shake_camera(victim, duration = duration, strength = strength)

		if (prob(dizzy_chance))
			victim.adjust_dizzy_up_to(head_movement_dizzy_base_duration * daze_mult, daze_dizziness_maximum_duration)

	if (limb.body_zone == BODY_ZONE_CHEST)
		if (prob(chest_movement_nausea_chance * overall_mult))
			shake_organs_for_nausea(chest_movement_base_nausea_score, max_nausea_duration)

		if (prob(chest_movement_organ_damage_chance * overall_mult))
			attack_random_organs(get_chest_movement_organ_damage(), chest_movement_organ_damage_individual_max)

/datum/wound/blunt/robotic/proc/can_shake_camera(strength, duration)
	var/datum/status_effect/dizziness/dizzy_effect = get_dizzy_effect()
	if (isnull(dizzy_effect) || !dizzy_effect.applying_dizziness)
		return TRUE
	var/amount = (dizzy_effect.duration - world.time) / 10
	if (amount <= 0)
		return TRUE

	var/dizziness_strength = victim.resting ? 5 : 1

	var/total_dizziness_strength = max((amount - (dizziness_strength * initial(dizzy_effect.tick_interval) * 0.1)), 0)

	// 0.6 deciseconds is approx how long a dizzy proc lasts
	if ((total_dizziness_strength * DIZZINESS_BASE_CAMERA_SHAKE_DURATION) < (strength * duration))
		return TRUE

	return FALSE

/// Merely a wrapper proc for adjust_disgust that sends a to_chat.
/datum/wound/blunt/robotic/proc/shake_organs_for_nausea(score, max)
	victim.adjust_disgust(score, max)
	to_chat(victim, span_warning("You feel a wave of nausea as your [limb.plaintext_zone]'s internals jostle..."))

/// Iterates through all our limb's organs and applies randomized damage to them, and sends a to_chat.
/datum/wound/blunt/robotic/proc/attack_random_organs(total_damage, max_damage_per_organ)
	var/list/obj/item/organ/picked_organs = assign_damage_to_organs(total_damage, max_damage_per_organ)
	for (var/obj/item/organ/organ as anything in picked_organs)
		organ.apply_organ_damage(picked_organs[organ])
	to_chat(victim, span_warning("You feel your [limb.plaintext_zone]'s internals jostle painfully!"))

/// Randomly iterates through all our organs to assign damage to them.
/// Returns a assoc list of (organ -> damage), where damage is capped at max_damage_per_organ, unless theres not enough organs to take all the damage.
/datum/wound/blunt/robotic/proc/assign_damage_to_organs(damage_to_distribute, max_damage_per_organ)
	RETURN_TYPE(/list)

	var/obj/item/organ/picked_organs = list()
	var/remaining_damage_distribution = damage_to_distribute

	var/list/obj/item/organ/limb_organs = limb.get_organs()
	if (!length(limb_organs)) // catches both null and empty
		return list()
	while (remaining_damage_distribution > 0)
		for (var/obj/item/organ/organ as anything in shuffle(limb_organs))
			picked_organs[organ] += min(remaining_damage_distribution, max_damage_per_organ)
			remaining_damage_distribution -= picked_organs[organ]

			if (remaining_damage_distribution < 0)
				stack_trace("remaining_damage_distribution somehow went below 0!")
				break

			if (remaining_damage_distribution == 0)
				break

	return picked_organs

/// Allows us to shake the camera of our victim/give them dizziness.
/datum/wound/blunt/robotic/proc/can_daze()
	return (limb.body_zone == BODY_ZONE_HEAD)

/// Returns a multiplier to our movement effects based on what our victim is buckled to.
/datum/wound/blunt/robotic/proc/get_buckled_movement_consequence_mult(atom/movable/buckled_to)
	if (!buckled_to)
		return 1

	if (istype(buckled_to, /obj/structure/bed/medical))
		return 0.05
	else
		return 0.5

/datum/wound/blunt/robotic/proc/get_chest_movement_organ_damage()
	return rand(chest_movement_organ_damage_min, chest_movement_organ_damage_max)

/// Returns the dizziness status effect that our victim possesses. Nullable.
/datum/wound/blunt/robotic/proc/get_dizzy_effect()
	RETURN_TYPE(/datum/status_effect/dizziness)

	for (var/datum/status_effect/effect as anything in victim.status_effects)
		if (istype(effect, /datum/status_effect/dizziness))
			return effect

/// If this wound can be treated in its current state by just hitting it with a low force object.
/datum/wound/blunt/robotic/proc/uses_percussive_maintenance()
	return FALSE

/datum/wound/blunt/robotic/moderate
	name = "Loosened Screws"
	desc = "Various semi-external fastening instruments have loosened, causing components to jostle, inhibiting limb control."
	treat_text = "Recommend topical re-fastening of instruments with a screwdriver, though percussive maintenance via low-force bludgeoning may suffice - \
	albiet at risk of worsening the injury."
	examine_desc = "appears to be loosely secured"
	occur_text = "jostles awkwardly and seems to slightly unfasten"
	severity = WOUND_SEVERITY_MODERATE

	status_effect_type = /datum/status_effect/wound/blunt/robotic/moderate
	treatable_tools = list(TOOL_SCREWDRIVER)

	max_nausea_duration = DISGUST_LEVEL_GROSS + 10

	interaction_efficiency_penalty = 1.2
	limp_slowdown = 2.5
	limp_chance = 30
	threshold_penalty = 20

	daze_attacked_minimum_score = 8

	daze_dizziness_maximum_duration = 10 SECONDS

	chest_attacked_nausea_mult = 0.2

	head_movement_dizzy_base_duration = 0.3 SECONDS

	head_movement_base_shake_intensity = 0.05
	head_movement_base_shake_duration = 1 // exxxtremely weak

	head_attacked_dizzy_duration_ratio = 2.4

	head_attacked_shake_duration_ratio = 0.05
	head_attacked_shake_intensity_ratio = 0.08

	daze_dizziness_maximum_duration = 22 SECONDS

	can_scar = FALSE

	a_or_from = "from"

/datum/wound_pregen_data/blunt_metal/loose_screws
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/robotic/moderate

	threshold_minimum = 30

/datum/wound/blunt/robotic/moderate/uses_percussive_maintenance()
	return TRUE

/datum/wound/blunt/robotic/moderate/treat(obj/item/I, mob/user)
	if (I.tool_behaviour == TOOL_SCREWDRIVER)
		fasten_screws(I, user)
		return TRUE

	return ..()

/datum/wound/blunt/robotic/moderate/proc/fasten_screws(obj/item/screwdriver_tool, mob/user)
	if (!screwdriver_tool.tool_start_check())
		return

	var/delay_mult = 1

	if (user == victim)
		delay_mult *= 3

	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.5

	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.5

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	victim.visible_message(span_notice("[user] begins fastening the screws of [their_or_other] [limb.plaintext_zone]..."))

	if (!screwdriver_tool.use_tool(target = victim, user = user, delay = (10 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	victim.visible_message(span_green("[user] finishes fastening [their_or_other] [limb.plaintext_zone]!"))
	remove_wound()

/datum/wound/blunt/robotic/severe
	name = "Detached Fastenings"
	desc = "Various fastening devices are extremely loose and solder has disconnected at multiple points, causing significant jostling of internal components and \
	noticable limb dysfunction."
	treat_text = "Fastening of bolts and screws by a qualified technician (though bone gel may suffice in the absence of one) followed by re-soldering."
	examine_desc = "jostles with every move, solder visibly broken"
	occur_text = "visibly cracks open, solder flying everywhere"
	severity = WOUND_SEVERITY_SEVERE

	wound_flags = (ACCEPTS_GAUZE | MANGLES_EXTERIOR)
	treatable_by = list(/obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/robotic/severe
	treatable_tools = list(TOOL_WELDER)

	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	limp_chance = 60

	threshold_penalty = 40

	daze_attacked_minimum_score = 6

	daze_dizziness_maximum_duration = 20 SECONDS

	max_nausea_duration = DISGUST_LEVEL_VERYGROSS + 2 // just BARELY above the vomit threshold

	chest_movement_nausea_chance = 2
	chest_attacked_nausea_chance = 75
	chest_attacked_nausea_mult = 0.25 // saw = 15, 1.5 seconds of disgust at x1

	chest_movement_organ_damage_chance = 0
	chest_movement_organ_damage_min = 2
	chest_movement_organ_damage_max = 7
	chest_movement_organ_damage_individual_max = 2

	attacked_organ_damage_individual_max = 3
	attacked_organ_damage_chance = 25
	attacked_organ_damage_mult = 0.25

	head_movement_base_shake_intensity = 0.25
	head_movement_base_shake_duration = 1

	head_movement_dizzy_base_duration = 0.5 SECONDS

	head_attacked_shake_duration_ratio = 0.18
	head_attacked_shake_intensity_ratio = 0.1

	daze_dizziness_maximum_duration = 40 SECONDS

	head_attacked_dizzy_duration_ratio = 3.4

	a_or_from = "from"

	ready_to_secure_internals = TRUE
	ready_to_ghetto_weld = FALSE

	scar_keyword = "bluntsevere"

/datum/wound_pregen_data/blunt_metal/fastenings
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/robotic/severe

	threshold_minimum = 65

/datum/wound/blunt/robotic/severe/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited, attack_direction, wound_source)
	var/turf/limb_turf = get_turf(L)
	if (limb_turf)
		new /obj/effect/decal/cleanable/oil(limb_turf)

	return ..()

/datum/wound/blunt/robotic/item_can_treat(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_WELDER || potential_treater.tool_behaviour == TOOL_CAUTERY)
		if (ready_to_ghetto_weld)
			return TRUE

	if (ready_to_secure_internals)
		if (item_can_secure_internals(potential_treater))
			return TRUE

	return ..()

/// Returns TRUE if the item can be used in our 1st step (2nd if T3) of repairs.
/datum/wound/blunt/robotic/proc/item_can_secure_internals(obj/item/potential_treater)
	return (potential_treater.tool_behaviour == TOOL_SCREWDRIVER || potential_treater.tool_behaviour == TOOL_WRENCH || istype(potential_treater, /obj/item/stack/medical/bone_gel))

// Only really relevant for T2/T3 wounds: The primary way to secure internals, best done by someone else
/datum/wound/blunt/robotic/proc/secure_internals_normally(obj/item/securing_item, mob/user)
	if (!securing_item.tool_start_check())
		return TRUE

	var/chance = 10
	var/delay_mult = 1

	if (user == victim)
		chance *= 0.2
		delay_mult *= 2

	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		chance *= 15 // almost guaranteed if its not self surgery
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 8
		delay_mult *= 0.85
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 3
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance *= 2
		delay_mult *= 0.8

	var/confused = (chance < 25) // generate chance beforehand, so we can use this var

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	var/your_or_other = (user == victim ? "your" : "[user]'s")
	if (user)
		user.visible_message(span_notice("[user] begins the delicate operation of securing the internals of [their_or_other] [limb.plaintext_zone] internals..."))
	if (confused)
		to_chat(user, span_warning("You are confused by the layout of [your_or_other] [limb.plaintext_zone]! Perhaps a roboticist, an engineer, or a diagnostic HUD would help?"))

	if (!securing_item.use_tool(target = victim, user = user, delay = (10 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if (prob(chance))
		if (user)
			user.visible_message(span_green("[user] finishes securing the internals of [their_or_other] [limb.plaintext_zone]!"))
		to_chat(victim, span_green("Your [limb.plaintext_zone]'s internals are now secure! Your next step is to weld/cauterize it."))
		ready_to_secure_internals = FALSE
		ready_to_ghetto_weld = TRUE
	else
		if (user)
			user.visible_message(span_warning("[user] screws up and accidentally damages [their_or_other] [limb.plaintext_zone]!"))
		limb.receive_damage(brute = 5, damage_source = securing_item, wound_bonus = CANT_WOUND)

	return TRUE

// If we dont want to use a wrench/screwdriver, we can just use bone gel
/datum/wound/blunt/robotic/proc/apply_gel(obj/item/stack/medical/bone_gel/gel, mob/user)

	if (gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already filled with bone gel!"))
		return TRUE

	var/delay_mult = 1
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	user.visible_message(span_danger("[user] begins hastily applying [gel] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin hastily applying [gel] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone], disregarding the almost acidic effect it seems to have on the metal..."))

	if (!do_after(user, (base_treat_time * 2 * (user == victim ? 1.5 : 1)) * delay_mult, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	gel.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [gel] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [gel] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [gel] to your [limb.plaintext_zone], and you can almost hear the sizzling of the metal..."))
	else
		victim.visible_message(span_notice("[victim] finishes applying [gel] to [victim.p_their()] [limb.plaintext_zone], emitting a funny fizzing sound!"), span_notice("You finish applying [gel] to your [limb.plaintext_zone], and you can almost hear the sizzling of the metal..."))

	gelled = TRUE
	set_disabling(TRUE)
	processes = TRUE
	return TRUE

// The final step - T2 and T3 end at this
/datum/wound/blunt/robotic/proc/resolder(obj/item/welding_item, mob/user)
	if (!welding_item.tool_start_check())
		return TRUE

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	victim.visible_message(span_notice("[user] begins re-soldering [their_or_other] [limb.plaintext_zone]..."))

	var/delay_mult = 1
	if (welding_item.tool_behaviour == TOOL_CAUTERY)
		delay_mult *= 3
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	if (!welding_item.use_tool(target = victim, user = user, delay = 7 SECONDS * delay_mult, volume = 50,  extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	victim.visible_message(span_green("[user] finishes re-soldering [their_or_other] [limb.plaintext_zone]!"))
	remove_wound()
	return TRUE

/// If we've past the next allowed time to shake our movement, we set variables accordingly.
/datum/wound/blunt/robotic/proc/update_next_movement_shake()
	if (!isnull(time_til_next_movement_shake_allowed) || world.time < time_til_next_movement_shake_allowed)
		return

	time_til_next_movement_shake_allowed = null
	can_do_movement_shake = TRUE

/datum/wound/blunt/robotic/get_extra_treatment_text()
	return "Walking instead of running, buckling yourself to something, resting, or having no gravity all reduce consequences of movement. \n\
	Having a diagnostic hud or knowing robo/engi wires increases treatment quality, but self-tending reduces it."

/datum/wound/blunt/robotic/critical
	name = "Collapsed Superstructure"
	desc = "The superstructure has totally collapsed in one or more locations, causing extreme internal oscillation with every move and massive limb dysfunction"
	treat_text = "Reforming of superstructure via either RCD or manual molding, followed by typical treatment of loosened internals. \
				To manually mold, the limb must be aggressively grabbed and welded held to it to make it malleable (though attacking it til thermal overload may be adequate) \
				followed by application of a plunger or another aggressive grab to mold the metal, though percussive maintenance may suffice as well at this stage."
	occur_text = "caves in on itself, damaged solder and shrapnel flying out in a miniature explosion"
	examine_desc = "has caved in, with internal components visible through gaps in the metal"
	severity = WOUND_SEVERITY_CRITICAL

	disabling = TRUE

	interaction_efficiency_penalty = 2.8
	limp_slowdown = 8
	limp_chance = 80
	threshold_penalty = 60

	scar_keyword = "bluntcritical"

	status_effect_type = /datum/status_effect/wound/blunt/robotic/critical

	sound_effect = 'sound/effects/wounds/crack2.ogg'

	wound_flags = (ACCEPTS_GAUZE | MANGLES_EXTERIOR)
	treatable_by = list(/obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/robotic/critical
	treatable_tools = list(TOOL_WELDER)

	daze_attacked_minimum_score = 1

	daze_dizziness_maximum_duration = 80 SECONDS
	head_movement_dizzy_base_duration = 0.8 SECONDS

	max_nausea_duration = DISGUST_LEVEL_DISGUSTED + 5

	attacked_organ_damage_individual_max = 4
	attacked_organ_damage_chance = 75
	attacked_organ_damage_mult = 0.25

	chest_movement_nausea_chance = 12

	chest_attacked_nausea_chance = 100
	chest_attacked_nausea_mult = 0.5
	chest_attacked_nausea_minimum_score = 4

	chest_movement_organ_damage_chance = 2
	chest_movement_organ_damage_min = 3
	chest_movement_organ_damage_max = 6
	chest_movement_organ_damage_individual_max = 4

	head_movement_shake_dizziness_overtake_mult = 200

	a_or_from = "a"

	percussive_maintenance_repair_chance = 3
	percussive_maintenance_damage_threshold = 6

	regen_time_needed = 60 SECONDS
	gel_damage = 60

	ready_to_secure_internals = FALSE
	ready_to_ghetto_weld = FALSE

	/// Has the first stage of our treatment been completed? E.g. RCDed, manually molded...
	var/superstructure_remedied = FALSE

/datum/wound_pregen_data/blunt_metal/superstructure
	abstract = FALSE

	wound_path_to_generate = /datum/wound/blunt/robotic/critical

	threshold_minimum = 125

/datum/wound/blunt/robotic/critical/apply_wound(obj/item/bodypart/L, silent, datum/wound/old_wound, smited, attack_direction, wound_source)
	var/turf/limb_turf = get_turf(L)
	if (limb_turf)
		new /obj/effect/decal/cleanable/oil(limb_turf)
	var/turf/next_turf = get_step(limb_turf, REVERSE_DIR(attack_direction))
	if (next_turf)
		new /obj/effect/decal/cleanable/oil(next_turf)

	return ..()

/datum/wound/blunt/robotic/critical/item_can_treat(obj/item/potential_treater)
	if (!superstructure_remedied)
		if (istype(potential_treater, /obj/item/construction/rcd))
			return TRUE
		if (limb_malleable() && istype(potential_treater, /obj/item/plunger))
			return TRUE
	return ..()

/datum/wound/blunt/robotic/critical/check_grab_treatments(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_WELDER && (!superstructure_remedied && !limb_malleable()))
		return TRUE
	return ..()

/datum/wound/blunt/robotic/critical/treat(obj/item/item, mob/user)
	if (!superstructure_remedied)
		if (istype(item, /obj/item/construction/rcd))
			return rcd_superstructure(item, user)
		if (uses_percussive_maintenance() && istype(item, /obj/item/plunger))
			return plunge(item, user)
		if (item.tool_behaviour == TOOL_WELDER && !limb_malleable())
			return heat_metal(item, user)
	return ..()

/datum/wound/blunt/robotic/critical/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone)
		return FALSE

	if (superstructure_remedied || !limb_malleable())
		return FALSE

	if(user.grab_state < GRAB_AGGRESSIVE)
		to_chat(user, span_warning("You must have [victim] in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!"))
		return TRUE

	user.visible_message(span_danger("[user] begins softly pressing against [victim]'s collapsed [limb.plaintext_zone]..."), span_notice("You begin softly pressing against [victim]'s collapsed [limb.plaintext_zone]..."), ignored_mobs=victim)
	to_chat(victim, span_userdanger("[user] begins softly pressing against your collapsed [limb.plaintext_zone]!"))

	var/delay_mult = 1
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	if(!do_after(user, 8 SECONDS, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return
	mold_metal(user)
	return TRUE

// Once our superstructure is heated (T2 robotic burn or 125% burn damage) we can aggro grab and start pushing the metal around
/datum/wound/blunt/robotic/critical/proc/mold_metal(mob/living/carbon/human/user)
	var/chance = 40

	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		chance *= 3
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 3
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance *= 2

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if ((user != victim && user.combat_mode))
		user.visible_message(span_danger("[user] molds [their_or_other] [limb.plaintext_zone] into a really silly shape! What a goofball!"))
		limb.receive_damage(brute = 40, wound_bonus = CANT_WOUND, damage_source = user)
	else if (prob(chance))
		user.visible_message(span_green("[user] carefully molds [their_or_other] [limb.plaintext_zone] into the proper shape!"))
		to_chat(victim, span_green("Your [limb.plaintext_zone] has been molded into the proper shape! Your next step is to use a screwdriver/wrench to secure your internals."))
		set_superstructure_status(TRUE)
	else
		user.visible_message(span_warning("[user] screws up, damaging [their_or_other] [limb.plaintext_zone] in their efforts to help!"))
		limb.receive_damage(brute = 5, damage_source = user, wound_bonus = CANT_WOUND)

	if (HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS))
		return

	to_chat(user, span_warning("You burn your hand on [victim]'s [limb.plaintext_zone]!"))
	var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
	affecting?.receive_damage(burn = 5)

// T2 burn wounds are required to mold metal, which finished the first step of treatment. Aggrograb someone and use a welder on them for a guaranteed wound with no damage
/datum/wound/blunt/robotic/critical/proc/heat_metal(obj/item/welder, mob/living/user)
	if (!welder.tool_use_check())
		return TRUE

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if (user)
		user.visible_message(span_notice("[user] carefully holds [welder] to [their_or_other] [limb.plaintext_zone], slowly heating it..."))

	var/delay_mult = 1
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	if (!welder.use_tool(target = victim, user = user, delay = 10 SECONDS * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	var/wound_path = /datum/wound/burn/robotic/overheat/severe
	if (user != victim && user.combat_mode)
		wound_path = /datum/wound/burn/robotic/overheat/critical
		user.visible_message(span_warning("[user] heats [victim]'s [limb.plaintext_zone] aggressively, overheating it far beyond the necessary point!"))
		limb.receive_damage(burn = 10, damage_source = welder)

	var/datum/wound/burn/robotic/overheat/overheat_wound = new wound_path
	overheat_wound.apply_wound(limb, wound_source = welder)

	to_chat(victim, span_green("Your [limb.plaintext_zone] is now heated, allowing it to be molded! Your next step is to have someone physically reset the superstructure with their hands."))
	return TRUE

// An RCD can be used on a T3 wound to finish its 1st treatment step with little risk and no burn wound
/datum/wound/blunt/robotic/critical/proc/rcd_superstructure(obj/item/construction/rcd/treating_rcd, mob/user)
	if (!treating_rcd.tool_use_check() || treating_rcd.get_matter(user) < ROBOTIC_T3_BLUNT_WOUND_RCD_COST)
		return TRUE

	if (user)
		user.visible_message(span_notice("[treating_rcd] whirs to life as it begins replacing the damaged superstructure of [victim]'s [limb.plaintext_zone]..."))

	var/delay_mult = 1
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	if (!treating_rcd.use_tool(target = victim, user = user, delay = 10 SECONDS * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE
	treating_rcd.useResource(ROBOTIC_T3_BLUNT_WOUND_RCD_COST, user)

	var/chance = 100
	if (victim == user)
		chance *= 0.75

	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		chance *= 5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 2
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 2
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance *= 2

	if (prob(chance))
		if (user)
			user.visible_message(span_green("[treating_rcd] lets out a small ping as it finishes replacing the superstructure of [victim]'s [limb.plaintext_zone]."))
		to_chat(victim, span_green("[treating_rcd] has finished replacing your [limb.plaintext_zone]'s superstructure! Your next step is to secure it with a screwdriver/wrench, though bone gel would also work."))
		set_superstructure_status(TRUE)
	else
		if (user)
			user.visible_message(span_warning("[user] screws up and accidentally damages more than they replaced with [treating_rcd]!"))
		limb.receive_damage(brute = 5, damage_source = treating_rcd, wound_bonus = CANT_WOUND)
	return TRUE

// A bit goofy but practical - you can use a plunger on a mallable limb instead of molding it or hitting it
// Far less punishing than other forms of ghetto self-tending but a lot less "proper" meaning you get worse bonuses from diag hud and such
// The "superior" ghetto self-tend compared to percussive maintenance
/datum/wound/blunt/robotic/critical/proc/plunge(obj/item/plunger/treating_plunger, mob/user)
	if (!treating_plunger.tool_use_check())
		return TRUE

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if (user)
		user.visible_message(span_notice("[user] starts plunging at the dents on [their_or_other] [limb.plaintext_zone]..."))

	var/delay_mult = 1
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		delay_mult *= 0.75

	delay_mult /= treating_plunger.plunge_mod

	if (!treating_plunger.use_tool(target = victim, user = user, delay = 8 SECONDS * delay_mult, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	var/chance = 80
	if (victim == user)
		chance *= 0.6

	if (HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES))
		chance *= 1.25
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 1.1
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 1.25
	if (HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		chance *= 1.5

	if (prob(chance))
		if (user)
			user.visible_message(span_green("[victim]'s [limb.plaintext_zone] lets out a sharp POP as the suction of [treating_plunger] forces the superstructure into it's normal position!"))
		to_chat(victim, span_green("Your [limb.plaintext_zone]'s structure has been reset to it's proper position! Your next step is to secure it with a screwdriver/wrench, though bone gel would also work."))
		set_superstructure_status(TRUE)
	else
		if (user)
			user.visible_message(span_warning("[victim]'s [limb.plaintext_zone] lets out a strained creak as [treating_plunger] rips some shrapnel out of the chassis!"))
		limb.receive_damage(brute = 5, damage_source = treating_plunger)
	return TRUE

/datum/wound/blunt/robotic/critical/handle_percussive_maintenance_success(attacking_item)
	victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] gets smashed into a proper shape!"), \
		span_green("Your [limb.plaintext_zone] smashes into place! Your next step is to secure it with a screwdriver/wrench, though bone gel would also work."))
	set_superstructure_status(TRUE)

/datum/wound/blunt/robotic/critical/handle_percussive_maintenance_failure(attacking_item)
	to_chat(victim, span_warning("Your [limb.plaintext_zone] only deforms more from the impact..."))
	limb.receive_damage(brute = 1, damage_source = attacking_item, wound_bonus = CANT_WOUND)

/datum/wound/blunt/robotic/critical/uses_percussive_maintenance()
	return (!superstructure_remedied && limb_malleable())

/datum/wound/blunt/robotic/critical/proc/set_superstructure_status(remedied)
	superstructure_remedied = remedied
	ready_to_secure_internals = remedied

#undef BLUNT_ATTACK_DAZE_MULT

#undef PERCUSSIVE_MAINTENANCE_REPAIR_CHANCE
#undef PERCUSSIVE_MAINTENANCE_DAMAGE_THRESHOLD

#undef ROBOTIC_T3_BLUNT_WOUND_RCD_COST

#undef ROBOTIC_WOUND_DETERMINATION_MOVEMENT_EFFECT_MOD
#undef ROBOTIC_WOUND_DETERMINATION_HIT_DAZE_MULT
#undef ROBOTIC_WOUND_DETERMINATION_HIT_NAUSEA_MULT
