
/*
	Muscle wounds. There is a chance to roll a muscle wound instead of others while doing brute damage
*/

/datum/wound/muscle
	name = "Muscle Wound"
	sound_effect = 'sound/effects/wounds/blood1.ogg'
	wound_flags = (ACCEPTS_GAUZE | SPLINT_OVERLAY)

	processes = TRUE
	/// How much do we need to regen. Will regen faster if we're splinted and or laying down
	var/regen_ticks_needed
	/// Our current counter for healing
	var/regen_ticks_current = 0

	can_scar = FALSE

/datum/wound_pregen_data/muscle
	abstract = TRUE

	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	required_limb_biostate = BIO_FLESH

	required_wounding_types = list(WOUND_BLUNT, WOUND_SLASH, WOUND_PIERCE)
	match_all_wounding_types = FALSE

	wound_series = WOUND_SERIES_MUSCLE_DAMAGE

	weight = 3 // very low chance to replace a normal wound. this is about 4.5%

/*
	Overwriting of base procs
*/
/datum/wound/muscle/wound_injury(datum/wound/old_wound = null, attack_direction)
	var/obj/item/held_item = victim.get_item_for_held_index(limb.held_index || 0)
	if(held_item && (disabling || prob(30 * severity)))
		if(istype(held_item, /obj/item/offhand))
			held_item = victim.get_inactive_held_item()

		if(held_item && victim.dropItemToGround(held_item))
			victim.visible_message(span_danger("[victim] drops [held_item] in shock!"), \
			span_warning("<b>The force on your [parse_zone(limb.body_zone)] causes you to drop [held_item]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)

	return ..()

/datum/wound/muscle/set_victim(new_victim)
	if (victim)
		UnregisterSignal(victim, COMSIG_LIVING_EARLY_UNARMED_ATTACK)

	if (new_victim)
		RegisterSignal(new_victim, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(attack_with_hurt_hand))

	return ..()

/datum/wound/muscle/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	return ..()

/datum/wound/muscle/handle_process()
	. = ..()

	regen_ticks_current++
	if(victim.body_position == LYING_DOWN)
		if(prob(50))
			regen_ticks_current += 0.5
		if(victim.IsSleeping())
			regen_ticks_current += 0.5

	if(limb.current_gauze)
		regen_ticks_current += (1-limb.current_gauze.splint_factor)

	if(regen_ticks_current > regen_ticks_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, span_green("Your [parse_zone(limb.body_zone)] has regenerated its muscle!"))
		remove_wound()

/// If we're a human who's punching something with a broken arm, we might hurt ourselves doing so
/datum/wound/muscle/proc/attack_with_hurt_hand(mob/M, atom/target, proximity)
	SIGNAL_HANDLER

	if(victim.get_active_hand() != limb || !victim.combat_mode || !ismob(target) || severity <= WOUND_SEVERITY_MODERATE)
		return

	// 15% of 30% chance to proc pain on hit
	if(prob(severity * 15))
		// And you have a 70% or 50% chance to actually land the blow, respectively
		if(prob(70 - 20 * severity))
			to_chat(victim, span_userdanger("The damaged muscle in your [parse_zone(limb.body_zone)] shoots with pain as you strike [target]!"))
			limb.receive_damage(brute=rand(1,5))
		else
			victim.visible_message(span_danger("[victim] weakly strikes [target] with [victim.p_their()] swollen [parse_zone(limb.body_zone)], recoiling from pain!"), \
			span_userdanger("You fail to strike [target] as the fracture in your [parse_zone(limb.body_zone)] lights up in unbearable pain!"), vision_distance=COMBAT_MESSAGE_RANGE)
			INVOKE_ASYNC(victim, TYPE_PROC_REF(/mob, emote), "scream")
			victim.Stun(0.5 SECONDS)
			limb.receive_damage(brute=rand(3,7))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/wound/muscle/get_examine_description(mob/user)
	if(!limb.current_gauze)
		return ..()

	var/list/msg = list()
	if(!limb.current_gauze)
		msg += "[victim.p_Their()] [parse_zone(limb.body_zone)] [examine_desc]"
	else
		var/absorption_capacity = ""
		// how much life we have left in these bandages
		switch(limb.current_gauze.absorption_capacity)
			if(0 to 1.25)
				absorption_capacity = "just barely"
			if(1.25 to 2.75)
				absorption_capacity = "loosely"
			if(2.75 to 4)
				absorption_capacity = "mostly"
			if(4 to INFINITY)
				absorption_capacity = "tightly"

		msg += "[victim.p_Their()] [parse_zone(limb.body_zone)] is [absorption_capacity] fastened with a [limb.current_gauze.name]!"

	return "<B>[msg.Join()]</B>"

/// Moderate (Muscle Tear)
/datum/wound/muscle/moderate
	name = "Muscle Tear"
	desc = "Patient's muscle has torn, causing serious pain and reduced limb functionality."
	treat_text = "A tight splint on the affected limb, as well as plenty of rest and sleep."
	examine_desc = "appears unnaturallly red and swollen"
	occur_text = "swells up, its skin turning red"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 2
	limp_chance = 30
	threshold_penalty = 15
	status_effect_type = /datum/status_effect/wound/muscle/moderate
	regen_ticks_needed = 90

/datum/wound_pregen_data/muscle/tear
	abstract = FALSE

	wound_path_to_generate = /datum/wound/muscle/moderate
	threshold_minimum = 35

/*
	Severe (Ruptured Tendon)
*/

/datum/wound/muscle/severe
	name = "Ruptured Tendon"
	sound_effect = 'sound/effects/wounds/blood2.ogg'
	desc = "Patient's tendon has been severed, causing significant pain and near uselessness of limb."
	treat_text = "A tight splint on the affected limb, as well as plenty of rest and sleep."
	examine_desc = "is limp and awkwardly twitching, skin swollen and red"
	occur_text = "twists in pain and goes limp, its tendon ruptured"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 5
	limp_chance = 40
	threshold_penalty = 35
	disabling = TRUE
	status_effect_type = /datum/status_effect/wound/muscle/severe
	regen_ticks_needed = 150

/datum/wound_pregen_data/muscle/tendon
	abstract = FALSE

	wound_path_to_generate = /datum/wound/muscle/severe
	threshold_minimum = 80

// muscle
/datum/status_effect/wound/muscle/moderate
	id = "torn muscle"
/datum/status_effect/wound/muscle/severe
	id = "ruptured tendon"

/datum/status_effect/wound/muscle/robotic/moderate
	id = "worn servo"

/datum/status_effect/wound/muscle/robotic/severe
	id = "severed hydraulic"
