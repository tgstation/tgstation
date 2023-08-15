/**
 * IDEAS
 *
 * If head/chest takes daamge w/ this, on some level, shake screen/cause confusion
 * If on chest and takes damage, vomit
 * If arm takes damage w/ this, chance to drop item or use it?
 * If leg takes damage w/ this, chance to fall over?
 *
 * If on leg, limp
 *
 * Fix by doing surgery to readjust things
 */

/// If a incoming attack is blunt, we increase the daze amount by this amount
#define BLUNT_ATTACK_DAZE_MULT 2
#define DAZE_DIZZINESS_MAXIMUM_DURATION 20 SECONDS
#define DAZE_BASE_MOVEMENT_SCORE 5

#define UNSECURE_WOUND_ON_HIT_KNOCKDOWN_DURATION 2 SECONDS
#define BLUNT_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 0.2
#define SLASH_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 0.7
#define PIERCE_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 1.2
#define BURN_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 0.2

/datum/wound/blunt/robotic
	name = "Robotic Blunt (Screws and bolts) Wound"
	wound_flags = (ACCEPTS_GAUZE)

	required_limb_biostate = BIO_ROBOTIC

	/// The basic multiplier applied to the effective daze strength whenever we do one.
	var/daze_mult = 0.2

	var/daze_dizzy_minimum_score = 10
	var/daze_dizzy_mult = 0.2

	/// The score needed to cause a camerashake.
	var/daze_camera_shake_minimum_score = 15
	var/daze_shake_duration_coefficient = 0.2
	var/daze_shake_intensity_coefficient = 0.2

	/// The minimum damage our limb must sustain before we try to daze our victim.
	var/daze_attacked_minimum_score = 10
	/// Assuming we sustain more damage than our minimum, this is the chance for a given attack to proc a daze attempt.
	var/daze_attacked_chance = 50

	/// Percent chance, every time we move, to attempt to daze the victim if we are on the head.
	var/head_movement_daze_chance = 90

	/// The maximum duration our nausea will last for.
	var/max_nausea_duration = 10 SECONDS
	/// The base amount of nausea we apply to our victim on movement.
	var/chest_movement_base_nausea_score = 5
	/// Percent chance, every time we move, to attempt to increase nausea of the victim if we are on the chest.
	var/chest_movement_nausea_chance = 20

	/// Percent chance, every time we move, to attempt to damage random organs if we are on the chest.
	var/chest_movement_organ_damage_chance = 0
	/// The minimum total damage we can roll when doing random movement organ damage.
	var/chest_movement_organ_damage_min = 5
	/// The maximum total damage we can roll when doing random movement organ damage.
	var/chest_movement_organ_damage_max = 15

	/// The minimum damage the chest must sustain before we try to increase their nausea.
	var/chest_attacked_nausea_minimum_score = 10
	/// Assuming we sustain more damage than our minimum, this is the chance for a given attack to proc a nausea attempt.
	var/chest_attacked_nausea_chance = 50

	/// Damage the chest takes is multiplied against this for determining the amount of nausea to apply.
	var/chest_attacked_nausea_mult = 1

	/// The chance for the internal organs of our limb to be attacked when the limb is attacked.
	var/base_exposed_organs_attacked_chance = 0

	/// The max amount of damage any specific organ can take from being randomly attacked.
	var/max_individual_organ_damage = 15

	/// Damage arms take is multiplied by this to get the percent chance of dropping it's held item when attacked.
	var/drop_item_on_hit_chance_mult = 1
	/// Damage legs take is multiplied by this to get the percent chance of the victim collapsing when legs are attacked.
	var/knockdown_on_hit_chance_mult = 1

/datum/wound/blunt/robotic/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	RegisterSignals(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED), PROC_REF(update_inefficiencies))
	RegisterSignal(victim, COMSIG_MOVABLE_MOVED, PROC_REF(victim_moved))

	update_inefficiencies()

//	RegisterSignal(victim, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(victim_attacked))

/datum/wound/blunt/robotic/remove_wound(ignore_limb, replaced)
	UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
	UnregisterSignal(limb, COMSIG_BODYPART_GAUZED)
	UnregisterSignal(limb, COMSIG_BODYPART_GAUZE_DESTROYED)

	return ..()

/datum/wound/blunt/robotic/proc/victim_moved(atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/mult = 1
	if (victim.body_position == LYING_DOWN)
		mult *= 0.5

	if (!forced && victim.m_intent == MOVE_INTENT_WALK)
		mult *= 0.5

	if (!victim.has_gravity(get_turf(victim)))
		mult *= 0.2

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		mult *= gauze.splint_factor

	if (can_daze() && prob(head_movement_daze_chance))
		daze(DAZE_BASE_MOVEMENT_SCORE * mult)

	if (limb.body_zone == BODY_ZONE_CHEST)
		if (prob(chest_movement_nausea_chance))
			shake_organs_for_nausea(chest_movement_base_nausea_score * mult, max_nausea_duration)

		if (prob(chest_movement_organ_damage_chance))
			attack_random_organs(get_chest_movement_organ_damage() * mult)

/datum/wound/blunt/robotic/proc/shake_organs_for_nausea(score, max)
	victim.adjust_disgust(score, max)
	to_chat(victim, span_warning("You feel your organs jostle around, and suddenly feel sick..."))

/datum/wound/blunt/robotic/proc/get_chest_movement_organ_damage()
	return rand(chest_movement_organ_damage_min, chest_movement_organ_damage_max)

/datum/wound/blunt/robotic/proc/can_daze()
	return (limb.body_zone == BODY_ZONE_HEAD)

/datum/wound/blunt/robotic/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction)
	if(!victim)
		return

	var/effective_damage = wounding_dmg
	if (wounding_type == WOUND_BLUNT)
		effective_damage *= BLUNT_ATTACK_DAZE_MULT

	switch (limb.body_zone) // TODO: test if this proc is called after wound_injury, we want these to happen on wound
		if (BODY_ZONE_HEAD)
			if (effective_damage < daze_attacked_minimum_score)
				return
			if (prob(daze_attacked_chance))
				daze(effective_damage)

		if (BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			try_dropping_item(effective_damage)

		if (BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			try_falling_over(effective_damage)

		if (BODY_ZONE_CHEST)
			if ((effective_damage >= chest_attacked_nausea_minimum_score) && prob(chest_attacked_nausea_chance))
				shake_organs_for_nausea((effective_damage * chest_attacked_nausea_mult), max_nausea_duration)

	if (wounding_dmg > WOUND_MINIMUM_DAMAGE)
		if (exposed_organ_attacked(wounding_type, wounding_dmg))
			attack_random_organs(total_damage = wounding_dmg)

/datum/wound/blunt/robotic/proc/attack_random_organs(total_damage, max_damage_per_organ = max_individual_organ_damage)
	var/list/obj/item/organ/picked_organs = assign_damage_to_organs()
	for (var/obj/item/organ/organ as anything in picked_organs)
		organ.apply_organ_damage(picked_organs[organ])
	to_chat(victim, span_warning("You feel your [limb.plaintext_zone]'s internals jostle painfully!"))

/datum/wound/blunt/robotic/proc/assign_damage_to_organs(wounding_dmg, max_damage_per_organ = max_individual_organ_damage)
	var/obj/item/organ/picked_organs = list()
	var/remaining_damage_distribution = wounding_dmg

	for (var/obj/item/organ/organ as anything in limb.get_organs())
		picked_organs[organ] = min(wounding_dmg, max_damage_per_organ)
		remaining_damage_distribution -= picked_organs[organ]

		if (remaining_damage_distribution < 0)
			stack_trace("remaining_damage_distribution somehow went below 0!")
			break

		if (remaining_damage_distribution == 0)
			break

	return picked_organs

/datum/wound/blunt/robotic/proc/exposed_organ_attacked(wounding_type, wounding_dmg)
	if (!base_exposed_organs_attacked_chance)
		return FALSE

	var/base_chance = base_exposed_organs_attacked_chance

	switch (wounding_type)
		if (WOUND_BLUNT)
			base_chance *= BLUNT_ATTACK_EXPOSED_ORGAN_CHANCE_MULT
		if (WOUND_SLASH)
			base_chance *= SLASH_ATTACK_EXPOSED_ORGAN_CHANCE_MULT
		if (WOUND_PIERCE)
			base_chance *= PIERCE_ATTACK_EXPOSED_ORGAN_CHANCE_MULT
		if (WOUND_BURN)
			base_chance *= BURN_ATTACK_EXPOSED_ORGAN_CHANCE_MULT

	return prob(base_chance)

/datum/wound/blunt/robotic/proc/daze(daze_amount)
	var/obj/item/stack/gauze = limb.current_gauze
	var/effective_score = (daze_amount * daze_mult)
	if (gauze)
		effective_score *= gauze.splint_factor

	if ((daze_amount >= daze_camera_shake_minimum_score))
		shake_camera(victim, duration = (daze_amount * daze_shake_duration_coefficient), strength = (daze_amount * daze_shake_intensity_coefficient))

	victim.adjust_dizzy_up_to(daze_amount * daze_dizzy_mult, DAZE_DIZZINESS_MAXIMUM_DURATION)

/datum/wound/blunt/robotic/proc/try_dropping_item(score)
	var/obj/item/held_item = victim.get_item_for_held_index(limb.held_index)
	if (istype(held_item, /obj/item/offhand))
		held_item = victim.get_inactive_held_item()
	if (!held_item)
		return

	var/drop_chance = min((score * drop_item_on_hit_chance_mult), 100)
	if (prob(drop_chance))
		if (victim.dropItemToGround(held_item))
			victim.visible_message(span_danger("[victim]'s [limb.plaintext_zone] shakes from the impact and drops [held_item]!"), \
			span_warning("<b>The impact on your [limb.plaintext_zone] causes you to drop [held_item]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)

/datum/wound/blunt/robotic/proc/try_falling_over(score)
	var/fall_chance = min((score * knockdown_on_hit_chance_mult), 100)
	if (prob(fall_chance))
		victim.Knockdown(UNSECURE_WOUND_ON_HIT_KNOCKDOWN_DURATION)
		if (victim.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB)) // So the message isn't duplicated. If they were stunned beforehand by something else, then the message not showing makes more sense anyways.
			return
		to_chat(victim, span_warning("The blow to your [limb.plaintext_zone] sends you to the ground!"))

/datum/wound/blunt/robotic/proc/update_inefficiencies()
	SIGNAL_HANDLER

	if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(limb.current_gauze?.splint_factor)
			limp_slowdown = initial(limp_slowdown) * limb.current_gauze.splint_factor
			limp_chance = initial(limp_chance) * limb.current_gauze.splint_factor
		else
			limp_slowdown = initial(limp_slowdown)
			limp_chance = initial(limp_chance)
		victim.apply_status_effect(/datum/status_effect/limp)
	else if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(limb.current_gauze?.splint_factor)
			interaction_efficiency_penalty = 1 + ((interaction_efficiency_penalty - 1) * limb.current_gauze.splint_factor)
		else
			interaction_efficiency_penalty = initial(interaction_efficiency_penalty)

	if(initial(disabling))
		set_disabling(!limb.current_gauze)

	limb.update_wounds()

/datum/wound/blunt/robotic/moderate
	name = "Loosened Screws"
	desc = "Various semi-external fastening instruments have loosened, causing components to jostle, inhibiting limb control."
	treat_text = "Recommend topical re-fastening of instruments with a screwdriver, though percussive maintenance may suffice at risk of worsening the injury."
	examine_desc = "appears to be loosely secured"
	occur_text = "jostles awkwardly and seems to slightly unfasten"
	severity = WOUND_SEVERITY_MODERATE

	interaction_efficiency_penalty = 1.15
	limp_slowdown = 3
	limp_chance = 50
	threshold_minimum = 35
	threshold_penalty = 15

	status_effect_type = /datum/status_effect/wound/blunt/bone/moderate
	treatable_tool = TOOL_SCREWDRIVER

	a_or_from = "from"

	severity = WOUND_SEVERITY_MODERATE

/datum/wound/blunt/robotic/moderate/treat(obj/item/I, mob/user)
	if (I.tool_behaviour == TOOL_SCREWDRIVER)
		screw(I, user)

/datum/wound/blunt/robotic/moderate/proc/screw(obj/item/screwdriver_tool, mob/user)
	if (!screwdriver_tool.tool_start_check())
		return

	var/delay_mult = (user == victim ? 3 : 1) //3x as long if you do it yourself

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	victim.visible_message(span_notice("[user] begins fastening [their_or_other] [limb.plaintext_zone]'s screws..."))

	if (!screwdriver_tool.use_tool(target = victim, user = user, delay = (10 SECONDS * delay_mult), amount = 1, volume = 50, extra_checks = PROC_REF(still_exists)))
		return

	victim.visible_message(span_green("[user] finishes fastening [their_or_other] [limb.plaintext_zone]!"))
	remove_wound()

/datum/wound/blunt/robotic/severe
	name = "Damaged Fastenings"
	desc = "Various fastening devices have been heavily damaged, and solder has disconnected at multiple points, causing significant jostling of internal components and \
			noticable limb dysfunction"
	treat_text = "Surgical maintenance to repair the fastening instruments, then re-welding of solder - though application of surgical glue and post-hoc weldering may suffice."
	examine_desc = "has its internal components visible through unsecured gaps in the metal"
	occur_text = "shudders and groans, as it visible cracks open"

	treatable_by = list(/obj/item/stack/medical/bone_gel)
	treatable_tool = TOOL_WELDER

	/// Our current counter for gel + gauze regeneration
	var/regen_time_elapsed = 0 SECONDS
	var/regen_time_needed = 20 SECONDS

	daze_mult = 1
	daze_camera_shake_minimum_score = 10

	wound_flags = (ACCEPTS_GAUZE | MANGLES_BONE)

	severity = WOUND_SEVERITY_SEVERE

	var/gelled = FALSE
	var/ready_to_ghetto_weld = FALSE
	var/gel_damage = 1.5 // per second

	base_exposed_organs_attacked_chance = 5

	threshold_minimum = 75
	threshold_penalty = 50

	a_or_from = "from"

/datum/wound/blunt/robotic/severe/treat(obj/item/item, mob/user)
	if (istype(item, /obj/item/stack/medical/bone_gel))
		gel(item, user)
	else if (item.tool_behaviour == TOOL_WELDER)
		if (!ready_to_ghetto_weld)
			var/message
			if (gelled)
				message = "The gel within [victim]'s [limb.plaintext_zone] has not yet fully hardened!"
			else
				message = "You need to secure the inner components with some surgical gel first!"
			to_chat(user, span_warning(message))
			return FALSE
		else
			weld(item, user)

/datum/wound/blunt/robotic/severe/proc/gel(obj/item/stack/medical/bone_gel/gel, mob/user)
	if (gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already filled with bone gel!"))
		return

	user.visible_message(span_danger("[user] begins hastily applying [gel] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin hastily applying [gel] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone], disregarding the bold \"ONLY USE WITH ORGANICS\" label..."))

	if (!do_after(user, base_treat_time * 2 * (user == victim ? 1.5 : 1), target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	gel.use(1)
	if(user != victim)
		user.visible_message(span_notice("[user] finishes applying [gel] to [victim]'s [limb.plaintext_zone], emitting a fizzing noise!"), span_notice("You finish applying [gel] to [victim]'s [limb.plaintext_zone]!"), ignored_mobs=victim)
		to_chat(victim, span_userdanger("[user] finishes applying [gel] to your [limb.plaintext_zone], and you can almost hear the sizzling of the metal..."))
	else
		victim.visible_message(span_notice("[victim] finishes applying [gel] to [victim.p_their()] [limb.plaintext_zone], emitting a funny fizzing sound!"), span_notice("You finish applying [gel] to your [limb.plaintext_zone], and you can almost hear the sizzling of the metal..."))

	gelled = TRUE
	set_disabling(TRUE)
	processes = TRUE

/datum/wound/blunt/robotic/severe/proc/weld(obj/item/welding_item, mob/user)
	if (!welding_item.tool_start_check())
		return

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	victim.visible_message(span_notice("[user] begins re-soldering [their_or_other] [limb.plaintext_zone]..."))

	if (!welding_item.use_tool(target = victim, user = user, delay = 7 SECONDS, amount = 1, volume = 50, extra_checks = PROC_REF(still_exists)))
		return

	victim.visible_message(span_green("[user] finishes re-soldering [their_or_other] [limb.plaintext_zone]!"))
	limb.receive_damage(burn = 5, damage_source = src) // not a proper fix
	remove_wound()

/datum/wound/blunt/robotic/severe/modify_desc_before_span(desc)
	. = ..()

	if (!limb.current_gauze)
		if (gelled)
			. += ", [span_notice("with fizzling blue surgical gel holding them in place")]!"

/datum/wound/blunt/robotic/severe/handle_process(seconds_per_tick, times_fired)
	. = ..()

	if (!gelled)
		processes = FALSE
		CRASH("handle_process called when gelled was false!")

	regen_time_elapsed += seconds_per_tick
	if(victim.body_position == LYING_DOWN)
		if(SPT_PROB(30, seconds_per_tick))
			regen_time_elapsed += 1 SECONDS
		if(victim.IsSleeping() && SPT_PROB(30, seconds_per_tick))
			regen_time_elapsed += 1 SECONDS

	var/effective_damage = (gel_damage * seconds_per_tick)
	limb.receive_damage(effective_damage, wound_bonus = CANT_WOUND, damage_source = src)
	victim.adjustStaminaLoss(effective_damage * 2)
	if(prob(33))
		to_chat(victim, span_danger("You feel your [limb.plaintext_zone] stiffen as the gel inside hardens..."))

	if(regen_time_elapsed > regen_time_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, span_notice("The gel within your [limb.plaintext_zone] has fully hardened, allowing you to re-solder it!"))
		processes = FALSE
		ready_to_ghetto_weld = TRUE
		set_disabling(FALSE)

/datum/wound/blunt/robotic/critical
	name = "Collapsed Superstructure"
	desc = "The superstructure has totally collapsed in one or more locations, exposing internal components and causing extreme limb dysfunction"
	treat_text = "Replacement of the superstructure with surgery, then following up with heavy resoldering, though gauze is effective as a temporary remedy."
	occur_text = "caves in on itself, completely exposing its internals"
	examine_desc = "looks caved in, with internal components and organs clearly visible"

	damage_mulitplier_penalty = 1.2
	interaction_efficiency_penalty = 3
	limp_slowdown = 8
	limp_chance = 90

	sound_effect = 'sound/effects/wounds/crack2.ogg'

	threshold_minimum = 120
	threshold_penalty = 50

	wound_flags = (ACCEPTS_GAUZE | MANGLES_BONE)

	severity = WOUND_SEVERITY_CRITICAL

	daze_mult = 3
	daze_camera_shake_minimum_score = WOUND_MINIMUM_DAMAGE

	base_exposed_organs_attacked_chance = 45 // this wound is REAL BAD

	a_or_from = "a"

#undef BLUNT_ATTACK_DAZE_MULT
#undef DAZE_DIZZINESS_MAXIMUM_DURATION
