//Called on /mob/living/carbon/Initialize(), for the carbon mobs to register relevant signals.
/mob/living/carbon/register_init_signals()
	. = ..()

	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOBREATH), .proc/on_nobreath_trait_gain)
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOMETABOLISM), .proc/on_nometabolism_trait_gain)

/**
 * On gain of TRAIT_NOBREATH
 *
 * This will clear all alerts and moods related to breathing.
 */
/mob/living/carbon/proc/on_nobreath_trait_gain(datum/source)
	SIGNAL_HANDLER

	failed_last_breath = FALSE
	clear_alert("too_much_oxy")
	clear_alert("not_enough_oxy")
	clear_alert("too_much_tox")
	clear_alert("not_enough_tox")
	clear_alert("nitro")
	clear_alert("too_much_nitro")
	clear_alert("not_enough_nitro")
	clear_alert("too_much_co2")
	clear_alert("not_enough_co2")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "smell")
	SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "suffocation")
/**
 * On gain of TRAIT_NOMETABOLISM
 *
 * This will clear all moods related to addictions and stop metabolization.
 */
/mob/living/carbon/proc/on_nometabolism_trait_gain(datum/source)
	SIGNAL_HANDLER

	if(reagents.addiction_list)
		to_chat(source, "<span class='notice'>You feel like you've gotten over your need for drugs.</span>")
		for(var/a in reagents.addiction_list)
			var/datum/reagent/R = a
			SEND_SIGNAL(src, COMSIG_CLEAR_MOOD_EVENT, "[R.type]_overdose")
			LAZYREMOVE(reagents.addiction_list, R)
			qdel(R)
	reagents.end_metabolization(keep_liverless = TRUE)
