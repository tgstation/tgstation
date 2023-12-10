/datum/action/changeling/sting//parent path, not meant for users afaik
	name = "Tiny Prick"
	desc = "Stabby stabby"

/datum/action/changeling/sting/Trigger(trigger_flags)
	var/mob/user = owner
	if(!user || !user.mind)
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling)
		return
	if(!changeling.chosen_sting)
		set_sting(user)
	else
		unset_sting(user)
	return

/datum/action/changeling/sting/proc/set_sting(mob/user)
	to_chat(user, span_notice("We prepare our sting. Alt+click or click the middle mouse button on a target to sting them."))
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chosen_sting = src

	changeling.lingstingdisplay.icon_state = button_icon_state
	changeling.lingstingdisplay.SetInvisibility(0, id=type)

/datum/action/changeling/sting/proc/unset_sting(mob/user)
	to_chat(user, span_warning("We retract our sting, we can't sting anyone for now."))
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	changeling.chosen_sting = null

	changeling.lingstingdisplay.icon_state = null
	changeling.lingstingdisplay.RemoveInvisibility(type)

/mob/living/carbon/proc/unset_sting()
	if(mind)
		var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
		if(changeling?.chosen_sting)
			changeling.chosen_sting.unset_sting(src)

/datum/action/changeling/sting/can_sting(mob/user, mob/target)
	if(!..())
		return
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling.chosen_sting)
		to_chat(user, "We haven't prepared our sting yet!")
	if(!iscarbon(target))
		return
	if(!isturf(user.loc))
		return
	if(!length(get_path_to(user, target, max_distance = changeling.sting_range, simulated_only = FALSE)))
		return // no path within the sting's range is found. what a weird place to use the pathfinding system
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/changeling))
		sting_feedback(user, target)
		changeling.chem_charges -= chemical_cost
	return 1

/datum/action/changeling/sting/sting_feedback(mob/user, mob/target)
	if(!target)
		return
	to_chat(user, span_notice("We stealthily sting [target.name]."))
	if(target.mind && target.mind.has_antag_datum(/datum/antagonist/changeling))
		to_chat(target, span_warning("You feel a tiny prick."))
	return 1


/datum/action/changeling/sting/transformation
	name = "Transformation Sting"
	desc = "We silently sting an organism, injecting a retrovirus that forces them to transform."
	helptext = "The victim will transform much like a changeling would. \
		For complex humanoids, the transformation is temporarily, but the duration is paused while the victim is dead or in stasis. \
		For more simple humanoids, such as monkeys, the transformation is permanent. \
		Does not provide a warning to others. Mutations will not be transferred."
	button_icon_state = "sting_transform"
	chemical_cost = 33 // Low enough that you can sting only two people in quick succession
	dna_cost = 2
	/// A reference to our active profile, which we grab DNA from
	VAR_FINAL/datum/changeling_profile/selected_dna
	/// Duration of the sting
	var/sting_duration = 8 MINUTES

/datum/action/changeling/sting/transformation/Grant(mob/grant_to)
	. = ..()
	build_all_button_icons(UPDATE_BUTTON_NAME)

/datum/action/changeling/sting/transformation/update_button_name(atom/movable/screen/movable/action_button/button, force)
	. = ..()
	button.desc += " Lasts [DisplayTimeText(sting_duration)] for humans, but duration is paused while dead or in stasis."
	button.desc += " Costs [chemical_cost] chemicals."

/datum/action/changeling/sting/transformation/Destroy()
	selected_dna = null
	return ..()

/datum/action/changeling/sting/transformation/set_sting(mob/user)
	selected_dna = null
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	var/datum/changeling_profile/new_selected_dna = changeling.select_dna()
	if(QDELETED(src) || QDELETED(changeling) || QDELETED(user))
		return
	if(!new_selected_dna || changeling.chosen_sting || selected_dna) // selected other sting or other DNA while sleeping
		return
	selected_dna = new_selected_dna
	return ..()

/datum/action/changeling/sting/transformation/can_sting(mob/user, mob/living/carbon/target)
	. = ..()
	if(!.)
		return
	// Similar checks here are ran to that of changeling can_absorb_dna -
	// Logic being that if their DNA is incompatible with us, it's also bad for transforming
	if(!iscarbon(target) \
		|| !target.has_dna() \
		|| HAS_TRAIT(target, TRAIT_HUSK) \
		|| HAS_TRAIT(target, TRAIT_BADDNA) \
		|| (HAS_TRAIT(target, TRAIT_NO_DNA_COPY) && !ismonkey(target))) // sure, go ahead, make a monk-clone
		user.balloon_alert(user, "incompatible DNA!")
		return FALSE
	if(target.has_status_effect(/datum/status_effect/temporary_transformation/trans_sting))
		user.balloon_alert(user, "already transformed!")
		return FALSE
	return TRUE

/datum/action/changeling/sting/transformation/sting_action(mob/living/user, mob/living/target)
	var/final_duration = sting_duration
	var/final_message = span_notice("We transform [target] into [selected_dna.dna.real_name].")
	if(ismonkey(target))
		final_duration = INFINITY
		final_message = span_warning("Our genes cry out as we transform the lesser form of [target] into [selected_dna.dna.real_name] permanently!")

	if(target.apply_status_effect(/datum/status_effect/temporary_transformation/trans_sting, final_duration, selected_dna.dna))
		..()
		log_combat(user, target, "stung", "transformation sting", " new identity is '[selected_dna.dna.real_name]'")
		to_chat(user, final_message)
		return TRUE
	return FALSE

/datum/action/changeling/sting/false_armblade
	name = "False Armblade Sting"
	desc = "We silently sting a human, injecting a retrovirus that mutates their arm to temporarily appear as an armblade. Costs 20 chemicals."
	helptext = "The victim will form an armblade much like a changeling would, except the armblade is dull and useless."
	button_icon_state = "sting_armblade"
	chemical_cost = 20
	dna_cost = 1

/obj/item/melee/arm_blade/false
	desc = "A grotesque mass of flesh that used to be your arm. Although it looks dangerous at first, you can tell it's actually quite dull and useless."
	force = 5 //Basically as strong as a punch
	fake = TRUE

/datum/action/changeling/sting/false_armblade/can_sting(mob/user, mob/target)
	if(!..())
		return
	if(isliving(target))
		var/mob/living/L = target
		if((HAS_TRAIT(L, TRAIT_HUSK)) || !L.has_dna())
			user.balloon_alert(user, "incompatible DNA!")
			return FALSE
	return TRUE

/datum/action/changeling/sting/false_armblade/sting_action(mob/user, mob/target)

	var/obj/item/held = target.get_active_held_item()
	if(held && !target.dropItemToGround(held))
		to_chat(user, span_warning("[held] is stuck to [target.p_their()] hand, you cannot grow a false armblade over it!"))
		return

	..()
	log_combat(user, target, "stung", object = "false armblade sting")
	if(ismonkey(target))
		to_chat(user, span_notice("Our genes cry out as we sting [target.name]!"))

	var/obj/item/melee/arm_blade/false/blade = new(target,1)
	target.put_in_hands(blade)
	target.visible_message(span_warning("A grotesque blade forms around [target.name]\'s arm!"), span_userdanger("Your arm twists and mutates, transforming into a horrific monstrosity!"), span_hear("You hear organic matter ripping and tearing!"))
	playsound(target, 'sound/effects/blobattack.ogg', 30, TRUE)

	addtimer(CALLBACK(src, PROC_REF(remove_fake), target, blade), 600)
	return TRUE

/datum/action/changeling/sting/false_armblade/proc/remove_fake(mob/target, obj/item/melee/arm_blade/false/blade)
	playsound(target, 'sound/effects/blobattack.ogg', 30, TRUE)
	target.visible_message("<span class='warning'>With a sickening crunch, \
	[target] reforms [target.p_their()] [blade.name] into an arm!</span>",
	span_warning("[blade] reforms back to normal."),
	"<span class='italics>You hear organic matter ripping and tearing!</span>")

	qdel(blade)
	target.update_held_items()

/datum/action/changeling/sting/extract_dna
	name = "Extract DNA Sting"
	desc = "We stealthily sting a target and extract their DNA. Costs 25 chemicals."
	helptext = "Will give you the DNA of your target, allowing you to transform into them."
	button_icon_state = "sting_extract"
	chemical_cost = 25
	dna_cost = 0

/datum/action/changeling/sting/extract_dna/can_sting(mob/user, mob/target)
	if(..())
		var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
		return changeling.can_absorb_dna(target)

/datum/action/changeling/sting/extract_dna/sting_action(mob/user, mob/living/carbon/human/target)
	..()
	log_combat(user, target, "stung", "extraction sting")
	var/datum/antagonist/changeling/changeling = user.mind.has_antag_datum(/datum/antagonist/changeling)
	if(!changeling.has_profile_with_dna(target.dna))
		changeling.add_new_profile(target)
	return TRUE

/datum/action/changeling/sting/mute
	name = "Mute Sting"
	desc = "We silently sting a human, completely silencing them for a short time. Costs 20 chemicals."
	helptext = "Does not provide a warning to the victim that they have been stung, until they try to speak and cannot."
	button_icon_state = "sting_mute"
	chemical_cost = 20
	dna_cost = 2

/datum/action/changeling/sting/mute/sting_action(mob/user, mob/living/carbon/target)
	..()
	log_combat(user, target, "stung", "mute sting")
	target.adjust_silence(1 MINUTES)
	return TRUE

/datum/action/changeling/sting/blind
	name = "Blind Sting"
	desc = "We temporarily blind our victim. Costs 25 chemicals."
	helptext = "This sting completely blinds a target for a short time, and leaves them with blurred vision for a long time. Does not work if target has robotic or missing eyes."
	button_icon_state = "sting_blind"
	chemical_cost = 25
	dna_cost = 1

/datum/action/changeling/sting/blind/sting_action(mob/user, mob/living/carbon/target)
	var/obj/item/organ/internal/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
	if(!eyes)
		user.balloon_alert(user, "no eyes!")
		return FALSE

	if(IS_ROBOTIC_ORGAN(eyes))
		user.balloon_alert(user, "robotic eyes!")
		return FALSE

	..()
	log_combat(user, target, "stung", "blind sting")
	to_chat(target, span_danger("Your eyes burn horrifically!"))
	eyes.apply_organ_damage(eyes.maxHealth * 0.8)
	target.adjust_temp_blindness(40 SECONDS)
	target.set_eye_blur_if_lower(80 SECONDS)
	return TRUE

/datum/action/changeling/sting/lsd
	name = "Hallucination Sting"
	desc = "We cause mass terror to our victim. Costs 10 chemicals."
	helptext = "We evolve the ability to sting a target with a powerful hallucinogenic chemical. \
			The target does not notice they have been stung, and the effect occurs after 30 to 60 seconds."
	button_icon_state = "sting_lsd"
	chemical_cost = 10
	dna_cost = 1

/datum/action/changeling/sting/lsd/sting_action(mob/user, mob/living/carbon/target)
	..()
	log_combat(user, target, "stung", "LSD sting")
	addtimer(CALLBACK(src, PROC_REF(hallucination_time), target), rand(30 SECONDS, 60 SECONDS))
	return TRUE

/datum/action/changeling/sting/lsd/proc/hallucination_time(mob/living/carbon/target)
	if(QDELETED(src) || QDELETED(target))
		return
	target.adjust_hallucinations(180 SECONDS)

/datum/action/changeling/sting/cryo
	name = "Cryogenic Sting"
	desc = "We silently sting our victim with a cocktail of chemicals that freezes them from the inside. Costs 15 chemicals."
	helptext = "Does not provide a warning to the victim, though they will likely realize they are suddenly freezing."
	button_icon_state = "sting_cryo"
	chemical_cost = 15
	dna_cost = 2

/datum/action/changeling/sting/cryo/sting_action(mob/user, mob/target)
	..()
	log_combat(user, target, "stung", "cryo sting")
	if(target.reagents)
		target.reagents.add_reagent(/datum/reagent/consumable/frostoil, 30)
	return TRUE
