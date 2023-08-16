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

#define ROBOTIC_T3_BLUNT_WOUND_RCD_COST 25

#define BLUNT_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 0.2
#define SLASH_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 0.7
#define PIERCE_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 1.2
#define BURN_ATTACK_EXPOSED_ORGAN_CHANCE_MULT 0.2

/datum/wound/blunt/robotic
	name = "Robotic Blunt (Screws and bolts) Wound"
	wound_flags = (ACCEPTS_GAUZE)

	required_limb_biostate = BIO_ROBOTIC

	var/daze_dizzy_minimum_score = 5
	var/daze_dizzy_mult = 1

	var/daze_shake_duration_mult = 0.2
	var/daze_shake_intensity_mult = 0.2

	/// The minimum damage our limb must sustain before we try to daze our victim.
	var/daze_attacked_minimum_score = 8
	var/daze_movement_base_score = 5 // the same as if someone hit you with a 5 force weapon
	/// Assuming we sustain more damage than our minimum, this is the chance for a given attack to proc a daze attempt.
	var/daze_attacked_chance = 35
	/// Percent chance, every time we move, to attempt to daze the victim if we are on the head.
	var/head_movement_daze_chance = 5

	var/daze_movement_shake_duration_mult = 1
	var/daze_movement_shake_intensity_mult = 1

	var/daze_attacked_shake_duration_mult = 1
	var/daze_attacked_shake_intensity_mult = 1

	var/daze_dizziness_maximum_duration = 20 SECONDS

	/// The maximum duration our nausea will last for.
	var/max_nausea_duration = 5 SECONDS
	/// The base amount of nausea we apply to our victim on movement.
	var/chest_movement_base_nausea_score = 0.2 SECONDS
	/// Percent chance, every time we move, to attempt to increase nausea of the victim if we are on the chest.
	var/chest_movement_nausea_chance = 2

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
	var/chest_attacked_organ_damage_individual_max = 10
	/// The chance for the internal organs of our limb to be damaged when the limb is attacked.
	var/chest_attacked_organ_damage_chance = 0
	var/chest_attacked_organ_damage_mult = 0.5

	/// Damage arms take is multiplied by this to get the percent chance of dropping it's held item when attacked.
	var/drop_item_on_hit_chance_mult = 0.2
	var/drop_item_on_hit_minimum_damage = WOUND_MINIMUM_DAMAGE
	/// Damage legs take is multiplied by this to get the percent chance of the victim collapsing when legs are attacked.
	var/knockdown_on_hit_chance_mult = 0.2
	var/knockdown_on_hit_minimum_damage = WOUND_MINIMUM_DAMAGE
	/// Time, in deciseconds, a knockdown from being hit in the legs will last.
	var/knockdown_on_hit_time = 1 SECONDS

	/// Our current counter for gel + gauze regeneration
	var/regen_time_elapsed = 0 SECONDS
	var/regen_time_needed = 30 SECONDS

	var/gellable = FALSE
	var/gelled = FALSE
	var/ready_to_ghetto_weld = FALSE
	var/gel_damage = 40 // brute in total

	var/ready_to_secure_internals = FALSE
	// If we've secured internals already, next step is to weld
	var/ready_to_ghetto_weld = TRUE

	var/percussive_maintenance_repair_chance = 25
	var/percussive_maintenance_damage_threshold = 7

/datum/wound/blunt/robotic/moderate
	name = "Loosened Screws"
	desc = "Various semi-external fastening instruments have loosened, causing components to jostle, inhibiting limb control."
	treat_text = "Recommend topical re-fastening of instruments with a screwdriver, though percussive maintenance via low-force bludgeoning may suffice - \
				albiet at risk of worsening the injury."
	examine_desc = "appears to be loosely secured"
	occur_text = "jostles awkwardly and seems to slightly unfasten"
	severity = WOUND_SEVERITY_MODERATE

	status_effect_type = /datum/status_effect/wound/blunt/robotic/moderate
	treatable_tool = TOOL_SCREWDRIVER

	interaction_efficiency_penalty = 1.15
	limp_slowdown = 2
	limp_chance = 25
	threshold_minimum = 25
	threshold_penalty = 15

	drop_item_on_hit_minimum_damage = 8
	knockdown_on_hit_minimum_damage = 8

	daze_attacked_chance = 70
	daze_attacked_minimum_score = 8
	daze_attacked_shake_duration_mult = 0.05
	daze_attacked_shake_intensity_mult = 0.1

	daze_dizziness_maximum_duration = 20 SECONDS
	daze_dizzy_minimum_score = 5
	daze_dizzy_mult = 2

	daze_movement_shake_duration_mult = 0.2
	daze_movement_shake_intensity_mult = 0.1
	head_movement_daze_chance = 60

	a_or_from = "from"

/datum/wound/blunt/robotic/moderate/uses_percussive_maintenance()
	return TRUE

/datum/wound/blunt/robotic/moderate/treat(obj/item/I, mob/user)
	if (I.tool_behaviour == TOOL_SCREWDRIVER)
		screw(I, user)
		return TRUE

	return ..()

/datum/wound/blunt/robotic/moderate/proc/screw(obj/item/screwdriver_tool, mob/user)
	if (!screwdriver_tool.tool_start_check())
		return

	var/delay_mult = 1

	if (user == victim)
		delay_mult *= 3

	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		delay_mult *= 0.5

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	victim.visible_message(span_notice("[user] begins fastening the screws of [their_or_other] [limb.plaintext_zone]..."))

	if (!screwdriver_tool.use_tool(target = victim, user = user, delay = (10 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	victim.visible_message(span_green("[user] finishes fastening [their_or_other] [limb.plaintext_zone]!"))
	remove_wound()

/datum/wound/blunt/robotic/severe
	name = "Detached Fastenings"
	desc = "Various fastening devices are extremely loose, and solder has disconnected at multiple points, causing significant jostling of internal components and \
			noticable limb dysfunction."
	treat_text = "Fastening of bolts and screws by a qualified technician (though bone gel may suffice in the absence of one), followed up by re-soldering."
	examine_desc = "jostles with every move, with visibly broken solder"
	occur_text = "visibly cracks open, solder flying everywhere"
	severity = WOUND_SEVERITY_SEVERE

	wound_flags = (ACCEPTS_GAUZE | MANGLES_BONE)
	treatable_by = list(/obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/robotic/severe
	treatable_tool = TOOL_WELDER

	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	limp_chance = 60
	threshold_minimum = 75
	threshold_penalty = 50

	drop_item_on_hit_minimum_damage = 8
	knockdown_on_hit_minimum_damage = 8

	daze_attacked_chance = 95
	daze_attacked_minimum_score = 6
	daze_attacked_shake_duration_mult = 0.2
	daze_attacked_shake_intensity_mult = 0.4

	daze_dizziness_maximum_duration = 400
	daze_dizzy_minimum_score = 3
	daze_dizzy_mult = 10

	daze_movement_shake_duration_mult = 0.2
	daze_movement_shake_intensity_mult = 0.05
	head_movement_daze_chance = 75

	chest_movement_nausea_chance = 8
	chest_attacked_nausea_chance = 50
	chest_attacked_nausea_mult = 0.4 // saw = 15, 1.5 seconds of disgust at x1

	chest_movement_organ_damage_chance = 2
	chest_movement_organ_damage_min = 2
	chest_movement_organ_damage_max = 7
	chest_movement_organ_damage_individual_max = 2

	chest_attacked_organ_damage_chance = 25
	chest_attacked_organ_damage_mult = 0.5

	a_or_from = "from"

	ready_to_secure_internals = TRUE
	ready_to_ghetto_weld = FALSE

/datum/wound/blunt/robotic/item_can_treat(obj/item/potential_treater)
	if (item.tool_behaviour == TOOL_WELDER || item.tool_behavior == TOOL_CAUTERY)
		if (!ready_to_ghetto_weld)
			return FALSE
		else
			return TRUE

	if (ready_to_secure_internals)
		if (item_can_secure_internals(potential_treater))
			return TRUE
		
	return ..()

/datum/wound/blunt/robotic/proc/item_can_secure_internals(obj/item/potential_treater)
	return (item.tool_behaviour == TOOL_SCREWDRIVER ||
		item.tool_behaviour == TOOL_WRENCH ||
		istype(item, /obj/item/stack/medical/bone_gel))

/datum/wound/blunt/robotic/treat(obj/item/item, mob/user)
	if (ready_to_secure_internals)
		if (istype(item, /obj/item/stack/medical/bone_gel))
			if (gellable)
				return gel(item, user)
			else
				var/victim_or_not = (victim ? "[victim]'s " : "")
				var/limb_text = (victim ? "[limb.plaintext_zone]" : "[limb]")
				to_chat(user, span_warning("[victim_or_not][limb_text] cannot be mended with [item]!"))
				return TRUE
		else if (item_can_secure_internals(potential_treater))
			return secure_internals_normally(potential_treater, user)
	else if (ready_to_ghetto_weld && (item.tool_behaviour == TOOL_WELDER) || (item.tool_behavior == TOOL_CAUTERY))
		return weld(item, user)

/datum/wound/blunt/robotic/proc/secure_internals_normally(obj/item/securing_item, user)
	if (!securing_item.tool_start_check())
		return TRUE

	var/chance = 5

	if (user == victim)
		chance *= 0.05

	var/has_robo_powers = HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES)

	var/delay_mult = 1
	if (has_robo_powers)
		chance *= 15
		delay_mult *= 0.5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 8
		delay_mult *= 0.85
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 5

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if (user)
		user.visible_message(span_notice("[user] begins the delicate operation of securing [their_or_other] [limb.planetext_zone]'s internals..."))
		to_chat(user, span_warning("You are confused by the layout of [their_or_other]'s [limb.planetext_zone]! Perhaps a roboticist, an engineer, or a diagnostic HUD would help?"))

	if (!securing_item.use_tool(target = victim, user = user, delay = (10 SECONDS * delay_mult), volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if (prob(chance))
		if (user)
			user.visible_message(span_green("[user] finishes securing the internals of [their_or_other] [limb.plaintext_zone]!"))
		to_chat(victim, span_green("Your [limb.plaintext_zone]'s internals are now secure! Your next step is to weld it."))
		ready_to_ghetto_weld = TRUE
	else
		if (user)
			user.visible_message(span_warning("[user] screws up and accidentally damages [their_or_other] [limb.plaintext_zone]!"))
		limb.receive_damage(brute = 1, damage_source = securing_item)

	return TRUE

/datum/wound/blunt/robotic/proc/gel(obj/item/stack/medical/bone_gel/gel, mob/user)
	if (gelled)
		to_chat(user, span_warning("[user == victim ? "Your" : "[victim]'s"] [limb.plaintext_zone] is already filled with bone gel!"))
		return TRUE

	user.visible_message(span_danger("[user] begins hastily applying [gel] to [victim]'s' [limb.plaintext_zone]..."), span_warning("You begin hastily applying [gel] to [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone], disregarding the bold \"ONLY USE WITH ORGANICS\" label..."))

	if (!do_after(user, base_treat_time * 2 * (user == victim ? 1.5 : 1), target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
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

/datum/wound/blunt/robotic/proc/weld(obj/item/welding_item, mob/user)
	if (!welding_item.tool_start_check())
		return TRUE

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	victim.visible_message(span_notice("[user] begins re-soldering [their_or_other] [limb.plaintext_zone]..."))

	var/delay_mult = 1
	if (welding_item.tool_behavior == TOOL_CAUTERY)
		delay_mult *= 3

	if (!welding_item.use_tool(target = victim, user = user, delay = 7 SECONDS * delay_mult, volume = 50,  extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	victim.visible_message(span_green("[user] finishes re-soldering [their_or_other] [limb.plaintext_zone]!"))
	limb.receive_damage(burn = 5, damage_source = src) // not a proper fix
	remove_wound()
	return TRUE

/datum/wound/blunt/robotic/modify_desc_before_span(desc)
	. = ..()

	if (!limb.current_gauze)
		if (gelled)
			. += ", [span_notice("with fizzling blue surgical gel holding them in place")]!"

/datum/wound/blunt/robotic/handle_process(seconds_per_tick, times_fired)
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
		set_disabling(FALSE)

/datum/wound/blunt/robotic/critical
	name = "Collapsed Superstructure"
	desc = "The superstructure has totally collapsed in one or more locations, causing extreme internal oscillation with every move and massive limb dysfunction"
	treat_text = "Reforming of superstructure via either RCD or manual molding, followed by typical treatment of loosened internals. \
				To manually mold, the limb must be aggressively grabbed and a welder held to it to make it malleable - and then, either a plunger or another \
				aggressive grab to mold the metal - though percussive maintenance may suffice as well."
	occur_text = "caves in on itself, damaged solder and shrapnel flying out in a miniature explosion"
	examine_desc = "looks caved in, with internal components visible through gaps in the metal"
	severity = WOUND_SEVERITY_CRITICAL

	damage_mulitplier_penalty = 1.2
	interaction_efficiency_penalty = 3
	limp_slowdown = 8
	limp_chance = 90
	threshold_minimum = 120
	threshold_penalty = 50

	status_effect_type = /datum/status_effect/wound/blunt/robotic/critical

	sound_effect = 'sound/effects/wounds/crack2.ogg'

	wound_flags = (ACCEPTS_GAUZE | MANGLES_BONE | MANGLES_FLESH)
	treatable_by = list(/obj/item/stack/medical/bone_gel)
	status_effect_type = /datum/status_effect/wound/blunt/robotic/severe
	treatable_tool = TOOL_WELDER

	drop_item_on_hit_minimum_damage = 8
	knockdown_on_hit_minimum_damage = 8

	daze_attacked_chance = 100
	daze_attacked_minimum_score = 1
	daze_attacked_shake_duration_mult = 1
	daze_attacked_shake_intensity_mult = 0.5

	daze_dizziness_maximum_duration = 80 SECONDS
	daze_dizzy_minimum_score = 1
	daze_dizzy_mult = 15

	daze_movement_shake_duration_mult = 1
	daze_movement_shake_intensity_mult = 0.2
	head_movement_daze_chance = 100

	chest_attacked_organ_damage_individual_max = 20
	/// The chance for the internal organs of our limb to be damaged when the limb is attacked.
	chest_attacked_organ_damage_chance = 100
	chest_attacked_organ_damage_mult = 0.5

	max_nausea_duration = 10 SECONDS

	chest_movement_nausea_chance = 12

	chest_attacked_nausea_chance = 75
	chest_attacked_nausea_mult = 0.6 // saw = 15, 1.5 seconds of disgust at x1
	chest_attacked_nausea_minimum_score = 4

	chest_movement_organ_damage_chance = 7
	chest_movement_organ_damage_min = 2
	chest_movement_organ_damage_max = 8
	chest_movement_organ_damage_individual_max = 4

	chest_attacked_organ_damage_chance = 25
	chest_attacked_organ_damage_mult = 0.5

	a_or_from = "a"

	percussive_maintenance_repair_chance = 15
	percussive_maintenance_damage_threshold = 6

	regen_time_needed = 60 SECONDS

	var/superstructure_remedied = FALSE
	ready_to_secure_internals = FALSE
	ready_to_ghetto_weld = FALSE

/datum/wound/blunt/robotic/critical/item_can_treat(obj/item/potential_treater)
	if (istype(potential_treater, /obj/item/construction/rcd))
		return TRUE
	if (!superstructure_remedied)
		if (istype(potential_treater, /obj/item/plunger) && !plunged)
			return TRUE
		else if (potential_treater.tool_behaviour == TOOL_WELDER && !limb_malleable())
			return TRUE
	return ..()

/datum/wound/blunt/robotic/critical/check_grab_treatments(obj/item/potential_treater, mob/user)
	if (potential_treater.tool_behaviour == TOOL_WELDER && (!superstructure_remedied && !limb_malleable()))
		return TRUE
	return ..()

/datum/wound/blunt/robotic/critical/treat(obj/item/item, mob/user)
	if (istype(item, /obj/item/construction/rcd))
		return rcd_superstructure(item, user)
	if (uses_percussive_maintenance())
		if (istype(item, /obj/item/plunger))
			return plunge(item, user)
	if (item.tool_behaviour == TOOL_WELDER && !superstructure_remedied && !limb_malleable())
		return heat_metal(item, user)
	return ..()

/datum/wound/blunt/robotic/critical/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone)
		return FALSE

	if (superstructure_remedied || !limb_malleable())
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, span_warning("You must have [victim] in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!"))
		return TRUE

	if(user.grab_state > GRAB_AGGRESSIVE)
		return TRUE

	user.visible_message(span_danger("[user] begins softly pressing against [victim]'s collapsed [limb.plaintext_zone]..."), span_notice("You begin softly pressing against [victim]'s collapsed [limb.plaintext_zone]..."), ignored_mobs=victim)
	to_chat(victim, span_userdanger("[user] begins softly pressing against your collapsed [limb.plaintext_zone]!"))

	if(!do_after(user, 8 SECONDS, target=victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return
	mold_metal(user, hostile)
	return TRUE

/datum/wound/blunt/robotic/critical/proc/mold_metal(mob/living/carbon/human/user)
	var/chance = 40

	var/has_robo_powers = HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES)

	if (has_robo_powers)
		chance *= 3
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 1.5

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if ((user != victim && user.combat_mode))
		user.visible_message(span_green("[user] molds [their_or_other] [limb.plaintext_zone] into a really silly shape! What a goofball!"))
		var/datum/wound/burn/robotic/moderate/warped_metal = new /datum/wound/burn/robotic/moderate
		melted_metal.apply_wound(src, wound_source = user)
	else if (prob(chance))
		user.visible_message(span_green("[user] carefully molds [their_or_other] [limb.plaintext_zone] into the proper shape!"))
		to_chat(victim, span_green("Your [limb.plaintext_zone] has been molded into the proper shape! Your next step is to use a screwdriver/wrench to secure your internals."))
		set_superstructure_status(TRUE)
	else
		user.visible_message(span_warning("[user] screws up, damaging [their_or_other] [limb.plaintext_zone] in their efforts to help!"))
		limb.receive_damage(brute = 5, damage_source = user)

	if (!(HAS_TRAIT(user, TRAIT_RESISTHEAT) || HAS_TRAIT(user, TRAIT_RESISTHEATHANDS)))
		to_chat(user, span_warning("You burn your hand on [victim]'s [limb.planetext_zone]!"))
		var/obj/item/bodypart/affecting = user.get_bodypart("[(user.active_hand_index % 2 == 0) ? "r" : "l" ]_arm")
		affecting?.receive_damage(burn = 5)
		
/datum/wound/blunt/robotic/critical/proc/heat_metal(obj/item/welder, mob/user)
	if (!welder.tool_use_check())
		return TRUE

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if (user)
		user.visible_message(span_notice("[user] carefully holds [welder] to [their_or_other] [limb.plaintext_zone], slowly heating it..."))

	if (!welder.use_tool(target = victim, user = user, delay = 10 SECONDS, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	var/datum/wound/burn/robotic/moderate/heated_metal = new /datum/wound/burn/robotic/moderate
	heated_metal.apply_wound(src, wound_source = welder)

	to_chat(victim, span_green("Your [limb.plaintext_zone] is now heated, allowing it to be molded! Your next step is to have someone physically reset the superstructure with their hands."))
	return TRUE

/datum/wound/blunt/robotic/critical/proc/rcd_superstructure(obj/item/construction/rcd/treating_rcd, mob/user)
	if (!treating_rcd.tool_use_check() || !treating_rcd.get_matter(user) < ROBOTIC_T3_BLUNT_WOUND_RCD_COST)
		return TRUE

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if (user)
		user.visible_message(span_notice("[treating_rcd] whirs to life as it begins replacing the damaged superstructure of [their_or_other] [limb.plaintext_zone]..."))

	if (!treating_rcd.use_tool(target = victim, user = user, delay = 15 SECONDS, volume = 50, amount = ROBOTIC_T3_BLUNT_WOUND_RCD_COST, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	var/chance = 100
	if (victim == user)
		chance *= 0.5

	var/has_robo_powers = HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES)

	if (has_robo_powers)
		chance *= 5
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 2
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 2

	if (prob(chance))
		if (user)
			user.visible_message(span_danger("[treating_rcd] lets out a small ping as it finishes replacing the superstructure of [victim]'s [limb.plaintext_zone]."))
		to_chat(victim, span_green("[treating_rcd] has finished replacing your [limb.plaintext_zone]'s superstructure! Your next step is to secure it with bone gel."))
		set_superstructure_status(TRUE)

	else 
		if (user)
			user.visible_message(span_warning("[user] screws up and accidentally damages more than they replaced with [treating_rcd]!"))
		limb.receive_damage(brute = 5, damage_source = treating_rcd)
	return TRUE

/datum/wound/blunt/robotic/critical/proc/plunge(obj/item/plunger/treating_plunger, mob/user)
	if (!treating_plunger.tool_use_check())
		return TRUE

	var/their_or_other = (user == victim ? "their" : "[user]'s")
	if (user)
		user.visible_message(span_notice("[user] starts plunging at the dents on [their_or_other] [limb.plaintext_zone]..."))

	var/chance = 50
	if (victim == user)
		chance *= 0.5

	var/has_robo_powers = HAS_TRAIT(user, TRAIT_KNOW_ROBO_WIRES)

	if (has_robo_powers)
		chance *= 1.25
	if (HAS_TRAIT(user, TRAIT_KNOW_ENGI_WIRES))
		chance *= 1.1
	if (HAS_TRAIT(user, TRAIT_DIAGNOSTIC_HUD))
		chance *= 1.25

	if (!treating_plunger.use_tool(target = victim, user = user, delay = 8 SECONDS, volume = 50, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return TRUE

	if (prob(chance))
		if (user)
			user.visible_message(span_green("[victim]'s [limb.plaintext_zone] lets out a sharp POP as the suction of [treating_plunger] forces the superstructure into it's normal position!"))
		to_chat(victim, span_green("Your [limb.plaintext_zone]'s structure has been reset to it's proper position! Your next step is to secure it with bone gel."))
		set_superstructure_status(TRUE)
	else 
		if (user)
			user.visible_message(span_warning("[victim]'s [limb.plaintext_zone] lets out a strained creak as [treating_plunger] rips some shrapnel out of the chassis!"))
		limb.receive_damage(brute = 5, damage_source = treating_plunger)
	return TRUE

/datum/wound/blunt/robotic/proc/limb_malleable()
	for (var/datum/wound/found_wound as anything in limb.wounds)
		if (found_wound.type == /datum/wound/burn/robotic/moderate) // meh solution but whateva
			return TRUE
	return FALSE

/datum/wound/blunt/robotic/critical/handle_percussive_maintenance_success(attacking_item)
	victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] gets smashed into a proper shape!"), \
		span_green("Your [limb.plaintext_zone] smashes into place! Your next step is to fill it with bone gel."))
	set_superstructure_status(TRUE)

/datum/wound/blunt/robotic/critical/handle_percussive_maintenance_failure(attacking_item)
	to_chat(victim, span_warning("Your [limb.plaintext_zone] only deforms more from the impact..."))
	limb.receive_damage(brute = 1, damage_source = src)

/datum/wound/blunt/robotic/critical/uses_percussive_maintenance()
	return (!superstructure_remedied && limb_malleable())

/datum/wound/blunt/robotic/proc/set_superstructure_status(remedied)
	superstructure_remedied = remedied
	gellable = remedied
	ready_to_secure_internals = remedied

/datum/wound/blunt/robotic/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	// hook into gaining/losing gauze so crit bone wounds can re-enable/disable depending if they're slung or not
	RegisterSignals(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED), PROC_REF(update_inefficiencies))
	update_inefficiencies()

/datum/wound/blunt/robotic/set_victim(new_victim)
	if (victim)
		UnregisterSignal(victim, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(victim, COMSIG_MOB_AFTER_APPLY_DAMAGE)
	if (new_victim)
		RegisterSignal(new_victim, COMSIG_MOVABLE_MOVED, PROC_REF(victim_moved))
		RegisterSignal(new_victim, COMSIG_MOB_AFTER_APPLY_DAMAGE, PROC_REF(victim_attacked))

	return ..()

/datum/wound/blunt/robotic/remove_wound(ignore_limb, replaced)
	UnregisterSignal(limb, COMSIG_BODYPART_GAUZED)
	UnregisterSignal(limb, COMSIG_BODYPART_GAUZE_DESTROYED)

	return ..()

/datum/wound/blunt/robotic/proc/victim_attacked(datum/source, damage, damagetype, def_zone, blocked, wound_bonus, bare_wound_bonus, sharpness, attack_direction, attacking_item)
	SIGNAL_HANDLER

	if (def_zone != limb.body_zone) // use this proc since receive damage can also be called for like, chems and shit
		return

	if(!victim)
		return

	var/effective_damage = (damage - blocked)
	if (!sharpness)
		effective_damage *= BLUNT_ATTACK_DAZE_MULT

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		effective_damage *= gauze.splint_factor

	switch (limb.body_zone) // TODO: test if this proc is called after wound_injury, we want these to happen on wound
		if (BODY_ZONE_HEAD)
			if (effective_damage < daze_attacked_minimum_score)
				return
			if (prob(daze_attacked_chance))
				daze(effective_damage, daze_attacked_shake_duration_mult, daze_attacked_shake_intensity_mult)

		if (BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			if (wounding_dmg > drop_item_on_hit_minimum_damage)
				try_dropping_item(effective_damage)

		if (BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			if (wounding_dmg > knockdown_on_hit_minimum_damage)
				try_falling_over(effective_damage)

		if (BODY_ZONE_CHEST)
			var/nausea = FALSE
			var/damage = FALSE
			if ((effective_damage >= chest_attacked_nausea_minimum_score) && prob(chest_attacked_nausea_chance))
				victim.adjust_disgust(effective_damage * chest_attacked_nausea_mult, max_nausea_duration)
				nausea = TRUE
			if ((effective_damage >= chest_attacked_organ_damage_minimum_score) && prob(chest_attacked_organ_damage_chance))
				attack_random_organs(total_damage = (effective_damage * chest_attacked_organ_damage_mult), chest_attacked_organ_damage_individual_max)
				damage = TRUE
			if (nausea || damage)
				var/from_or_nothing = (attacking_item ? " [attacking_item]'s" : "")
				var/painfully_or_not = (damage ? " painfully" : "")
				var/nausea_or_not = (nausea ? " a wave of nausea as" : "")
				to_chat(victim, span_warning("You feel[nausea_or_not] your [limb.plaintext_zone]'s internals jostle[painfully_or_not] from the[from_or_nothing] impact!"))

	/*if (wounding_dmg > WOUND_MINIMUM_DAMAGE)
		if (exposed_organ_attacked(wounding_type, wounding_dmg))
			attack_random_organs(total_damage = wounding_dmg)*/

	if (uses_percussive_maintenance() && (damage > 0)) // we use the threshold because generally speaking higher force attacks are trying to fuck you up
		if (damage <= percussive_maintenance_damage_threshold && (damagetype == BRUTE && !sharpness)) // anything above it wont try to repair it
			var/mob/living/user
			if (isatom(attacking_item))
				var/atom/attacking_atom = attacking_item
				user = attacking_atom.loc
			var/chance_mult = 1
			if (user)
				if (user == victim)
					chance_mult *= 0.25 // less likely for it to work if you hit yourself, so people can go up to people and go "please punch me"
				/*else if (attacking_item && user.combat_mode)
					chance_mult *= 0 // "sure bro", i say as i start beating the shit out of them with murderous intent
					*/
				// no way to do the above, lots of things require combat mode to hit people
			if (prob(percussive_maintenance_repair_chance * chance_mult))
				handle_percussive_maintenance_success(attacking_item)
			else
				handle_percussive_maintenance_failure(attacking_item)

/datum/wound/blunt/robotic/proc/handle_percussive_maintenance_success(attacking_item)
	victim.visible_message(span_green("[victim]'s [limb.plaintext_zone] rattles from the impact, but looks a lot more secure!"), \
		span_green("Your [limb.plaintext_zone] rattles into place!"))
	remove_wound()

/datum/wound/blunt/robotic/proc/handle_percussive_maintenance_failure(attacking_item)
	to_chat(victim, span_warning("Your [limb.plaintext_zone] rattles around, but you don't sense any sign of improvement."))

/datum/wound/blunt/robotic/proc/victim_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	var/overall_mult = 1

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		overall_mult *= gauze.splint_factor

	if (can_daze())
		var/daze_chance = head_movement_daze_chance
		daze_chance *= overall_mult
		if (!victim.has_gravity(get_turf(victim)))
			daze_chance *= 0.5
		else if (victim.body_position == LYING_DOWN || (!forced && victim.m_intent == MOVE_INTENT_WALK))
			daze_chance *= 0.25

		if (prob(daze_chance))
			var/daze_mult = rand(1, 1.2)
			daze(daze_movement_base_score * daze_mult, daze_movement_shake_duration_mult, daze_movement_shake_intensity_mult)

	if (limb.body_zone == BODY_ZONE_CHEST)
		if (prob(chest_movement_nausea_chance))
			shake_organs_for_nausea(chest_movement_base_nausea_score * overall_mult, max_nausea_duration)

		if (prob(chest_movement_organ_damage_chance))
			attack_random_organs(get_chest_movement_organ_damage() * overall_mult, chest_movement_organ_damage_individual_max)

/datum/wound/blunt/robotic/proc/shake_organs_for_nausea(score, max)
	victim.adjust_disgust(score, max)
	to_chat(victim, span_warning("You feel a wave of nausea as your [limb.plaintext_zone]'s internals jostle..."))

/datum/wound/blunt/robotic/proc/get_chest_movement_organ_damage()
	return rand(chest_movement_organ_damage_min, chest_movement_organ_damage_max)

/datum/wound/blunt/robotic/proc/can_daze()
	return (limb.body_zone == BODY_ZONE_HEAD)

/*/datum/wound/blunt/robotic/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction)
	if(!victim)
		return

	var/effective_damage = wounding_dmg
	if (wounding_type == WOUND_BLUNT)
		effective_damage *= BLUNT_ATTACK_DAZE_MULT

	var/obj/item/stack/gauze = limb.current_gauze
	if (gauze)
		effective_damage *= gauze.splint_factor

	switch (limb.body_zone) // TODO: test if this proc is called after wound_injury, we want these to happen on wound
		if (BODY_ZONE_HEAD)
			// ...

		if (BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)
			if (wounding_dmg > drop_item_on_hit_minimum_damage)
				try_dropping_item(effective_damage)

		if (BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
			if (wounding_dmg > knockdown_on_hit_minimum_damage)
				try_falling_over(effective_damage)

		if (BODY_ZONE_CHEST)
			if ((effective_damage >= chest_attacked_nausea_minimum_score) && prob(chest_attacked_nausea_chance))
				shake_organs_for_nausea((effective_damage * chest_attacked_nausea_mult), max_nausea_duration)

	if (wounding_dmg > WOUND_MINIMUM_DAMAGE)
		if (exposed_organ_attacked(wounding_type, wounding_dmg))
			attack_random_organs(total_damage = wounding_dmg)
*/

/datum/wound/blunt/robotic/proc/attack_random_organs(total_damage, max_damage_per_organ)
	var/list/obj/item/organ/picked_organs = assign_damage_to_organs(total_damage, max_damage_per_organ)
	for (var/obj/item/organ/organ as anything in picked_organs)
		organ.apply_organ_damage(picked_organs[organ])
	to_chat(victim, span_warning("You feel your [limb.plaintext_zone]'s internals jostle painfully!"))

/datum/wound/blunt/robotic/proc/assign_damage_to_organs(wounding_dmg, max_damage_per_organ)
	var/obj/item/organ/picked_organs = list()
	var/remaining_damage_distribution = wounding_dmg

	for (var/obj/item/organ/organ as anything in shuffle(limb.get_organs()))
		picked_organs[organ] = min(remaining_damage_distribution, max_damage_per_organ)
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

/datum/wound/blunt/robotic/proc/daze(daze_amount, shake_duration_mult, shake_intensity_mult)
	shake_camera(victim, duration = (daze_amount * shake_duration_mult), strength = (daze_amount * shake_intensity_mult))
	victim.adjust_dizzy_up_to(daze_amount * daze_dizzy_mult, daze_dizziness_maximum_duration)

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
			span_warning("<b>Your [limb.plaintext_zone] shakes from the impact, causing you to drop [held_item]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)

/datum/wound/blunt/robotic/proc/try_falling_over(score)
	var/fall_chance = min((score * knockdown_on_hit_chance_mult), 100)
	if (prob(fall_chance))
		victim.Knockdown(knockdown_on_hit_time)
		if (victim.incapacitated(IGNORE_RESTRAINTS|IGNORE_GRAB)) // So the message isn't duplicated. If they were stunned beforehand by something else, then the message not showing makes more sense anyways.
			return
		to_chat(victim, span_warning("The blow to your [limb.plaintext_zone] sends you to the ground!"))

/datum/wound/blunt/robotic/proc/update_inefficiencies(datum/source)
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

#undef BLUNT_ATTACK_DAZE_MULT
