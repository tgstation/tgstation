/datum/status_effect/regenerative_extract
	id = "Slime Regeneration"
	status_type = STATUS_EFFECT_UNIQUE
	duration = 15 SECONDS
	tick_interval = 0.2 SECONDS
	alert_type = /atom/movable/screen/alert/status_effect/regen_extract
	show_duration = TRUE
	/// The damage healed (for each type) per tick.
	/// This is multipled against the multiplier derived from cooldowns.
	var/base_healing_amt = 5
	/// The number multiplied against the base healing amount,
	/// used for the "diminishing returns" cooldown effect.
	var/multiplier = 1
	/// The multiplier that the cooldown applied after the effect ends will use.
	var/diminishing_multiplier = 0.75
	/// How long the subsequent cooldown effect will last.
	var/diminish_time = 45 SECONDS
	/// The maximum nutrition level this regenerative extract can heal up to.
	var/nutrition_heal_cap = NUTRITION_LEVEL_FED - 50
	/// Base traits given to the owner.
	var/static/list/given_traits = list(TRAIT_ANALGESIA, TRAIT_NOCRITDAMAGE)
	/// Extra traits given to the owner, added to the base traits.
	var/list/extra_traits

/datum/status_effect/regenerative_extract/on_apply()
	// So this seems weird, but this allows us to have multiple things affect the regen multiplier,
	// without doing something like hardcoding a `for(var/datum/status_effect/slime_regen_cooldown/cooldown in owner.status_effects)`
	// Instead, cooldown effects register the [COMSIG_SLIME_REGEN_CALC] signal, and can affect our multiplier via the pointer we pass.
	SEND_SIGNAL(owner, COMSIG_SLIME_REGEN_CALC, &multiplier)
	if(multiplier < 1)
		to_chat(owner, span_warning("The previous regenerative goo hasn't fully evaporated yet, weakening the new regenerative effect!"))
	owner.add_traits(islist(extra_traits) ? (given_traits + extra_traits) : given_traits, id)
	return TRUE

/datum/status_effect/regenerative_extract/on_remove()
	owner.remove_traits(islist(extra_traits) ? (given_traits + extra_traits) : given_traits, id)
	owner.apply_status_effect(/datum/status_effect/slime_regen_cooldown, diminishing_multiplier, diminish_time)

/datum/status_effect/regenerative_extract/tick(seconds_per_tick, times_fired)
	var/heal_amt = base_healing_amt * seconds_per_tick * multiplier
	heal_act(heal_amt)
	owner.updatehealth()

/datum/status_effect/regenerative_extract/proc/heal_act(heal_amt)
	if(!heal_amt)
		return
	heal_damage(heal_amt)
	heal_misc(heal_amt)
	if(iscarbon(owner))
		heal_organs(heal_amt)
		heal_wounds()

/datum/status_effect/regenerative_extract/proc/heal_damage(heal_amt)
	owner.heal_overall_damage(brute = heal_amt, burn = heal_amt, updating_health = FALSE)
	owner.stamina?.adjust(-heal_amt, forced = TRUE)
	owner.adjustOxyLoss(-heal_amt, updating_health = FALSE)
	owner.adjustToxLoss(-heal_amt, updating_health = FALSE, forced = TRUE)
	owner.adjustCloneLoss(-heal_amt, updating_health = FALSE)

/datum/status_effect/regenerative_extract/proc/heal_misc(heal_amt)
	owner.adjust_disgust(-heal_amt)
	if(owner.blood_volume < BLOOD_VOLUME_NORMAL)
		owner.blood_volume = min(owner.blood_volume + heal_amt, BLOOD_VOLUME_NORMAL)
	if((owner.nutrition < nutrition_heal_cap) && !HAS_TRAIT(owner, TRAIT_NOHUNGER))
		owner.nutrition = min(owner.nutrition + heal_amt, nutrition_heal_cap)

/datum/status_effect/regenerative_extract/proc/heal_organs(heal_amt)
	var/static/list/ignored_traumas
	if(!ignored_traumas)
		ignored_traumas = typecacheof(list(
			/datum/brain_trauma/hypnosis,
			/datum/brain_trauma/special/obsessed,
			/datum/brain_trauma/severe/split_personality/brainwashing,
		))
	var/mob/living/carbon/carbon_owner = owner
	for(var/obj/item/organ/organ in carbon_owner.organs)
		organ.apply_organ_damage(-heal_amt)
	// stupid manual trauma curing code, so you can't just remove trauma-based antags with one click
	var/obj/item/organ/internal/brain/brain = carbon_owner.get_organ_slot(ORGAN_SLOT_BRAIN)
	for(var/datum/brain_trauma/trauma as anything in shuffle(brain?.traumas))
		if(!is_type_in_typecache(trauma, ignored_traumas) && trauma.resilience <= TRAUMA_RESILIENCE_MAGIC)
			qdel(trauma)
			return

/datum/status_effect/regenerative_extract/proc/heal_wounds()
	var/mob/living/carbon/carbon_owner = owner
	if(length(carbon_owner.all_wounds))
		var/list/datum/wound/ordered_wounds = sort_list(carbon_owner.all_wounds, GLOBAL_PROC_REF(cmp_wound_severity_dsc))
		ordered_wounds[1]?.remove_wound()

/datum/status_effect/regenerative_extract/get_examine_text()
	return "[owner.p_They()] have a subtle, gentle glow to [owner.p_their()] skin, with slime soothing [owner.p_their()] wounds."

/atom/movable/screen/alert/status_effect/regen_extract
	name = "Slime Regeneration"
	desc = "A milky slime covers your skin, soothing and regenerating your injuries!"
	icon_state = "regenerative_core"
