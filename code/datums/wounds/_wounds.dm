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

	/// Simple description, shortened for clarity if defined. Otherwise just takes the normal desc in the analyzer proc.
	var/simple_desc
	/// Simple analyzer's wound description, which focuses less on the clinical aspect of the wound and more on easily readable treatment instructions.
	var/simple_treat_text = "Go to medbay idiot"
	/// Improvised remedies indicated by the first aid analyzer only.
	var/homemade_treat_text = "Remember to drink lots of water!"


	/// If this wound can generate a scar.
	var/can_scar = TRUE

	/// The default file we take our scar descriptions from, if we fail to get the ideal file.
	var/default_scar_file

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

	/// Who owns the body part that we're wounding
	var/mob/living/carbon/victim = null
	/// The bodypart we're parented to. Not guaranteed to be non-null, especially after/during removal or if we haven't been applied
	var/obj/item/bodypart/limb = null

	/// Specific items such as bandages or sutures that can try directly treating this wound
	var/list/treatable_by
	/// Specific items such as bandages or sutures that can try directly treating this wound only if the user has the victim in an aggressive grab or higher
	var/list/treatable_by_grabbed
	/// Any tools with any of the flags in this list will be usable to try directly treating this wound
	var/list/treatable_tools
	/// How long it will take to treat this wound with a standard effective tool, assuming it doesn't need surgery
	var/base_treat_time = 5 SECONDS

	/// Using this limb in a do_after interaction will multiply the length by this duration (arms)
	var/interaction_efficiency_penalty = 1
	/// Incoming damage on this limb will be multiplied by this, to simulate tenderness and vulnerability (mostly burns).
	var/damage_multiplier_penalty = 1
	/// If set and this wound is applied to a leg, we take this many deciseconds extra per step on this leg
	var/limp_slowdown
	/// If this wound has a limp_slowdown and is applied to a leg, it has this chance to limp each step
	var/limp_chance
	/// How much we're contributing to this limb's bleed_rate
	var/blood_flow

	/// How much having this wound will add to all future check_wounding() rolls on this limb, to allow progression to worse injuries with repeated damage
	var/threshold_penalty
	/// How much having this wound will add to all future check_wounding() rolls on this limb, but only for wounds of its own series
	var/series_threshold_penalty = 0
	/// If we need to process each life tick
	var/processes = FALSE

	/// If having this wound makes currently makes the parent bodypart unusable
	var/disabling

	/// What status effect we assign on application
	var/status_effect_type
	/// If we're operating on this wound and it gets healed, we'll nix the surgery too
	var/datum/surgery/attached_surgery
	/// if you're a lazy git and just throw them in cryo, the wound will go away after accumulating severity * [base_xadone_progress_to_qdel] power
	var/cryo_progress

	/// The base amount of [cryo_progress] required to have ourselves fully healed by cryo. Multiplied against severity.
	var/base_xadone_progress_to_qdel = 33

	/// What kind of scars this wound will create description wise once healed
	var/scar_keyword = "generic"
	/// If we've already tried scarring while removing (remove_wound can be called twice in a del chain, let's be nice to our code yeah?) TODO: make this cleaner
	var/already_scarred = FALSE
	/// The source of how we got the wound, typically a weapon.
	var/wound_source

	/// What flags apply to this wound
	var/wound_flags = (ACCEPTS_GAUZE)

	/// The unique ID of our wound for use with [actionspeed_mod]. Defaults to REF(src).
	var/unique_id
	/// The actionspeed modifier we will use in case we are on the arms and have a interaction penalty. Qdelled on destroy.
	var/datum/actionspeed_modifier/wound_interaction_inefficiency/actionspeed_mod

/datum/wound/New()
	. = ..()

	unique_id = generate_unique_id()
	update_actionspeed_modifier()

/datum/wound/Destroy()
	QDEL_NULL(attached_surgery)
	if (limb)
		remove_wound()

	QDEL_NULL(actionspeed_mod)

	return ..()

/// If we should have an actionspeed_mod, ensures we do and updates its slowdown. Otherwise, ensures we dont have one
/// by qdeleting any existing modifier.
/datum/wound/proc/update_actionspeed_modifier()
	if (should_have_actionspeed_modifier())
		if (!actionspeed_mod)
			generate_actionspeed_modifier()
		actionspeed_mod.multiplicative_slowdown = get_effective_actionspeed_modifier()
		victim?.update_actionspeed()
	else
		remove_actionspeed_modifier()

/// Returns TRUE if we have an interaction_efficiency_penalty, and if we are on the arms, FALSE otherwise.
/datum/wound/proc/should_have_actionspeed_modifier()
	return (limb && victim && (limb.body_zone == BODY_ZONE_L_ARM || limb.body_zone == BODY_ZONE_R_ARM) && interaction_efficiency_penalty != 0)

/// If we have no actionspeed_mod, generates a new one with our unique ID, sets actionspeed_mod to it, then returns it.
/datum/wound/proc/generate_actionspeed_modifier()
	RETURN_TYPE(/datum/actionspeed_modifier)

	if (actionspeed_mod)
		return actionspeed_mod

	var/datum/actionspeed_modifier/wound_interaction_inefficiency/new_modifier = new /datum/actionspeed_modifier/wound_interaction_inefficiency(unique_id, src)
	new_modifier.multiplicative_slowdown = get_effective_actionspeed_modifier()
	victim?.add_actionspeed_modifier(new_modifier)

	actionspeed_mod = new_modifier
	return actionspeed_mod

/// If we have an actionspeed_mod, qdels it and sets our ref of it to null.
/datum/wound/proc/remove_actionspeed_modifier()
	if (!actionspeed_mod)
		return

	victim?.remove_actionspeed_modifier(actionspeed_mod)
	QDEL_NULL(actionspeed_mod)

/// Generates the ID we use for [unique_id], which is also set as our actionspeed mod's ID
/datum/wound/proc/generate_unique_id()
	return REF(src) // unique, cannot change, a perfect id

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
/datum/wound/proc/apply_wound(obj/item/bodypart/L, silent = FALSE, datum/wound/old_wound = null, smited = FALSE, attack_direction = null, wound_source = "Unknown", replacing = FALSE)

	if (!can_be_applied_to(L, old_wound))
		qdel(src)
		return FALSE

	if(isitem(wound_source))
		var/obj/item/wound_item = wound_source
		src.wound_source = wound_item.name
	else
		src.wound_source = wound_source

	set_victim(L.owner)
	set_limb(L, replacing)
	LAZYADD(victim.all_wounds, src)
	LAZYADD(limb.wounds, src)
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

		if(severity > WOUND_SEVERITY_SEVERE)
			msg = "<b>[msg]</b>"
			vis_dist = DEFAULT_MESSAGE_RANGE

		victim.visible_message(msg, span_userdanger("Your [limb.plaintext_zone] [occur_text]!"), vision_distance = vis_dist)
		if(sound_effect)
			playsound(L.owner, sound_effect, sound_volume + (20 * severity), TRUE, falloff_exponent = SOUND_FALLOFF_EXPONENT + 2,  ignore_walls = FALSE, falloff_distance = 0)

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
	return pregen_data.can_be_applied_to(L, old_wound = old_wound)

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

/// Setter for [victim]. Should completely transfer signals, attributes, etc. To the new victim - if there is any, as it can be null.
/datum/wound/proc/set_victim(new_victim)
	if(victim)
		UnregisterSignal(victim, list(COMSIG_QDELETING, COMSIG_MOB_SWAP_HANDS, COMSIG_CARBON_POST_REMOVE_LIMB, COMSIG_CARBON_POST_ATTACH_LIMB))
		UnregisterSignal(victim, COMSIG_QDELETING)
		UnregisterSignal(victim, COMSIG_MOB_SWAP_HANDS)
		UnregisterSignal(victim, COMSIG_CARBON_POST_REMOVE_LIMB)
		if (actionspeed_mod)
			victim.remove_actionspeed_modifier(actionspeed_mod) // no need to qdelete it, just remove it from our victim

	remove_wound_from_victim()
	victim = new_victim
	if(victim)
		RegisterSignal(victim, COMSIG_QDELETING, PROC_REF(null_victim))
		RegisterSignals(victim, list(COMSIG_MOB_SWAP_HANDS, COMSIG_CARBON_POST_REMOVE_LIMB, COMSIG_CARBON_POST_ATTACH_LIMB), PROC_REF(add_or_remove_actionspeed_mod))

		if (limb)
			start_limping_if_we_should() // the status effect already handles removing itself
			add_or_remove_actionspeed_mod()

/// Proc called to change the variable `limb` and react to the event.
/datum/wound/proc/set_limb(obj/item/bodypart/new_value, replaced = FALSE)
	if(limb == new_value)
		return FALSE //Limb can either be a reference to something or `null`. Returning the number variable makes it clear no change was made.
	. = limb
	if(limb) // if we're nulling limb, we're basically detaching from it, so we should remove ourselves in that case
		UnregisterSignal(limb, COMSIG_QDELETING)
		UnregisterSignal(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_UNGAUZED))
		LAZYREMOVE(limb.wounds, src)
		limb.update_wounds(replaced)
		if (disabling)
			limb.remove_traits(list(TRAIT_PARALYSIS, TRAIT_DISABLED_BY_WOUND), REF(src))

	limb = new_value

	// POST-CHANGE

	if (limb)
		RegisterSignal(limb, COMSIG_QDELETING, PROC_REF(source_died))
		RegisterSignals(limb, list(COMSIG_BODYPART_GAUZED, COMSIG_BODYPART_UNGAUZED), PROC_REF(gauze_state_changed))
		if (disabling)
			limb.add_traits(list(TRAIT_PARALYSIS, TRAIT_DISABLED_BY_WOUND), REF(src))

		if (victim)
			start_limping_if_we_should() // the status effect already handles removing itself
			add_or_remove_actionspeed_mod()

		update_inefficiencies(replaced)

/datum/wound/proc/add_or_remove_actionspeed_mod()
	update_actionspeed_modifier()
	if (actionspeed_mod)
		if(victim.get_active_hand() == limb)
			victim.add_actionspeed_modifier(actionspeed_mod, TRUE)
		else
			victim.remove_actionspeed_modifier(actionspeed_mod)

/datum/wound/proc/start_limping_if_we_should()
	if ((limb.body_zone == BODY_ZONE_L_LEG || limb.body_zone == BODY_ZONE_R_LEG) && limp_slowdown > 0 && limp_chance > 0)
		victim.apply_status_effect(/datum/status_effect/limp)

/datum/wound/proc/source_died()
	SIGNAL_HANDLER
	qdel(src)

/// Remove the wound from whatever it's afflicting, and cleans up whateverstatus effects it had or modifiers it had on interaction times. ignore_limb is used for detachments where we only want to forget the victim
/datum/wound/proc/remove_wound(ignore_limb, replaced = FALSE)
	//TODO: have better way to tell if we're getting removed without replacement (full heal) scar stuff
	var/old_victim = victim
	var/old_limb = limb

	set_disabling(FALSE)
	if(limb && can_scar && !already_scarred && !replaced)
		already_scarred = TRUE
		var/datum/scar/new_scar = new
		new_scar.generate(limb, src)

	remove_actionspeed_modifier()

	null_victim() // we use the proc here because some behaviors may depend on changing victim to some new value

	if(limb && !ignore_limb)
		set_limb(null, replaced) // since we're removing limb's ref to us, we should do the same
		// if you want to keep the ref, do it externally, theres no reason for us to remember it

	if (ismob(old_victim))
		var/mob/mob_victim = old_victim
		SEND_SIGNAL(mob_victim, COMSIG_CARBON_POST_LOSE_WOUND, src, old_limb, ignore_limb, replaced)

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
	new_wound.apply_wound(cached_limb, old_wound = src, smited = smited, attack_direction = attack_direction, wound_source = wound_source, replacing = TRUE)
	. = new_wound
	qdel(src)

/// The immediate negative effects faced as a result of the wound
/datum/wound/proc/wound_injury(datum/wound/old_wound = null, attack_direction = null)
	return

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

/// Setter for [interaction_efficiency_penalty]. Updates the actionspeed of our actionspeed mod.
/datum/wound/proc/set_interaction_efficiency_penalty(new_value)
	var/should_update = (new_value != interaction_efficiency_penalty)

	interaction_efficiency_penalty = new_value

	if (should_update)
		update_actionspeed_modifier()

/// Returns a "adjusted" interaction_efficiency_penalty that will be used for the actionspeed mod.
/datum/wound/proc/get_effective_actionspeed_modifier()
	return interaction_efficiency_penalty - 1

/// Returns the decisecond multiplier of any click interactions, assuming our limb is being used.
/datum/wound/proc/get_action_delay_mult()
	SHOULD_BE_PURE(TRUE)

	return interaction_efficiency_penalty

/// Returns the decisecond increment of any click interactions, assuming our limb is being used.
/datum/wound/proc/get_action_delay_increment()
	SHOULD_BE_PURE(TRUE)

	return 0

/// Signal proc for if gauze has been applied or removed from our limb.
/datum/wound/proc/gauze_state_changed()
	SIGNAL_HANDLER

	if (wound_flags & ACCEPTS_GAUZE)
		update_inefficiencies()

/// Updates our limping and interaction penalties in accordance with our gauze.
/datum/wound/proc/update_inefficiencies(replaced_or_replacing = FALSE)
	if (wound_flags & ACCEPTS_GAUZE)
		if(limb.body_zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))
			if(limb.current_gauze?.splint_factor)
				limp_slowdown = initial(limp_slowdown) * limb.current_gauze.splint_factor
				limp_chance = initial(limp_chance) * limb.current_gauze.splint_factor
			else
				limp_slowdown = initial(limp_slowdown)
				limp_chance = initial(limp_chance)
		else if(limb.body_zone in GLOB.arm_zones)
			if(limb.current_gauze?.splint_factor)
				set_interaction_efficiency_penalty(1 + ((get_effective_actionspeed_modifier()) * limb.current_gauze.splint_factor))
			else
				set_interaction_efficiency_penalty(initial(interaction_efficiency_penalty))

		if(initial(disabling))
			set_disabling(isnull(limb.current_gauze))

		limb.update_wounds(replaced_or_replacing)

	start_limping_if_we_should()

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
	if(potential_treater.tool_behaviour in treatable_tools)
		return TRUE
	if(TOOL_CAUTERY in treatable_tools && potential_treater.get_temperature() && user == victim) // allow improvised cauterization on yourself without an aggro grab
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

/// Like try_treating() but for unhanded interactions, used by joint dislocations for manual bodypart chiropractice for example. Ignores thick material checks since you can pop an arm into place through a thick suit unlike using sutures
/datum/wound/proc/try_handling(mob/living/user)
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

	return handle_xadone_progress()

/// Does various actions based on [cryo_progress]. By default, qdeletes the wound past a certain threshold.
/datum/wound/proc/handle_xadone_progress()
	if(cryo_progress > get_xadone_progress_to_qdel())
		qdel(src)

/// Returns the amount of [cryo_progress] we need to be qdeleted.
/datum/wound/proc/get_xadone_progress_to_qdel()
	SHOULD_BE_PURE(TRUE)

	return base_xadone_progress_to_qdel * severity

/// When synthflesh is applied to the victim, we call this. No sense in setting up an entire chem reaction system for wounds when we only care for a few chems. Probably will change in the future
/datum/wound/proc/on_synthflesh(reac_volume)
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
	return "Type: [name]\nSeverity: [severity_text(simple = FALSE)]\nDescription: [desc]\nRecommended Treatment: [treat_text]"

/datum/wound/proc/get_simple_scanner_description(mob/user)
	return "[name] detected!\nRisk: [severity_text(simple = TRUE)]\nDescription: [simple_desc ? simple_desc : desc]\n<i>Treatment Guide: [simple_treat_text]</i>\n<i>Homemade Remedies: [homemade_treat_text]</i>"

/datum/wound/proc/severity_text(simple = FALSE)
	switch(severity)
		if(WOUND_SEVERITY_TRIVIAL)
			return "Trivial"
		if(WOUND_SEVERITY_MODERATE)
			return "Moderate" + (simple ? "!" : "")
		if(WOUND_SEVERITY_SEVERE)
			return "Severe" + (simple ? "!!" : "")
		if(WOUND_SEVERITY_CRITICAL)
			return "Critical" + (simple ? "!!!" : "")

/// Returns TRUE if our limb is the head or chest, FALSE otherwise.
/// Essential in the sense of "we cannot live without it".
/datum/wound/proc/limb_essential()
	return (limb.body_zone == BODY_ZONE_HEAD || limb.body_zone == BODY_ZONE_CHEST)

/// Getter proc for our scar_keyword, in case we might have some custom scar gen logic.
/datum/wound/proc/get_scar_keyword(obj/item/bodypart/scarred_limb, add_to_scars)
	return scar_keyword

/// Getter proc for our scar_file, in case we might have some custom scar gen logic.
/datum/wound/proc/get_scar_file(obj/item/bodypart/scarred_limb, add_to_scars)
	var/datum/wound_pregen_data/pregen_data = get_pregen_data()
	// basically we iterate over biotypes until we find the one we want
	// fleshy burns will look for flesh then bone
	// dislocations will look for flesh, then bone, then metal
	var/file = default_scar_file
	for (var/biotype as anything in pregen_data.scar_priorities)
		if (scarred_limb.biological_state & text2num(biotype))
			file = GLOB.biotypes_to_scar_file[biotype]
			break

	return file

/// Returns what string is displayed when a limb that has sustained this wound is examined
/// (This is examining the LIMB ITSELF, when it's not attached to someone.)
/datum/wound/proc/get_limb_examine_description()
	return

/// Gets the flat percentage chance increment of a dismember occuring, if a dismember is attempted (requires mangled flesh and bone). returning 15 = +15%.
/datum/wound/proc/get_dismember_chance_bonus(existing_chance)
	SHOULD_BE_PURE(TRUE)

	var/datum/wound_pregen_data/pregen_data = get_pregen_data()

	if (WOUND_BLUNT in pregen_data.required_wounding_types && severity >= WOUND_SEVERITY_CRITICAL)
		return WOUND_CRITICAL_BLUNT_DISMEMBER_BONUS // we only require mangled bone (T2 blunt), but if there's a critical blunt, we'll add 15% more

/// Returns our pregen data, which is practically guaranteed to exist, so this proc can safely be used raw.
/// In fact, since it's RETURN_TYPEd to wound_pregen_data, you can even directly access the variables without having to store the value of this proc in a typed variable.
/// Ex. get_pregen_data().wound_series
/datum/wound/proc/get_pregen_data()
	RETURN_TYPE(/datum/wound_pregen_data)

	return GLOB.all_wound_pregen_data[type]

#undef WOUND_CRITICAL_BLUNT_DISMEMBER_BONUS
