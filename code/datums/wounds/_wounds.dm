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

#define WOUND_CRITICAL_BLUNT_DISMEMBER_BONUS 15

/datum/wound
	/// What it's named
	var/name = "Wound"
	/// The description shown on the scanners
	var/desc = ""
	/// The basic treatment suggested by health analyzers
	var/treat_text = ""
	/// What the limb looks like on a cursory examine
	var/examine_desc = "is badly hurt"

	/// If this wound can generate a scar.
	var/can_scar = TRUE

	/// The file we take our scar descriptions from.
	var/scar_file

	/// needed for "your arm has a compound fracture" vs "your arm has some third degree burns"
	var/a_or_from = "a"
	/// The visible message when this happens
	var/occur_text = ""
	/// This sound will be played upon the wound being applied
	var/sound_effect
	/// The volume of [sound_effect]
	var/sound_volume = 70

	/// Either WOUND_SEVERITY_TRIVIAL (meme wounds like stubbed toe), WOUND_SEVERITY_MODERATE, WOUND_SEVERITY_SEVERE, or WOUND_SEVERITY_CRITICAL (or maybe WOUND_SEVERITY_LOSS)
	var/severity = WOUND_SEVERITY_MODERATE
	/// The type of attack that can generate this wound. E.g. WOUND_SLASH = A sword can cause us, or WOUND_BLUNT = a hammer can cause us/a sword attacking mangled flesh.
	var/wound_type
	/// The series of wounds this is in. See wounds.dm (the defines file) for a more detailed explanation - but tldr is that no 2 wounds of the same series can be on a limb.
	var/wound_series

	/// Who owns the body part that we're wounding
	var/mob/living/carbon/victim = null
	/// The bodypart we're parented to. Not guaranteed to be non-null, especially after/during removal or if we haven't been applied
	var/obj/item/bodypart/limb = null

	/// Specific items such as bandages or sutures that can try directly treating this wound
	var/list/treatable_by
	/// Specific items such as bandages or sutures that can try directly treating this wound only if the user has the victim in an aggressive grab or higher
	var/list/treatable_by_grabbed
	/// Tools with the specified tool flag will also be able to try directly treating this wound
	var/treatable_tool
	/// How long it will take to treat this wound with a standard effective tool, assuming it doesn't need surgery
	var/base_treat_time = 5 SECONDS

	/// Using this limb in a do_after interaction will multiply the length by this duration (arms)
	var/interaction_efficiency_penalty = 1
	/// Incoming damage on this limb will be multiplied by this, to simulate tenderness and vulnerability (mostly burns).
	var/damage_mulitplier_penalty = 1
	/// If set and this wound is applied to a leg, we take this many deciseconds extra per step on this leg
	var/limp_slowdown
	/// If this wound has a limp_slowdown and is applied to a leg, it has this chance to limp each step
	var/limp_chance
	/// How much we're contributing to this limb's bleed_rate
	var/blood_flow
	/// Essentially, keeps track of whether or not this wound is capable of bleeding (in case the owner has the NOBLOOD species trait)
	var/no_bleeding = FALSE

	/// The minimum we need to roll on [/obj/item/bodypart/proc/check_wounding] to begin suffering this wound, see check_wounding_mods() for more
	var/threshold_minimum
	/// How much having this wound will add to all future check_wounding() rolls on this limb, to allow progression to worse injuries with repeated damage
	var/threshold_penalty
	/// If we need to process each life tick
	var/processes = FALSE

	/// If having this wound makes currently makes the parent bodypart unusable
	var/disabling

	/// What status effect we assign on application
	var/status_effect_type
	/// If we're operating on this wound and it gets healed, we'll nix the surgery too
	var/datum/surgery/attached_surgery
	/// if you're a lazy git and just throw them in cryo, the wound will go away after accumulating severity * 25 power
	var/cryo_progress

	/// What kind of scars this wound will create description wise once healed
	var/scar_keyword = "generic"
	/// If we've already tried scarring while removing (remove_wound can be called twice in a del chain, let's be nice to our code yeah?) TODO: make this cleaner
	var/already_scarred = FALSE
	/// The source of how we got the wound, typically a weapon.
	var/wound_source

	/// What flags apply to this wound
	var/wound_flags = (ACCEPTS_GAUZE)

/datum/wound/Destroy()
	if(attached_surgery)
		QDEL_NULL(attached_surgery)
	if (limb)
		remove_wound()
	return ..()

// Applied into wounds when they're scanned with the wound analyzer, halves time to treat them manually.
#define TRAIT_WOUND_SCANNED "wound_scanned"
// I dunno lol
#define ANALYZER_TRAIT "analyzer_trait"

/**
 * apply_wound() is used once a wound type is instantiated to assign it to a bodypart, and actually come into play.
 *
 *
 * Arguments:
 * * L: The bodypart we're wounding, we don't care about the person, we can get them through the limb
 * * silent: Not actually necessary I don't think, was originally used for demoting wounds so they wouldn't make new messages, but I believe old_wound took over that, I may remove this shortly
 * * old_wound: If our new wound is a replacement for one of the same time (promotion or demotion), we can reference the old one just before it's removed to copy over necessary vars
 * * smited- If this is a smite, we don't care about this wound for stat tracking purposes (not yet implemented)
 * * attack_direction: For bloodsplatters, if relevant
 * * wound_source: The source of the wound, such as a weapon.
 */
/datum/wound/proc/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/old_wound = null, smited = FALSE, attack_direction = null, wound_source = "Unknown")

	if (!can_be_applied_to(L, old_wound))
		qdel(src)
		return FALSE

	if(isitem(wound_source))
		var/obj/item/wound_item = wound_source
		src.wound_source = wound_item.name
	else
		src.wound_source = wound_source

	set_victim(L.owner)
	set_limb(L)
	LAZYADD(victim.all_wounds, src)
	LAZYADD(limb.wounds, src)
	no_bleeding = HAS_TRAIT(victim, TRAIT_NOBLOOD)
	update_descriptions()
	limb.update_wounds()
	if(status_effect_type)
		victim.apply_status_effect(status_effect_type, src)
	SEND_SIGNAL(victim, COMSIG_CARBON_GAIN_WOUND, src, limb)
	if(!victim.alerts[ALERT_WOUNDED]) // only one alert is shared between all of the wounds
		victim.throw_alert(ALERT_WOUNDED, /atom/movable/screen/alert/status_effect/wound)

	var/demoted
	if(old_wound)
		demoted = (severity <= old_wound.severity)

	if(severity == WOUND_SEVERITY_TRIVIAL)
		return

	if(!silent && !demoted)
		var/msg = span_danger("[victim]'s [limb.plaintext_zone] [occur_text]!")
		var/vis_dist = COMBAT_MESSAGE_RANGE

		if(severity != WOUND_SEVERITY_MODERATE)
			msg = "<b>[msg]</b>"
			vis_dist = DEFAULT_MESSAGE_RANGE

		victim.visible_message(msg, span_userdanger("Your [limb.plaintext_zone] [occur_text]!"), vision_distance = vis_dist)
		if(sound_effect)
			playsound(L.owner, sound_effect, sound_volume + (20 * severity), TRUE)

	wound_injury(old_wound, attack_direction = attack_direction)
	if(!demoted)
		second_wind()

	return TRUE

/// Returns TRUE if we can be applied to the limb.
/datum/wound/proc/can_be_applied_to(obj/item/bodypart/L, datum/wound/old_wound)
	var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[type]

	// We assume we aren't being randomly applied - we have no reason to believe we are
	// And, besides, if we were, you could just as easily check our pregen data rather than run this proc
	// Generally speaking this proc is called in apply_wound, which is called when the caller is already confidant in its ability to be applied
	return pregen_data.can_be_applied_to(L, wound_type, old_wound)

/// Returns the zones we can be applied to.
/datum/wound/proc/get_viable_zones()
	var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[type]

	return pregen_data.viable_zones

/// Returns the biostate we require to be applied.
/datum/wound/proc/get_required_biostate()
	var/datum/wound_pregen_data/pregen_data = GLOB.all_wound_pregen_data[type]

	return pregen_data.required_limb_biostate

// Updates descriptive texts for the wound, in case it can get altered for whatever reason
/datum/wound/proc/update_descriptions()
	return

/datum/wound/proc/null_victim()
	SIGNAL_HANDLER
	set_victim(null)

/datum/wound/proc/set_victim(new_victim)
	if(victim)
		UnregisterSignal(victim, COMSIG_QDELETING)
	remove_wound_from_victim()
	victim = new_victim
	if(victim)
		RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(null_victim))

/datum/wound/proc/source_died()
	SIGNAL_HANDLER
	qdel(src)

/// Remove the wound from whatever it's afflicting, and cleans up whateverstatus effects it had or modifiers it had on interaction times. ignore_limb is used for detachments where we only want to forget the victim
/datum/wound/proc/remove_wound(ignore_limb, replaced = FALSE)
	//TODO: have better way to tell if we're getting removed without replacement (full heal) scar stuff
	set_disabling(FALSE)
	if(limb && can_scar && !already_scarred && !replaced)
		already_scarred = TRUE
		var/datum/scar/new_scar = new
		new_scar.generate(limb, src)

	null_victim() // we use the proc here because some behaviors may depend on changing victim to some new value

	if(limb && !ignore_limb)
		set_limb(null, replaced) // since we're removing limb's ref to us, we should do the same
		// if you want to keep the ref, do it externally, theres no reason for us to remember it

/datum/wound/proc/remove_wound_from_victim()
	if(!victim)
		return
	LAZYREMOVE(victim.all_wounds, src)
	if(!victim.all_wounds)
		victim.clear_alert(ALERT_WOUNDED)
	SEND_SIGNAL(victim, COMSIG_CARBON_LOSE_WOUND, src, limb)

/**
 * replace_wound() is used when you want to replace the current wound with a new wound, presumably of the same category, just of a different severity (either up or down counts)
 *
 * Arguments:
 * * new_wound- The wound instance you want to replace this
 * * smited- If this is a smite, we don't care about this wound for stat tracking purposes (not yet implemented)
 */
/datum/wound/proc/replace_wound(datum/wound/new_wound, smited = FALSE, attack_direction = attack_direction)
	already_scarred = TRUE
	var/obj/item/bodypart/cached_limb = limb // remove_wound() nulls limb so we have to track it locally
	remove_wound(replaced=TRUE)
	new_wound.apply_wound(cached_limb, old_wound = src, smited = smited, attack_direction = attack_direction, wound_source = wound_source)
	. = new_wound
	qdel(src)

/// The immediate negative effects faced as a result of the wound
/datum/wound/proc/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	return

/// Proc called to change the variable `limb` and react to the event.
/datum/wound/proc/set_limb(obj/item/bodypart/new_value, replaced = FALSE)
	if(limb == new_value)
		return FALSE //Limb can either be a reference to something or `null`. Returning the number variable makes it clear no change was made.
	. = limb
	if(limb) // if we're nulling limb, we're basically detaching from it, so we should remove ourselves in that case
		UnregisterSignal(limb, COMSIG_QDELETING)
		LAZYREMOVE(limb.wounds, src)
		limb.update_wounds(replaced)
		if (disabling)
			limb.remove_traits(list(TRAIT_PARALYSIS, TRAIT_DISABLED_BY_WOUND), REF(src))

	limb = new_value

	// POST-CHANGE

	if (limb)
		RegisterSignal(limb, COMSIG_QDELETING, PROC_REF(source_died))
	if(limb)
		if(disabling)
			limb.add_traits(list(TRAIT_PARALYSIS, TRAIT_DISABLED_BY_WOUND), REF(src))

/// Proc called to change the variable `disabling` and react to the event.
/datum/wound/proc/set_disabling(new_value)
	if(disabling == new_value)
		return
	. = disabling
	disabling = new_value
	if(disabling)
		if(!. && limb) //Gained disabling.
			limb.add_traits(list(TRAIT_PARALYSIS, TRAIT_DISABLED_BY_WOUND), REF(src))
	else if(. && limb) //Lost disabling.
		limb.remove_traits(list(TRAIT_PARALYSIS, TRAIT_DISABLED_BY_WOUND), REF(src))
	if(limb?.can_be_disabled)
		limb.update_disabled()


/// Additional beneficial effects when the wound is gained, in case you want to give a temporary boost to allow the victim to try an escape or last stand
/datum/wound/proc/second_wind()
	switch(severity)
		if(WOUND_SEVERITY_MODERATE)
			victim.reagents.add_reagent(/datum/reagent/determination, WOUND_DETERMINATION_MODERATE)
		if(WOUND_SEVERITY_SEVERE)
			victim.reagents.add_reagent(/datum/reagent/determination, WOUND_DETERMINATION_SEVERE)
		if(WOUND_SEVERITY_CRITICAL)
			victim.reagents.add_reagent(/datum/reagent/determination, WOUND_DETERMINATION_CRITICAL)
		if(WOUND_SEVERITY_LOSS)
			victim.reagents.add_reagent(/datum/reagent/determination, WOUND_DETERMINATION_LOSS)

/**
 * try_treating() is an intercept run from [/mob/living/carbon/proc/attackby] right after surgeries but before anything else. Return TRUE here if the item is something that is relevant to treatment to take over the interaction.
 *
 * This proc leads into [/datum/wound/proc/treat] and probably shouldn't be added onto in children types. You can specify what items or tools you want to be intercepted
 * with var/list/treatable_by and var/treatable_tool, then if an item fulfills one of those requirements and our wound claims it first, it goes over to treat() and treat_self().
 *
 * Arguments:
 * * I: The item we're trying to use
 * * user: The mob trying to use it on us
 */
/datum/wound/proc/try_treating(obj/item/I, mob/user)
	// first we weed out if we're not dealing with our wound's bodypart, or if it might be an attack
	if(!I || limb.body_zone != user.zone_selected)
		return FALSE

	if(isliving(user))
		var/mob/living/tendee = user
		if(I.force && tendee.combat_mode)
			return FALSE

	if(!item_can_treat(I, user))
		return FALSE

	// now that we've determined we have a valid attempt at treating, we can stomp on their dreams if we're already interacting with the patient or if their part is obscured
	if(DOING_INTERACTION_WITH_TARGET(user, victim))
		to_chat(user, span_warning("You're already interacting with [victim]!"))
		return TRUE

	// next we check if the bodypart in actually accessible (not under thick clothing). We skip the species trait check since skellies
	// & such may need to use bone gel but may be wearing a space suit for..... whatever reason a skeleton would wear a space suit for
	if(ishuman(victim))
		var/mob/living/carbon/human/victim_human = victim
		if(!victim_human.try_inject(user, injection_flags = INJECT_CHECK_IGNORE_SPECIES | INJECT_TRY_SHOW_ERROR_MESSAGE))
			return TRUE

	// lastly, treat them
	return treat(I, user) // we allow treat to return a value so it can control if the item does its normal interaction or not

/// Returns TRUE if the item can be used to treat our wounds. Hooks into treat() - only things that return TRUE here may be used there.
/datum/wound/proc/item_can_treat(obj/item/potential_treater, mob/user)
	// check if we have a valid treatable tool
	if(potential_treater.tool_behaviour == treatable_tool)
		return TRUE
	if(treatable_tool == TOOL_CAUTERY && potential_treater.get_temperature() && user == victim) // allow improvised cauterization on yourself without an aggro grab
		return TRUE
	// failing that, see if we're aggro grabbing them and if we have an item that works for aggro grabs only
	if(user.pulling == victim && user.grab_state >= GRAB_AGGRESSIVE && check_grab_treatments(potential_treater, user))
		return TRUE
	// failing THAT, we check if we have a generally allowed item
	for(var/allowed_type in treatable_by)
		if(istype(potential_treater, allowed_type))
			return TRUE

/// Return TRUE if we have an item that can only be used while aggro grabbed (unhanded aggro grab treatments go in [/datum/wound/proc/try_handling]). Treatment is still is handled in [/datum/wound/proc/treat]
/datum/wound/proc/check_grab_treatments(obj/item/I, mob/user)
	return FALSE

/// Like try_treating() but for unhanded interactions from humans, used by joint dislocations for manual bodypart chiropractice for example. Ignores thick material checks since you can pop an arm into place through a thick suit unlike using sutures
/datum/wound/proc/try_handling(mob/living/carbon/human/user)
	return FALSE

/// Someone is using something that might be used for treating the wound on this limb
/datum/wound/proc/treat(obj/item/I, mob/user)
	return

/// If var/processing is TRUE, this is run on each life tick
/datum/wound/proc/handle_process(seconds_per_tick, times_fired)
	return

/// For use in do_after callback checks
/datum/wound/proc/still_exists()
	return (!QDELETED(src) && limb)

/// When our parent bodypart is hurt.
/datum/wound/proc/receive_damage(wounding_type, wounding_dmg, wound_bonus, attack_direction, damage_source)
	return

/// Called from cryoxadone and pyroxadone when they're proc'ing. Wounds will slowly be fixed separately from other methods when these are in effect. crappy name but eh
/datum/wound/proc/on_xadone(power)
	cryo_progress += power
	if(cryo_progress > 33 * severity)
		qdel(src)

/// When synthflesh is applied to the victim, we call this. No sense in setting up an entire chem reaction system for wounds when we only care for a few chems. Probably will change in the future
/datum/wound/proc/on_synthflesh(power)
	return

/// Called when the patient is undergoing stasis, so that having fully treated a wound doesn't make you sit there helplessly until you think to unbuckle them
/datum/wound/proc/on_stasis(seconds_per_tick, times_fired)
	return

/// Sets our blood flow
/datum/wound/proc/set_blood_flow(set_to)
	adjust_blood_flow(set_to - blood_flow)

/// Use this to modify blood flow. You must use this to change the variable
/// Takes the amount to adjust by, and the lowest amount we're allowed to have post adjust
/datum/wound/proc/adjust_blood_flow(adjust_by, minimum = 0)
	if(!adjust_by)
		return
	var/old_flow = blood_flow
	blood_flow = max(blood_flow + adjust_by, minimum)

	if(old_flow == blood_flow)
		return

	/// Update our bleed rate
	limb.refresh_bleed_rate()

/// Used when we're being dragged while bleeding, the value we return is how much bloodloss this wound causes from being dragged. Since it's a proc, you can let bandages soak some of the blood
/datum/wound/proc/drag_bleed_amount()
	return

/**
 * get_bleed_rate_of_change() is used in [/mob/living/carbon/proc/bleed_warn] to gauge whether this wound (if bleeding) is becoming worse, better, or staying the same over time
 *
 * Returns BLOOD_FLOW_STEADY if we're not bleeding or there's no change (like piercing), BLOOD_FLOW_DECREASING if we're clotting (non-critical slashes, gauzed, coagulant, etc), BLOOD_FLOW_INCREASING if we're opening up (crit slashes/heparin/nitrous oxide)
 */
/datum/wound/proc/get_bleed_rate_of_change()
	if(blood_flow && HAS_TRAIT(victim, TRAIT_BLOODY_MESS))
		return BLOOD_FLOW_INCREASING
	return BLOOD_FLOW_STEADY

/**
 * get_examine_description() is used in carbon/examine and human/examine to show the status of this wound. Useful if you need to show some status like the wound being splinted or bandaged.
 *
 * Return the full string line you want to show, note that we're already dealing with the 'warning' span at this point, and that \n is already appended for you in the place this is called from
 *
 * Arguments:
 * * mob/user: The user examining the wound's owner, if that matters
 */
/datum/wound/proc/get_examine_description(mob/user)
	. = get_wound_description(user)
	if(HAS_TRAIT(src, TRAIT_WOUND_SCANNED))
		. += span_notice("\nThere is a holo-image next to the wound that seems to contain indications for treatment.")

	return .

/datum/wound/proc/get_wound_description(mob/user)
	var/desc

	if ((wound_flags & ACCEPTS_GAUZE) && limb.current_gauze)
		var/sling_condition = get_gauze_condition()
		desc = "[victim.p_Their()] [limb.plaintext_zone] is [sling_condition] fastened in a sling of [limb.current_gauze.name]"
	else
		desc = "[victim.p_Their()] [limb.plaintext_zone] [examine_desc]"

	desc = modify_desc_before_span(desc, user)

	return get_desc_intensity(desc)

/// A hook proc used to modify desc before it is spanned via [get_desc_intensity]. Useful for inserting spans yourself.
/datum/wound/proc/modify_desc_before_span(desc, mob/user)
	return desc

/datum/wound/proc/get_gauze_condition()
	SHOULD_BE_PURE(TRUE)
	if (!limb.current_gauze)
		return null

	switch(limb.current_gauze.absorption_capacity)
		if(0 to 1.25)
			return "just barely"
		if(1.25 to 2.75)
			return "loosely"
		if(2.75 to 4)
			return "mostly"
		if(4 to INFINITY)
			return "tightly"

/// Spans [desc] based on our severity.
/datum/wound/proc/get_desc_intensity(desc)
	SHOULD_BE_PURE(TRUE)
	if (severity > WOUND_SEVERITY_MODERATE)
		return span_bold("[desc]!")
	return "[desc]."

/datum/wound/proc/get_scanner_description(mob/user)
	return "Type: [name]\nSeverity: [severity_text()]\nDescription: [desc]\nRecommended Treatment: [treat_text]"

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


/// Returns TRUE if our limb is the head or chest, FALSE otherwise.
/// Essential in the sense of "we cannot live without it".
/datum/wound/proc/limb_essential()
	return (limb.body_zone == BODY_ZONE_HEAD || limb.body_zone == BODY_ZONE_CHEST)

/// Getter proc for our scar_keyword, in case we might have some custom scar gen logic.
/datum/wound/proc/get_scar_keyword(obj/item/bodypart/scarred_limb, add_to_scars)
	return scar_keyword

/// Getter proc for our scar_file, in case we might have some custom scar gen logic.
/datum/wound/proc/get_scar_file(obj/item/bodypart/scarred_limb, add_to_scars)
	return scar_file

/// Returns what string is displayed when a limb that has sustained this wound is examined
/// (This is examining the LIMB ITSELF, when it's not attached to someone.)
/datum/wound/proc/get_limb_examine_description()
	return

/// Gets the flat percentage chance increment of a dismember occuring, if a dismember is attempted (requires mangled flesh and bone). returning 15 = +15%.
/datum/wound/proc/get_dismember_chance_bonus(existing_chance)
	SHOULD_BE_PURE(TRUE)

	if (wound_type == WOUND_BLUNT && severity >= WOUND_SEVERITY_CRITICAL)
		return WOUND_CRITICAL_BLUNT_DISMEMBER_BONUS // we only require mangled bone (T2 blunt), but if there's a critical blunt, we'll add 15% more

#undef WOUND_CRITICAL_BLUNT_DISMEMBER_BONUS
