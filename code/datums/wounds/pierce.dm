
/*
	Pierce
*/

/datum/wound/pierce
	sound_effect = 'sound/weapons/slice.ogg'
	processes = TRUE
	wound_type = WOUND_LIST_PIERCE
	treatable_by = list(/obj/item/stack/medical/suture, /obj/item/stack/medical/gauze)
	treatable_by_grabbed = list(/obj/item/gun/energy/laser)
	treatable_tool = TOOL_CAUTERY
	base_treat_time = 3 SECONDS

	/// How much blood we start losing when this wound is first applied
	var/initial_flow
	/// When we have less than this amount of flow, either from treatment or clotting, we demote to a lower cut or are healed of the wound
	var/minimum_flow
	/// How fast our blood flow will naturally decrease per tick, not only do larger cuts bleed more faster, they clot slower
	var/clot_rate

	/// Once the blood flow drops below minimum_flow, we demote it to this type of wound. If there's none, we're all better
	var/demotes_to

	/// How much staunching per type (cautery, suturing, bandaging) you can have before that type is no longer effective for this cut NOT IMPLEMENTED
	var/max_per_type
	/// The maximum flow we've had so far
	var/highest_flow
	/// How much flow we've already cauterized
	var/cauterized
	/// How much flow we've already sutured
	var/sutured

/datum/wound/pierce/receive_damage(wounding_type, wounding_dmg, wound_bonus)
	if(victim.stat != DEAD && wounding_type == WOUND_SLASH) // can't stab dead bodies to make it bleed faster this way
		blood_flow += 0.05 * wounding_dmg

/datum/wound/pierce/handle_process()
	blood_flow = min(blood_flow, WOUND_CUT_MAX_BLOODFLOW)

	if(victim.reagents && victim.reagents.has_reagent(/datum/reagent/toxin/heparin))
		blood_flow += 0.5 // old herapin used to just add +2 bleed stacks per tick, this adds 0.5 bleed flow to all open cuts which is probably even stronger as long as you can cut them first
	else if(victim.reagents && victim.reagents.has_reagent(/datum/reagent/medicine/coagulant))
		blood_flow -= 0.25

	if(limb.current_gauze)
		if(clot_rate > 0)
			blood_flow -= clot_rate
		blood_flow -= limb.current_gauze.absorption_rate
		limb.current_gauze.absorption_capacity -= limb.current_gauze.absorption_rate

	//else
		//blood_flow -= clot_rate

	if(blood_flow > highest_flow)
		highest_flow = blood_flow


/datum/wound/pierce/treat(obj/item/I, mob/user)
	if(istype(I, /obj/item/stack/medical/suture))
		suture(I, user)


/datum/wound/pierce/on_xadone(power)
	. = ..()
	blood_flow -= 0.03 * power // i think it's like a minimum of 3 power, so .09 blood_flow reduction per tick is pretty good for 0 effort


/// If someone is using a suture to close this cut
/datum/wound/pierce/proc/suture(obj/item/stack/medical/suture/I, mob/user)
	var/self_penalty_mult = (user == victim ? 1.4 : 1)
	user.visible_message("<span class='notice'>[user] begins stitching [victim]'s [limb.name] with [I]...</span>", "<span class='notice'>You begin stitching [user == victim ? "your" : "[victim]'s"] [limb.name] with [I]...</span>")
	var/time_mod = user.mind?.get_skill_modifier(/datum/skill/healing, SKILL_SPEED_MODIFIER) || 1
	if(!do_after(user, base_treat_time * time_mod * self_penalty_mult, target=victim, extra_checks = CALLBACK(src, .proc/still_exists)))
		return
	user.visible_message("<span class='green'>[user] stitches up some of the bleeding on [victim].</span>", "<span class='green'>You stitch up some of the bleeding on [user == victim ? "yourself" : "[victim]"].</span>")
	var/blood_sutured = I.stop_bleeding / self_penalty_mult
	blood_flow -= blood_sutured
	sutured += blood_sutured
	limb.heal_damage(I.heal_brute, I.heal_burn)

	if(blood_flow > minimum_flow)
		try_treating(I, user)
	else if(demotes_to)
		to_chat(user, "<span class='green'>You successfully lower the severity of [user == victim ? "your" : "[victim]'s"] cuts.</span>")

/datum/wound/pierce/moderate
	name = "Minor Breakage"
	desc = "Patient's skin has been broken open, causing severe bruising and minor internal bleeding in affected area."
	treat_text = "Treat afffected site with bandaging or exposure to extreme cold. In dire cases, brief exposure to vacuum may suffice." // lol shove your bruised arm out into space, ss13 logic
	examine_desc = "has a small, circular hole, gently bleeding"
	occur_text = "spurts out a thin stream of blood"
	sound_effect = 'sound/effects/blood1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 2
	minimum_flow = 0.5
	max_per_type = 3
	clot_rate = 0.15
	threshold_minimum = 40
	threshold_penalty = 15
	status_effect_type = /datum/status_effect/wound/pierce/moderate
	scarring_descriptions = list("a small, faded bruise", "a small twist of reformed skin", "a thumb-sized puncture scar")

/datum/wound/pierce/severe
	name = "Open Puncture"
	desc = "Patient's internal tissue is penetrated, causing sizeable internal bleeding and organ damage."
	treat_text = "Close sources of internal bleeding, then repair punctures in skin."
	examine_desc = "is pierced clear through, with bits of tissue obscuring the open hole"
	occur_text = "looses a violent spray of blood, revealing a pierced wound"
	sound_effect = 'sound/effects/blood2.ogg'
	severity = WOUND_SEVERITY_SEVERE
	initial_flow = 3.25
	minimum_flow = 2.75
	clot_rate = 0.07
	max_per_type = 4
	threshold_minimum = 90
	threshold_penalty = 25
	demotes_to = /datum/wound/pierce/moderate
	status_effect_type = /datum/status_effect/wound/pierce/severe
	scarring_descriptions = list("an ink-splat shaped pocket of scar tissue", "a long-faded puncture wound", "a tumbling puncture hole with evidence of faded stitching")

/datum/wound/pierce/critical
	name = "Ruptured Cavity"
	desc = "Patient's internal tissue and circulatory system is shredded, causing significant internal bleeding and damage to internal organs."
	treat_text = "Surgical stabilization of damaged innards, followed by patching open holes in skin."
	examine_desc = "is ripped clear through, barely held together by exposed bone"
	occur_text = "blasts apart, sending chunks of viscera flying in all directions"
	sound_effect = 'sound/effects/blood3.ogg'
	severity = WOUND_SEVERITY_CRITICAL
	initial_flow = 4.25
	minimum_flow = 4
	clot_rate = -0.05 // critical cuts actively get worse instead of better
	max_per_type = 5
	threshold_minimum = 120
	threshold_penalty = 40
	demotes_to = /datum/wound/pierce/severe
	status_effect_type = /datum/status_effect/wound/pierce/critical
	scarring_descriptions = list("a rippling shockwave of scar tissue", "a wide, scattered cloud of shrapnel marks", "a gruesome multi-pronged puncture scar")
