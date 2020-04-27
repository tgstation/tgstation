


/*
	Bones
*/
// TODO: well, a lot really, but i'd kill to get overlays and a bonebreaking effect like Blitz: The League, similar to electric shock skeletons


/datum/wound/brute/bone
	sound_effect = 'sound/effects/crack1.ogg'
	wound_type = WOUND_TYPE_BONE

	/// How effective various item types are at splinting these injuries. Checks from left to right, subpaths are accepted, so put specific subtypes before general ones
	var/list/splint_items = list(/obj/item/stack/medical/gauze = 0.25, /obj/item/stack/sticky_tape/surgical = 0.4, /obj/item/stack/sticky_tape/super = 0.6, /obj/item/stack/sticky_tape = 0.75)
	/// A coefficient for how much of the wound's negative effects like limping we can ignore thanks to splints, lower the better
	var/splint_factor

/datum/wound/brute/bone/apply_wound(obj/item/bodypart/L, silent=FALSE, datum/wound/old_wound = NONE, special_arg=NONE)
	. = ..()
	if(L.held_index && victim.get_item_for_held_index(L.held_index) && prob(30 * severity))
		var/obj/item/I = victim.get_item_for_held_index(L.held_index)
		if(victim.dropItemToGround(I))
			victim.visible_message("<span class='danger'>[victim] drops [I] in shock!</span>", "<span class='warning'><b>The force on your [L.name] causes you to drop [I]!</b></span>", vision_distance=COMBAT_MESSAGE_RANGE)

	update_inefficiencies()

/datum/wound/brute/bone/proc/check_splint_factor(obj/item/I)
	for(var/item_path in splint_items)
		if(istype(I, item_path))
			return splint_items[item_path]

/datum/wound/brute/bone/proc/update_inefficiencies()
	if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
		if(splint_factor)
			limp_slowdown = initial(limp_slowdown) * splint_factor
		else
			limp_slowdown = initial(limp_slowdown)
		victim.apply_status_effect(STATUS_EFFECT_LIMP)
	else if(limb.body_zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))
		if(splint_factor)
			interaction_efficiency_penalty = 1 + ((interaction_efficiency_penalty - 1) * splint_factor)
		else
			interaction_efficiency_penalty = interaction_efficiency_penalty

	if(disabling && splint_factor)
		disabling = FALSE

	limb.update_wounds()


/datum/wound/brute/bone/moderate
	name = "Joint Dislocation"
	desc = "Patient's bone has been unset from socket, causing pain and reduced motor function."
	treat_text = "Recommended application of bonesetter to affected limb, though manual relocation may suffice."
	examine_desc = "is awkwardly jammed out of place"
	occur_text = "jerks violently and becomes unseated"
	severity = WOUND_SEVERITY_MODERATE
	interaction_efficiency_penalty = 1.5
	limp_slowdown = 3
	threshold_minimum = 35
	threshold_penalty = 15
	treatable_tool = TOOL_BONESET
	status_effect_type = /datum/status_effect/wound/bone/moderate

/datum/wound/brute/bone/moderate/try_handling(mob/living/carbon/human/user)
	if(user.pulling != victim || user.zone_selected != limb.body_zone || user.a_intent == INTENT_GRAB)
		return FALSE

	if(user.grab_state == GRAB_PASSIVE)
		to_chat(user, "<span class='warning'>You must have [victim] in an aggressive grab to manipulate [victim.p_their()] [src]!</span>")
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

	if(!do_after(user, time, TRUE, victim))

		if(prob(65 + prob_mod))
			user.visible_message("<span class='danger'>[user] snaps [victim]'s dislocated [limb.name] back into place!</span>", "<span class='notice'>You snap [victim]'s dislocated [limb.name] back into place!</span>", ignored_mobs=victim)
			to_chat(victim, "<span class='userdanger'>[user] snaps your dislocated [limb.name] back into place!</span>")
			victim.emote("scream")
			limb.receive_damage(brute=20, wound_bonus=CANT_WOUND)
			remove_wound()
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

	if(!do_after(user, time, TRUE, victim))

		if(prob(25 + prob_mod))
			user.visible_message("<span class='danger'>[user] snaps [victim]'s dislocated [limb.name] with a sickening crack!</span>", "<span class='danger'>You snap [victim]'s dislocated [limb.name] with a sickening crack!</span>", ignored_mobs=victim)
			to_chat(victim, "<span class='userdanger'>[user] snaps your dislocated [limb.name] with a sickening crack!</span>")
			victim.emote("scream")
			limb.receive_damage(brute=25, wound_bonus=30 + prob_mod * 3)
		else
			user.visible_message("<span class='danger'>[user] wrenches [victim]'s dislocated [limb.name] around painfully!</span>", "<span class='danger'>You wrench [victim]'s dislocated [limb.name] around painfully!</span>", ignored_mobs=victim)
			to_chat(victim, "<span class='userdanger'>[user] wrenches your dislocated [limb.name] around painfully!</span>")
			limb.receive_damage(brute=10, wound_bonus=CANT_WOUND)
			malpractice(user)


/datum/wound/brute/bone/moderate/treat_self(obj/item/I, mob/user)
	victim.visible_message("<span class='danger'>[user] begins resetting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>You begin resetting your [limb.name] with [I]...</span>")
	if(!do_after(user, base_treat_time * I.toolspeed * 1.5, target = victim, extra_checks=.proc/still_exists))

		victim.visible_message("<span class='danger'>[user] finishes resetting [victim.p_their()] [limb.name]!</span>", "<span class='userdanger'>You reset your [limb.name]!</span>")
		victim.emote("scream")
		remove_wound()

/datum/wound/brute/bone/moderate/treat(obj/item/I, mob/user)
	user.visible_message("<span class='danger'>[user] begins resetting [victim]'s [limb.name] with [I].</span>", "<span class='notice'>You begin resetting [victim]'s [limb.name] with [I]...</span>", victim)
	to_chat(victim, "<span class='warning'>[user] begins resetting your [limb.name] with [I].</span>")
	if(!do_after(user, base_treat_time * I.toolspeed, target = victim, extra_checks=.proc/still_exists))

		user.visible_message("<span class='danger'>[user] finishes resetting [victim]'s [limb.name]!</span>", "<span class='nicegreen'>You finish resetting [victim]'s [limb.name]!</span>", victim)
		to_chat(victim, "<span class='userdanger'>[user] resets your [limb.name]!</span>")
		victim.emote("scream")
		remove_wound()

/*
	Severe (Hairline Fracture)
*/

/datum/wound/brute/bone/severe
	name = "Hairline Fracture"
	desc = "Patient's bone has suffered a crack in the foundation, causing serious pain and reduced limb functionality."
	treat_text = "Recommended light surgical application of bone gel, though splinting will prevent worsening situation."
	examine_desc = "appears bruised and grotesquely swollen"
	var/splint_examine_desc = "is fastened in a splint of "
	occur_text = "sprays chips of bone and develops a nasty looking bruise"
	severity = WOUND_SEVERITY_SEVERE
	interaction_efficiency_penalty = 2
	limp_slowdown = 6
	threshold_minimum = 55
	threshold_penalty = 30
	treatable_by = list(/obj/item/stack/sticky_tape, /obj/item/stack/medical/gauze)
	status_effect_type = /datum/status_effect/wound/bone/severe


/datum/wound/brute/bone/severe/treat_self(obj/item/I, mob/user)
	var/splint_check = check_splint_factor(I)
	if(splint_factor && splint_check >= splint_factor)
		to_chat(user, "<span class='warning'>The splint already on [user == victim ? "your" : "[victim]'s"] [limb.name] is better than you can do with [I].</span>")
		return
	victim.visible_message("<span class='danger'>[user] begins splinting [victim.p_their()] [limb.name] with [I].</span>", "<span class='warning'>You begin splinting your [limb.name] with [I]...</span>")
	if(!do_after(user, base_treat_time * 1.5, target = victim, extra_checks=.proc/still_exists))

		examine_desc = splint_examine_desc + I.name
		victim.visible_message("<span class='notice'>[user] finishes splinting [victim.p_their()] [limb.name]!</span>", "<span class='nicegreen'>You finish splinting your [limb.name]!</span>")
		splint_factor = splint_check
		update_inefficiencies()

/datum/wound/brute/bone/severe/treat(obj/item/I, mob/user)
	var/splint_check = check_splint_factor(I)
	if(splint_factor && splint_check >= splint_factor)
		to_chat(user, "<span class='warning'>The splint already on [user == victim ? "your" : "[victim]'s"] [limb.name] is better than you can do with [I].</span>")
		return
	user.visible_message("<span class='notice'>[user] begins splinting [victim]'s [limb.name] with [I].</span>", "<span class='notice'>You begin splinting [victim]'s [limb.name] with [I]...</span>", victim)
	to_chat(victim, "<span class='notice'>[user] begins splinting your [limb.name] with [I].</span>")
	if(!do_after(user, base_treat_time, target = victim, extra_checks=.proc/still_exists))

		examine_desc = splint_examine_desc + I.name
		user.visible_message("<span class='notice'>[user] finishes splinting [victim]'s [limb.name]!</span>", "<span class='nicegreen'>You finish splinting [victim]'s [limb.name]!</span>", victim)
		to_chat(victim, "<span class='nicegreen'>[user] splints your [limb.name]!</span>")
		splint_factor = check_splint_factor(I)
		update_inefficiencies()

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
	threshold_minimum = 110
	threshold_penalty = 50
	disabling = TRUE
	treatable_by = list(/obj/item/stack/sticky_tape, /obj/item/stack/medical/gauze)
	status_effect_type = /datum/status_effect/wound/bone/critical


