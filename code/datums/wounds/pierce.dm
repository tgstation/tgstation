
/*
	Piercing wounds
*/

/datum/wound/pierce
	name = "Piercing Wound"
	sound_effect = 'sound/weapons/slice.ogg'
	processes = TRUE
	wound_type = WOUND_PIERCE
	treatable_by = list(/obj/item/stack/medical/suture)
	treatable_tool = TOOL_CAUTERY
	base_treat_time = 3 SECONDS
	wound_flags = (FLESH_WOUND | ACCEPTS_GAUZE)

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// If gauzed, what percent of the internal bleeding actually clots of the total absorption rate
	var/gauzed_clot_rate

	/// When hit on this bodypart, we have this chance of losing some blood + the incoming damage
	var/internal_bleeding_chance
	/// If we let off blood when hit, the max blood lost is this * the incoming damage
	var/internal_bleeding_coefficient

/datum/wound/pierce/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	set_blood_flow(initial_flow)
	if(!no_bleeding && attack_direction && victim.blood_volume > BLOOD_VOLUME_OKAY)
		victim.spray_blood(attack_direction, severity)

/datum/wound/pierce/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(victim.stat == DEAD || (wounding_dmg < 5) || no_bleeding || !victim.blood_volume || !prob(internal_bleeding_chance + wounding_dmg))
		return
	if(limb.current_gauze?.splint_factor)
		wounding_dmg *= (1 - limb.current_gauze.splint_factor)
	var/blood_bled = rand(1, wounding_dmg * internal_bleeding_coefficient) // 12 brute toolbox can cause up to 15/18/21 bloodloss on mod/sev/crit
	switch(blood_bled)
		if(1 to 6)
			victim.bleed(blood_bled, TRUE)
		if(7 to 13)
			victim.visible_message("<span class='smalldanger'>Blood droplets fly from the hole in [victim]'s [limb.plaintext_zone].</span>", span_danger("You cough up a bit of blood from the blow to your [limb.plaintext_zone]."), vision_distance=COMBAT_MESSAGE_RANGE)
			victim.bleed(blood_bled, TRUE)
		if(14 to 19)
			victim.visible_message("<span class='smalldanger'>A small stream of blood spurts from the hole in [victim]'s [limb.plaintext_zone]!</span>", span_danger("You spit out a string of blood from the blow to your [limb.plaintext_zone]!"), vision_distance=COMBAT_MESSAGE_RANGE)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(victim.loc, victim.dir)
			victim.bleed(blood_bled)
		if(20 to INFINITY)
			victim.visible_message(span_danger("A spray of blood streams from the gash in [victim]'s [limb.plaintext_zone]!"), span_danger("<b>You choke up on a spray of blood from the blow to your [limb.plaintext_zone]!</b>"), vision_distance=COMBAT_MESSAGE_RANGE)
			victim.bleed(blood_bled)
			new /obj/effect/temp_visual/dir_setting/bloodsplatter(victim.loc, victim.dir)
			victim.add_splatter_floor(get_step(victim.loc, victim.dir))

/datum/wound/pierce/get_bleed_rate_of_change()
	//basically if a species doesn't bleed, the wound is stagnant and will not heal on it's own (nor get worse)
	if(no_bleeding)
		return BLOOD_FLOW_STEADY
	if(HAS_TRAIT(victim, TRAIT_BLOODY_MESS))
		return BLOOD_FLOW_INCREASING
	if(limb.current_gauze)
		return BLOOD_FLOW_DECREASING
	return BLOOD_FLOW_STEADY

/datum/wound/pierce/handle_process(seconds_per_tick, times_fired)
	set_blood_flow(min(blood_flow, WOUND_SLASH_MAX_BLOODFLOW))

	if(!no_bleeding)
		if(victim.bodytemperature < (BODYTEMP_NORMAL - 10))
			adjust_blood_flow(-0.1 * seconds_per_tick)
			if(SPT_PROB(2.5, seconds_per_tick))
				to_chat(victim, span_notice("You feel the [lowertext(name)] in your [limb.plaintext_zone] firming up from the cold!"))

		if(HAS_TRAIT(victim, TRAIT_BLOODY_MESS))
			adjust_blood_flow(0.25 * seconds_per_tick) // old heparin used to just add +2 bleed stacks per tick, this adds 0.5 bleed flow to all open cuts which is probably even stronger as long as you can cut them first

	if(limb.current_gauze)
		adjust_blood_flow(-limb.current_gauze.absorption_rate * gauzed_clot_rate * seconds_per_tick)
		limb.current_gauze.absorption_capacity -= limb.current_gauze.absorption_rate * seconds_per_tick

	if(blood_flow <= 0)
		qdel(src)

/datum/wound/pierce/on_stasis(seconds_per_tick, times_fired)
	. = ..()
	if(blood_flow <= 0)
		qdel(src)

/datum/wound/pierce/check_grab_treatments(obj/item/I, mob/user)
	if(I.get_temperature()) // if we're using something hot but not a cautery, we need to be aggro grabbing them first, so we don't try treating someone we're eswording
		return TRUE

/datum/wound/pierce/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/suture))
		suture(I, user)
	else if(I.tool_behaviour == TOOL_CAUTERY || I.get_temperature())
		tool_cauterize(I, user)

/datum/wound/pierce/on_xadone(power)
	. = ..()
	adjust_blood_flow(-0.03 * power) // i think it's like a minimum of 3 power, so .09 blood_flow reduction per tick is pretty good for 0 effort

/datum/wound/pierce/on_synthflesh(power)
	. = ..()
	adjust_blood_flow(-0.025 * power) // 20u * 0.05 = -1 blood flow, less than with slashes but still good considering smaller bleed rates

/// If someone is using a suture to close this puncture
/datum/wound/pierce/proc/suture(obj/item/stack/medical/suture/I, mob/user)
	var/self_penalty_mult = (user == victim ? 1.4 : 1)
	var/treatment_delay = base_treat_time * self_penalty_mult

	if(HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		treatment_delay *= 0.5
		user.visible_message(span_notice("[user] begins expertly stitching [victim]'s [limb.plaintext_zone] with [I]..."), span_notice("You begin stitching [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone] with [I], keeping the holo-image information in mind..."))
	else
		user.visible_message(span_notice("[user] begins stitching [victim]'s [limb.plaintext_zone] with [I]..."), span_notice("You begin stitching [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone] with [I]..."))

	if(!do_after(user, treatment_delay, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return
	var/bleeding_wording = (no_bleeding ? "holes" : "bleeding")
	user.visible_message(span_green("[user] stitches up some of the [bleeding_wording] on [victim]."), span_green("You stitch up some of the [bleeding_wording] on [user == victim ? "yourself" : "[victim]"]."))
	var/blood_sutured = I.stop_bleeding / self_penalty_mult
	adjust_blood_flow(-blood_sutured)
	limb.heal_damage(I.heal_brute, I.heal_burn)
	I.use(1)

	if(blood_flow > 0)
		try_treating(I, user)
	else
		to_chat(user, span_green("You successfully close the hole in [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone]."))

/// If someone is using either a cautery tool or something with heat to cauterize this pierce
/datum/wound/pierce/proc/tool_cauterize(obj/item/I, mob/user)

	var/improv_penalty_mult = (I.tool_behaviour == TOOL_CAUTERY ? 1 : 1.25) // 25% longer and less effective if you don't use a real cautery
	var/self_penalty_mult = (user == victim ? 1.5 : 1) // 50% longer and less effective if you do it to yourself

	var/treatment_delay = base_treat_time * self_penalty_mult * improv_penalty_mult

	if(HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		treatment_delay *= 0.5
		user.visible_message(span_danger("[user] begins expertly cauterizing [victim]'s [limb.plaintext_zone] with [I]..."), span_warning("You begin cauterizing [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone] with [I], keeping the holo-image indications in mind..."))
	else
		user.visible_message(span_danger("[user] begins cauterizing [victim]'s [limb.plaintext_zone] with [I]..."), span_warning("You begin cauterizing [user == victim ? "your" : "[victim]'s"] [limb.plaintext_zone] with [I]..."))

	if(!do_after(user, treatment_delay, target = victim, extra_checks = CALLBACK(src, PROC_REF(still_exists))))
		return

	var/bleeding_wording = (no_bleeding ? "holes" : "bleeding")
	user.visible_message(span_green("[user] cauterizes some of the [bleeding_wording] on [victim]."), span_green("You cauterize some of the [bleeding_wording] on [victim]."))
	limb.receive_damage(burn = 2 + severity, wound_bonus = CANT_WOUND)
	if(prob(30))
		victim.emote("scream")
	var/blood_cauterized = (0.6 / (self_penalty_mult * improv_penalty_mult))
	adjust_blood_flow(-blood_cauterized)

	if(blood_flow > 0)
		try_treating(I, user)

/datum/wound/pierce/moderate
	name = "Minor Skin Breakage"
	desc = "Patient's skin has been broken open, causing severe bruising and minor internal bleeding in affected area."
	treat_text = "Treat affected site with bandaging or exposure to extreme cold. In dire cases, brief exposure to vacuum may suffice." // space is cold in ss13, so it's like an ice pack!
	examine_desc = "has a small, circular hole, gently bleeding"
	occur_text = "spurts out a thin stream of blood"
	sound_effect = 'sound/effects/wounds/pierce1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 1.5
	gauzed_clot_rate = 0.8
	internal_bleeding_chance = 30
	internal_bleeding_coefficient = 1.25
	threshold_minimum = 30
	threshold_penalty = 20
	status_effect_type = /datum/status_effect/wound/pierce/moderate
	scar_keyword = "piercemoderate"

/datum/wound/pierce/moderate/update_descriptions()
	if(no_bleeding)
		examine_desc = "has a small, circular hole"
		occur_text = "splits a small hole open"

/datum/wound/pierce/severe
	name = "Open Puncture"
	desc = "Patient's internal tissue is penetrated, causing sizeable internal bleeding and reduced limb stability."
	treat_text = "Repair punctures in skin by suture or cautery, extreme cold may also work."
	examine_desc = "is pierced clear through, with bits of tissue obscuring the open hole"
	occur_text = "looses a violent spray of blood, revealing a pierced wound"
	sound_effect = 'sound/effects/wounds/pierce2.ogg'
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 2.25
	gauzed_clot_rate = 0.6
	internal_bleeding_chance = 60
	internal_bleeding_coefficient = 1.5
	threshold_minimum = 50
	threshold_penalty = 35
	status_effect_type = /datum/status_effect/wound/pierce/severe
	scar_keyword = "piercesevere"

/datum/wound/pierce/severe/update_descriptions()
	if(no_bleeding)
		occur_text = "tears a hole open"

/datum/wound/pierce/critical
	name = "Ruptured Cavity"
	desc = "Patient's internal tissue and circulatory system is shredded, causing significant internal bleeding and damage to internal organs."
	treat_text = "Surgical repair of puncture wound, followed by supervised resanguination."
	examine_desc = "is ripped clear through, barely held together by exposed bone"
	occur_text = "blasts apart, sending chunks of viscera flying in all directions"
	sound_effect = 'sound/effects/wounds/pierce3.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 3
	gauzed_clot_rate = 0.4
	internal_bleeding_chance = 80
	internal_bleeding_coefficient = 1.75
	threshold_minimum = 100
	threshold_penalty = 50
	status_effect_type = /datum/status_effect/wound/pierce/critical
	scar_keyword = "piercecritical"
	wound_flags = (FLESH_WOUND | ACCEPTS_GAUZE | MANGLES_FLESH)
