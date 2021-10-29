
/*
	Muscle wounds. There is a chance to roll a muscle wound instead of others while doing brute damage
*/

/datum/wound/muscle
	name = "Muscle Wound"
	sound_effect = 'sound/effects/wounds/blood1.ogg'
	wound_type = WOUND_MUSCLE
	wound_flags = (FLESH_WOUND | ACCEPTS_SPLINT)
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	processes = TRUE
	/// How much do we need to regen. Will regen faster if we're splinted and or laying down
	var/regen_ticks_needed
	/// Our current counter for healing
	var/regen_ticks_current = 0

/*
	Overwriting of base procs
*/
/datum/wound/muscle/wound_injury(datum/wound/old_wound = null)
	// hook into gaining/losing gauze so crit muscle wounds can re-enable/disable depending if they're slung or not
	RegisterSignal(limb, list(COMSIG_BODYPART_SPLINTED, COMSIG_BODYPART_SPLINT_DESTROYED), .proc/update_inefficiencies)

	RegisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/attack_with_hurt_hand)
	if(limb.held_index && victim.get_item_for_held_index(limb.held_index) && (disabling || prob(30 * severity)))
		var/obj/item/I = victim.get_item_for_held_index(limb.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message("<span class='danger'>[victim] drops [I] in shock!</span>", "<span class='warning'><b>The force on your [limb.name] causes you to drop [I]!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()

/datum/wound/muscle/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	if(limb)
		UnregisterSignal(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_GAUZE_DESTROYED))
	if(victim)
		UnregisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	return ..()

/datum/wound/muscle/handle_process()
	. = ..()

	regen_ticks_current++
	if(victim.body_position == LYING_DOWN)
		if(prob(50))
			regen_ticks_current += 0.5
		if(victim.IsSleeping())
			regen_ticks_current += 0.5

	if(limb.current_splint)
		regen_ticks_current += (1-limb.current_splint.splint_factor)

	if(regen_ticks_current > regen_ticks_needed)
		if(!victim || !limb)
			qdel(src)
			return
		to_chat(victim, "<span class='green'>Your [limb.name] has regenerated its muscle!</span>")
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
			to_chat(victim, "<span class='userdanger'>The damaged muscle in your [limb.name] shoots with pain as you strike [target]!</span>")
			limb.receive_damage(brute=rand(1,5))
		else
			victim.visible_message("<span class='danger'>[victim] weakly strikes [target] with [victim.p_their()] swollen [limb.name], recoiling from pain!</span>", \
			"<span class='userdanger'>You fail to strike [target] as the fracture in your [limb.name] lights up in unbearable pain!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			INVOKE_ASYNC(victim, /mob.proc/emote, "scream")
			victim.Stun(0.5 SECONDS)
			limb.receive_damage(brute=rand(3,7))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/wound/muscle/get_examine_description(mob/user)
	if(!limb.current_splint)
		return ..()

	var/list/msg = list()
	if(!limb.current_splint)
		msg += "[victim.p_their(TRUE)] [limb.name] [examine_desc]"
	else
		var/sling_condition = ""
		// how much life we have left in these bandages
		switch(limb.current_splint.sling_condition)
			if(0 to 1.25)
				sling_condition = "just barely"
			if(1.25 to 2.75)
				sling_condition = "loosely"
			if(2.75 to 4)
				sling_condition = "mostly"
			if(4 to INFINITY)
				sling_condition = "tightly"

		msg += "[victim.p_their(TRUE)] [limb.name] is [sling_condition] fastened with a [limb.current_splint.name]!"

	return "<B>[msg.Join()]</B>"

/*
	Common procs mostly copied from bone wounds, as their behaviour is very similar
*/

/datum/wound/muscle/proc/update_inefficiencies()
	SIGNAL_HANDLER
	if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(limb.current_splint)
			limp_slowdown = initial(limp_slowdown) * limb.current_splint.splint_factor
		else
			limp_slowdown = initial(limp_slowdown)
		victim.apply_status_effect(STATUS_EFFECT_LIMP)
	else if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(limb.current_splint)
			interaction_efficiency_penalty = 1 + ((interaction_efficiency_penalty - 1) * limb.current_splint.splint_factor)
		else
			interaction_efficiency_penalty = interaction_efficiency_penalty

	if(initial(disabling))
		if(limb.current_splint && limb.current_splint.helps_disabled)
			set_disabling(FALSE)
		else
			set_disabling(TRUE)

	limb.update_wounds()

/// Moderate (Muscle Tear)
/datum/wound/muscle/moderate
	name = "Muscle Tear"
	desc = "Patient's muscle has torn, causing serious pain and reduced limb functionality."
	treat_text = "Recommended rest and sleep, or splinting the limb."
	examine_desc = "appears unnaturallly red and swollen"
	occur_text = "swells up, it's skin turning red"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 2
	threshold_minimum = 35
	threshold_penalty = 15
	status_effect_type = /datum/status_effect/wound/muscle/moderate
	regen_ticks_needed = 90

/*
	Severe (Ruptured Tendon)
*/

/datum/wound/muscle/severe
	name = "Ruptured Tendon"
	sound_effect = 'sound/effects/wounds/blood2.ogg'
	desc = "Patient's tendon has been severed, causing significant pain and near uselessness of limb."
	treat_text = "Recommended rest and sleep aswell as splinting the limb."
	examine_desc = "is limp and awkwardly twitching, skin swollen and red"
	occur_text = "twists in pain and goes limp, it's tendon ruptured"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 5
	threshold_minimum = 80
	threshold_penalty = 35
	disabling = TRUE
	status_effect_type = /datum/status_effect/wound/muscle/severe
	regen_ticks_needed = 150

/datum/status_effect/wound/muscle

/datum/status_effect/wound/muscle/on_apply()
	. = ..()
	RegisterSignal(owner, COMSIG_MOB_SWAP_HANDS, .proc/on_swap_hands)
	on_swap_hands()

/datum/status_effect/wound/muscle/on_remove()
	. = ..()
	UnregisterSignal(owner, COMSIG_MOB_SWAP_HANDS)
	var/mob/living/carbon/wound_owner = owner
	wound_owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/muscle_wound)

/datum/status_effect/wound/muscle/proc/on_swap_hands()
	SIGNAL_HANDLER

	var/mob/living/carbon/wound_owner = owner
	if(wound_owner.get_active_hand() == linked_limb)
		wound_owner.add_actionspeed_modifier(/datum/actionspeed_modifier/muscle_wound, (linked_wound.interaction_efficiency_penalty - 1))
	else
		wound_owner.remove_actionspeed_modifier(/datum/actionspeed_modifier/muscle_wound)

/datum/status_effect/wound/muscle/nextmove_modifier()
	var/mob/living/carbon/C = owner

	if(C.get_active_hand() == linked_limb)
		return linked_wound.interaction_efficiency_penalty

	return 1

// muscle
/datum/status_effect/wound/muscle/moderate
	id = "torn muscle"
/datum/status_effect/wound/muscle/severe
	id = "ruptured tendon"

/datum/actionspeed_modifier/muscle_wound
	variable = TRUE
