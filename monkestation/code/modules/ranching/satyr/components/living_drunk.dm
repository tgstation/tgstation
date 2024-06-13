///basically inverts how inebriated works
/datum/component/living_drunk
	var/current_drunkness = 100
	var/max_drunkness = 100

	COOLDOWN_DECLARE(drank_grace)
	var/grace_period = 5 MINUTES
	var/booze_per_drunkness = 100

	var/drunk_state = 0

/datum/component/living_drunk/Initialize(grace_period = 5 MINUTES, booze_per_drunkness = 100)
	. = ..()
	src.grace_period = grace_period
	src.booze_per_drunkness = booze_per_drunkness

	ADD_TRAIT(parent, TRAIT_LIVING_DRUNK, INNATE_TRAIT)
	START_PROCESSING(SSobj, src)

/datum/component/living_drunk/Destroy(force, silent)
	REMOVE_TRAIT(parent, TRAIT_LIVING_DRUNK, INNATE_TRAIT)
	. = ..()

/datum/component/living_drunk/RegisterWithParent()
	. = ..()
	var/mob/living/living = parent
	RegisterSignal(living?.reagents, COMSIG_REAGENT_METABOLIZE_REAGENT, PROC_REF(on_reagent_metabolize))


/datum/component/living_drunk/UnregisterFromParent()
	. = ..()
	var/mob/living/living = parent
	UnregisterSignal(living?.reagents, COMSIG_REAGENT_METABOLIZE_REAGENT)

/datum/component/living_drunk/proc/on_reagent_metabolize(datum/reagents/source, datum/reagent/reagent, seconds_per_tick)
	if(!(reagent.type in typesof(/datum/reagent/consumable/ethanol)))
		return
	var/mob/living/living = parent
	var/metabolized_amount = living.metabolism_efficiency * reagent.metabolization_rate * seconds_per_tick

	var/drunk_increase = metabolized_amount / booze_per_drunkness
	current_drunkness = min(max_drunkness, current_drunkness + drunk_increase)
	COOLDOWN_START(src, drank_grace, grace_period)
	drunkness_change_effects()

/datum/component/living_drunk/process(seconds_per_tick)
	if(!COOLDOWN_FINISHED(src, drank_grace))
		return
	current_drunkness -= 0.1
	drunkness_change_effects()

/datum/component/living_drunk/proc/drunkness_change_effects()
	var/mob/living/living = parent
	if((current_drunkness <= 10) && drunk_state != 2)
		living.apply_status_effect(/datum/status_effect/inebriated/drunk, 80)
		drunk_state = 2
		return
	if((current_drunkness <= 30) && (drunk_state != 1 || drunk_state != 2))
		living.apply_status_effect(/datum/status_effect/inebriated/tipsy, 5)
		drunk_state = 1
		return

	if(current_drunkness > 30)
		drunk_state = 0
		living.remove_status_effect(/datum/status_effect/inebriated/tipsy)
		living.remove_status_effect(/datum/status_effect/inebriated/drunk)
