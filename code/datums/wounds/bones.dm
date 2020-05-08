
/*
	Bones
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons

/*
	Base definition
*/
/datum/wound/brute/bone
	sound_effect = 'sound/effects/crack1.ogg'
	wound_type = WOUND_TYPE_BONE

	/// The item we're currently splinted with, if there is one
	var/obj/item/stack/splinted

/*
	Overwriting of base procs
*/
/datum/wound/brute/bone/apply_wound(obj/item/bodypart/L, silent=FALSE, datum/wound/old_wound = null)
	. = ..()
	if(QDELETED(src) || !limb)
		return
	RegisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/attack_with_hurt_hand)
	if(L.held_index && victim.get_item_for_held_index(L.held_index) && (disabling || prob(30 * severity)))
		var/obj/item/I = victim.get_item_for_held_index(L.held_index)
		if(istype(I, /obj/item/offhand))
			I = victim.get_inactive_held_item()

		if(I && victim.dropItemToGround(I))
			victim.visible_message("<span class='danger'>[victim] drops [I] in shock!</span>", "<span class='warning'><b>The force on your [L.name] causes you to drop [I]!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()

/datum/wound/brute/bone/remove_wound(ignore_limb, replaced)
	limp_slowdown = 0
	if(limb)
		REMOVE_TRAIT(limb, TRAIT_LIMB_DISABLED_WOUND, src)
	if(victim)
		UnregisterSignal(victim, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	return ..()

// note this is only for humans since they alone have COMSIG_HUMAN_EARLY_UNARMED_ATTACK (obviously)
/datum/wound/brute/bone/proc/attack_with_hurt_hand(mob/M, atom/target, proximity)
	if(victim.get_active_hand() != limb || victim.a_intent == INTENT_HELP || !ismob(target) || severity <= WOUND_SEVERITY_MODERATE)
		return

	// With a severe or critical wound, you have a 15% or 30% chance to proc pain on hit
	if(prob((severity - 1) * 15))
		// And you have a 70% or 50% chance to actually land the blow, respectively
		if(prob(70 - 20 * (severity - 1)))
			to_chat(victim, "<span class='userdanger'>The fracture in your [limb.name] shoots with pain as you strike [target]!</span>")
			limb.receive_damage(brute=rand(1,5))
		else
			victim.visible_message("<span class='danger'>[victim] weakly strikes [target] with [victim.p_their()] broken [limb.name], recoiling from pain!</span>", \
			"<span class='userdanger'>You fail to strike [target] as the fracture in your [limb.name] lights up in unbearable pain!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			victim.emote("scream")
			victim.Stun(0.5 SECONDS)
			limb.receive_damage(brute=rand(3,7))
			return COMPONENT_NO_ATTACK_HAND

/datum/wound/brute/bone/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(!(wounding_type in list(WOUND_SHARP, WOUND_BURN)) || !splinted || !victim || wound_bonus == CANT_WOUND)
		return

	splinted.take_damage(wounding_dmg, damage_type = (wounding_type == WOUND_SHARP ? BRUTE : BURN), sound_effect = FALSE)
	if(QDELETED(splinted))
		var/destroyed_verb = (wounding_type == WOUND_SHARP ? "torn" : "burned")
		victim.visible_message("<span class='danger'>The splint securing [victim]'s [limb.name] is [destroyed_verb] away!</span>", "<span class='danger'><b>The splint securing your [limb.name] is [destroyed_verb] away!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)
		splinted = null
		treat_priority = TRUE
		update_inefficiencies()


/datum/wound/brute/bone/get_examine_description(mob/user)
	if(!splinted)
		return ..()

	var/splint_condition = ""
	// how much life we have left in these bandages
	switch(splinted.obj_integrity / splinted.max_integrity * 100)
		if(0 to 25)
			splint_condition = "just barely "
		if(25 to 50)
			splint_condition = "loosely "
		if(50 to 75)
			splint_condition = "mostly "
		if(75 to INFINITY)
			splint_condition = "tightly "
	return "<B>[victim.p_their(TRUE)] [limb.name] is [splint_condition] fastened in a splint of [splinted.name]!</B>"

/*
	New common procs for /datum/wound/brute/bone/
*/

/datum/wound/brute/bone/proc/update_inefficiencies()
	if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(splinted)
			limp_slowdown = initial(limp_slowdown) * splinted.splint_factor
		else
			limp_slowdown = initial(limp_slowdown)
		victim.apply_status_effect(STATUS_EFFECT_LIMP)
	else if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(splinted)
			interaction_efficiency_penalty = 1 + ((interaction_efficiency_penalty - 1) * splinted.splint_factor)
		else
			interaction_efficiency_penalty = interaction_efficiency_penalty

	if(initial(disabling) && splinted)
		disabling = FALSE
		REMOVE_TRAIT(limb, TRAIT_LIMB_DISABLED_WOUND, src)
	else if(initial(disabling))
		ADD_TRAIT(limb, TRAIT_LIMB_DISABLED_WOUND, src)
		disabling = TRUE

	limb.update_wounds()

/*
	BEWARE OF REDUNDANCY AHEAD THAT I MUST PARE DOWN
*/

/datum/wound/brute/bone/proc/splint(obj/item/stack/I, mob/user)
	if(splinted && splinted.splint_factor >= I.splint_factor)
		to_chat(user, "<span class='warning'>The splint already on [user == victim ? "your" : "[victim]'s"] [limb.name] is better than you can do with [I].</span>")
		return

	user.visible_message("<span class='danger'>[user] begins splinting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>You begin splinting [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	user.visible_message("<span class='green'>[user] finishes splinting [victim]'s [limb.name]!</span>", "<span class='green'>You finish splinting [user == victim ? "your" : "[victim]'s"] [limb.name]!</span>")
	treat_priority = FALSE
	splinted = new I.type(limb)
	splinted.amount = 1
	I.use(1)
	update_inefficiencies()

/*
	Moderate (Joint Dislocation)
*/

/datum/wound/brute/bone/moderate
	name = "Joint Dislocation"
	desc = "Patient's bone has been unset from socket, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation by applying an aggressive grab to the patient and helpfully interacting with afflicted limb may suffice."
	examine_desc = "is awkwardly jammed out of place"
	occur_text = "jerks violently and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	viable_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 3
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET
	status_effect_type = /datum/status_effect/wound/bone/moderate
	scarring_descriptions = list("light discoloring", "a slight blue tint")

/datum/wound/brute/bone/moderate/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>You must have [victim] in an aggressive grab to manipulate [victim.p_their()] [lowertext(name)]!</span>")
		return TRUE

	if(user.grab_state >= GRAB_AGGRESSIVE)
		user.visible_message("<span class='danger'>[user] begins twisting and straining [victim]'s dislocated [limb.name]!</span>", "<span class='notice'>You begin twisting and straining [victim]'s dislocated [limb.name]...</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] begins twisting and straining your dislocated [limb.name]!</span>")
		if(user.a_intent == INTENT_HELP)
			chiropractice(user)
		else
			malpractice(user)
		return TRUE

/datum/wound/brute/bone/moderate/proc/chiropractice(mob/living/carbon/human/user)
	var/time = base_treat_time
	var/time_mod = user.mind?.get_skill_modifier(/datum/skill/medical, SKILL_SPEED_MODIFIER)
	var/prob_mod = user.mind?.get_skill_modifier(/datum/skill/medical, SKILL_PROBS_MODIFIER)
	if(time_mod)
		time *= time_mod

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(prob(65 + prob_mod))
		user.visible_message("<span class='danger'>[user] snaps [victim]'s dislocated [limb.name] back into place!</span>", "<span class='notice'>You snap [victim]'s dislocated [limb.name] back into place!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] snaps your dislocated [limb.name] back into place!</span>")
		victim.emote("scream")
		limb.receive_damage(brute=20, wound_bonus=CANT_WOUND)
		qdel(src)
	else
		user.visible_message("<span class='danger'>[user] wrenches [victim]'s dislocated [limb.name] around painfully!</span>", "<span class='danger'>You wrench [victim]'s dislocated [limb.name] around painfully!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] wrenches your dislocated [limb.name] around painfully!</span>")
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		chiropractice(user)

/datum/wound/brute/bone/moderate/proc/malpractice(mob/living/carbon/human/user)
	var/time = base_treat_time
	var/time_mod = user.mind?.get_skill_modifier(/datum/skill/medical, SKILL_SPEED_MODIFIER)
	var/prob_mod = user.mind?.get_skill_modifier(/datum/skill/medical, SKILL_PROBS_MODIFIER)
	if(time_mod)
		time *= time_mod

	if(!do_after(user, time, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return

	if(prob(65 + prob_mod))
		user.visible_message("<span class='danger'>[user] snaps [victim]'s dislocated [limb.name] with a sickening crack!</span>", "<span class='danger'>You snap [victim]'s dislocated [limb.name] with a sickening crack!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] snaps your dislocated [limb.name] with a sickening crack!</span>")
		victim.emote("scream")
		limb.receive_damage(brute=25, wound_bonus=30 + prob_mod * 3)
	else
		user.visible_message("<span class='danger'>[user] wrenches [victim]'s dislocated [limb.name] around painfully!</span>", "<span class='danger'>You wrench [victim]'s dislocated [limb.name] around painfully!</span>", ignored_mobs=victim)
		to_chat(victim, "<span class='userdanger'>[user] wrenches your dislocated [limb.name] around painfully!</span>")
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		malpractice(user)


/datum/wound/brute/bone/moderate/treat(obj/item/I, mob/user)
	if(victim == user)
		victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>You begin resetting your [limb.name] with [I]...</span>")
	else
		user.visible_message("<span class='danger'>[user] begins resetting [victim]'s [limb.name] with [I].</span>", "<span class='notice'>You begin resetting [victim]'s [limb.name] with [I]...</span>")

	if(!do_after(user, base_treat_time * (user == victim ? 1.5 : 1), target = victim, extra_checks=CALLBACK(src, .proc/still_exists)))
		return

	if(victim == user)
		limb.receive_damage(brute=15, wound_bonus=CANT_WOUND)
		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] [limb.name]!</span>", "<span class='userdanger'>You reset your [limb.name]!</span>")
	else
		limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
		user.visible_message("<span class='danger'>[user] finishes resetting [victim]'s [limb.name]!</span>", "<span class='nicegreen'>You finish resetting [victim]'s [limb.name]!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets your [limb.name]!</span>")

	victim.emote("scream")
	qdel(src)

/*
	Severe (Hairline Fracture)
*/

/datum/wound/brute/bone/severe
	name = "Hairline Fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Recommended light surgical application of bone gel, though splinting will prevent worsening situation."
	examine_desc = "appears bruised and grotesquely swollen"

	occur_text = "sprays chips of bone and develops a nasty looking bruise"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	threshold_minimum = 60
	threshold_penalty = 30
	treatable_by = list(/obj/item/stack/sticky_tape, /obj/item/stack/medical/gauze)
	status_effect_type = /datum/status_effect/wound/bone/severe
	treat_priority = TRUE
	scarring_descriptions = list("a faded, fist-sized bruise", "a vaguely triangular peel scar")


/datum/wound/brute/bone/critical
	name = "Compound Fracture"
	desc = "Patient's bones have suffered multiple gruesome fractures, causing significant pain and near uselessness of limb."
	treat_text = "Immediate binding of affected limb, followed by surgical intervention ASAP."
	examine_desc = "has a cracked bone sticking out of it"
	occur_text = "cracks apart, exposing broken bones to open air"
	severity = WOUND_SEVERITY_CRITICAL
	interaction_efficiency_penalty = 4
	limp_slowdown = 9
	sound_effect = 'sound/effects/crack2.ogg'
	threshold_minimum = 115
	threshold_penalty = 50
	disabling = TRUE
	treatable_by = list(/obj/item/stack/sticky_tape, /obj/item/stack/medical/gauze)
	status_effect_type = /datum/status_effect/wound/bone/critical
	treat_priority = TRUE
	scarring_descriptions = list("a section of janky skin lines and badly healed scars", "a large patch of uneven skin tone", "a cluster of calluses")

/datum/wound/brute/bone/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack))
		splint(I, user)
