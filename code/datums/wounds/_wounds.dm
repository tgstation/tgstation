/*
	Wounds are specific medical complications that can arise and be applied to (currently) carbons, with a focus on humans. All of the code for and related to this is heavily WIP,
	and the documentation will be slanted towards explaining what each part/piece is leading up to, until such a time as I finish the core implementations. The original design doc
	can be found at https://hackmd.io/@Ryll/r1lb4SOwU

	Wounds are datums that operate like a mix of diseases, brain traumas, and components, and are applied to a /obj/item/bodypart (preferably attached to a carbon) when they take large spikes of damage
	or under other certain conditions (thrown hard against a wall, sustained exposure to plasma fire, etc). Wounds are categorized by the three following criteria:
		1. Severity: Either MODERATE, SEVERE, or CRITICAL. See the hackmd for more details
		2. Viable zones: What body parts the wound is applicable to. Generic wounds like broken bones and severe burns can apply to every zone, but you may want to add special wounds for certain limbs
			like a twisted ankle for legs only, or open air exposure of the organs for particularly gruesome chest wounds. Wounds should be able to function for every zone they are marked viable for.
		3. Damage type: Currently either BRUTE or BURN. Again, see the hackmd for a breakdown of my plans for each type.

	When a body part suffers enough damage to get a wound, the severity (determined by a roll or something, worse damage leading to worse wounds), affected limb, and damage type sustained are factored into
	deciding what specific wound will be applied. I'd like to have a few different types of wounds for at least some of the choices, but I'm just doing rough generals for now. Expect polishing
*/

/datum/wound
	//Fluff
	var/form = "injury"
	var/name = "ouchie"
	var/desc = ""
	var/treat_text = ""
	var/examine_desc = ""

	/// needed for "your arm has a compound fracture" vs "your arm has some third degree burs"
	var/a_or_from = "a"

	var/occur_text = ""
	/// This sound will be played upon the wound being applied
	var/sound_effect

	/// Either WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_SEVERE, or WOUND_SEVERITY_CRITICAL
	var/severity = WOUND_SEVERITY_MODERATE
	/// What damage type can allow this wound to be rolled, currently either BRUTE or BURN
	var/damtype = BRUTE

	/// What body zones can we affect
	var/list/viable_zones = list(BODY_ZONE_HEAD, BODY_ZONE_CHEST, BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	/// Who owns the body part that we're wounding
	var/mob/living/carbon/victim = null
	/// The bodypart we're parented to
	var/obj/item/bodypart/limb = null

	/// Specific items such as bandages or sutures that can try directly treating this wound
	var/list/treatable_by
	/// Tools with the specified tool flag will also be able to try directly treating this wound
	var/treatable_tool
	/// How long it will take to treat this wound with a standard effective tool, assuming it doesn't need surgery
	var/base_treat_time = 5 SECONDS

	/// Using this limb in a do_after interaction will multiply the length by this duration (arms)
	var/interaction_efficiency_penalty = 1
	/// Incoming damage on this limb will be multiplied by this, to simulate tenderness and vulnerability (mostly burns).
	var/damage_mulitplier_penalty = 1
	/// If set and this wound is applied to a leg,
	var/limp_slowdown

	/// If we currently need to process each life tick
	var/processes = FALSE
	/// How much we're contributing to this limb's bleed_rate
	var/blood_flow

	/// The list of wounds it belongs in, WOUND_TYPE_BONE, WOUND_TYPE_CUT, or WOUND_TYPE_BURN
	var/wound_type

	/// The minimum we need to roll on [/obj/item/bodypart/proc/receive_damage()] to begin suffering this wound, the roll is 0-100 +/- modifiers, see receive_damage() for more
	var/threshold_minimum
	/// How much having this wound will add to future receive_damage() rolls on this limb, to allow progression to worse injuries with repeated damage
	var/threshold_penalty

	///
	var/status_effect_type

	/// If having this wound makes the parent bodypart unusable
	var/disabling

	var/datum/status_effect/linked_status_effect

/datum/wound/Destroy()
	. = ..()
	remove_wound()

/// Apply whatever wound we've created to the specified limb
/datum/wound/proc/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/old_wound = NONE, special_arg = NONE)
	if(!istype(L) || !L.owner || !(L.body_zone in viable_zones))
		return

	for(var/i in L.wounds)
		var/datum/wound/prexisting_wound = i
		if(prexisting_wound.type == type)
			qdel(src)
			return

	victim = L.owner
	limb = L
	LAZYADD(victim.all_wounds, src)
	LAZYADD(limb.wounds, src)
	limb.update_wounds()
	if(status_effect_type)
		linked_status_effect = victim.apply_status_effect(status_effect_type, src)
	SEND_SIGNAL(victim, COMSIG_CARBON_GAIN_WOUND, src, limb)
	if(!victim.alerts["wound"])
		victim.throw_alert("wound", /obj/screen/alert/status_effect/wound)

	var/demoted
	if(old_wound)
		demoted = (severity <= old_wound.severity)

	if(severity == WOUND_SEVERITY_TRIVIAL)
		return

	if(!(silent || demoted))
		var/msg = "<span class='danger'>[victim]'s [limb.name] [occur_text]!</span>"
		var/vis_dist = COMBAT_MESSAGE_RANGE

		if(severity != WOUND_SEVERITY_MODERATE)
			msg = "<b>[msg]</b>"
			vis_dist = DEFAULT_MESSAGE_RANGE

		victim.visible_message(msg, "<span class='userdanger'>Your [limb.name] [occur_text]!</span>", vision_distance = vis_dist)
		if(sound_effect)
			playsound(L.owner, sound_effect, 60 + 20 * severity, TRUE)

	if(!demoted)
		wound_injury()
		second_wind()

/// Remove the wound from whatever it's afflicting
/datum/wound/proc/remove_wound()
	if(limb)
		LAZYREMOVE(limb.wounds, src)
		limb.update_wounds()
		limb = null
	if(victim)
		LAZYREMOVE(victim.all_wounds, src)
		if(!victim.all_wounds)
			victim.clear_alert("wound")
		SEND_SIGNAL(victim, COMSIG_CARBON_LOSE_WOUND, src, limb)
		victim = null

/// When you want to swap out one wound for another (typically a promotion or demotion in the same type)
/datum/wound/proc/replace_wound(new_type, special_arg)
	var/datum/wound/new_wound = new new_type
	var/obj/item/bodypart/temp_limb = limb // since we're about to null it
	remove_wound()
	new_wound.apply_wound(temp_limb, silent = TRUE, old_wound = src)
	qdel(src)

/// The immediate negative effects faced as a result of the wound
/datum/wound/proc/wound_injury()
	return

/// Additional beneficial effects when the wound is gained, in case you want to give a temporary boost to allow the victim to try an escape or last stand
/datum/wound/proc/second_wind()
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			victim.reagents.add_reagent(/datum/reagent/determination, WOUND_DETERMINATION_MODERATE)
		if(WOUND_SEVERITY_SEVERE)
			victim.reagents.add_reagent(/datum/reagent/determination, WOUND_DETERMINATION_SEVERE)
		if(WOUND_SEVERITY_CRITICAL)
			victim.reagents.add_reagent(/datum/reagent/determination, WOUND_DETERMINATION_CRITICAL)


/// Someone is using their hands on us, we can check to see if we want to let them treat us by hand
/datum/wound/proc/try_handling(mob/living/carbon/human/user)
	return FALSE

/// Someone is using something that might be used for treating the wound on this limb
/datum/wound/proc/try_treating(obj/item/I, mob/user)
	if(limb.body_zone != user.zone_selected || (I.force && user.a_intent != INTENT_HELP))
		return FALSE

	if((I.tool_behaviour != treatable_tool) && !(treatable_tool == TOOL_CAUTERY && I.get_temperature() > 300))
		var/allowed = FALSE
		for(var/allowed_type in treatable_by)
			if(istype(I, allowed_type))
				allowed = TRUE
				break
		if(!allowed)
			return FALSE

	if(INTERACTING_WITH(user, victim))
		to_chat(user, "<span class='warning'>You're already interacting with [victim]!</span>")
		return TRUE

	if(user == victim)
		treat_self(I, user)
	else
		treat(I, user)
	return TRUE

/// Someone is using something that might be used for treating the wound on this limb
/datum/wound/proc/treat_self(obj/item/I, mob/user)
	return treat(I, user)

/// Someone is using something that might be used for treating the wound on this limb
/datum/wound/proc/treat(obj/item/I, mob/user)
	return

/// Someone is using something that might be used for treating the wound on this limb
/datum/wound/proc/applied_reagents( mob/user)
	return

/// If var/processing is TRUE, this is run on each life tick
/datum/wound/proc/handle_process()
	return

/datum/wound/proc/still_exists()
	return (!QDELETED(src) && limb)

/datum/wound/proc/severity_text()
	switch(severity)
		if(WOUND_SEVERITY_TRIVIAL)
			return "Trivial"
		if(WOUND_SEVERITY_MODERATE)
			return "Moderate"
		if(WOUND_SEVERITY_SEVERE)
			return "Severe"
		if(WOUND_SEVERITY_CRITICAL)
			return "Critical"

/datum/wound/brute
	damtype = BRUTE
