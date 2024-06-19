//Called on /mob/living/carbon/Initialize(mapload), for the carbon mobs to register relevant signals.
/mob/living/carbon/register_init_signals()
	. = ..()

	//Traits that register add and remove
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_AGENDER), PROC_REF(on_agender_trait_gain))
	RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AGENDER), PROC_REF(on_agender_trait_loss))

	//Traits that register add only
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_NOBREATH), PROC_REF(on_nobreath_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_LIVERLESS_METABOLISM), PROC_REF(on_liverless_metabolism_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_VIRUSIMMUNE), PROC_REF(on_virusimmune_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_TOXIMMUNE), PROC_REF(on_toximmune_trait_gain))
	RegisterSignal(src, SIGNAL_ADDTRAIT(TRAIT_GENELESS), PROC_REF(on_geneless_trait_gain))

/**
 * On gain of TRAIT_AGENDER
 *
 * This will make the mob get it's gender set to PLURAL.
 */
/mob/living/carbon/proc/on_agender_trait_gain(datum/source)
	SIGNAL_HANDLER

	gender = PLURAL

/**
 * On removal of TRAIT_AGENDER
 *
 * This will make the mob get it's gender set to whatever the DNA says it should be.
 */
/mob/living/carbon/proc/on_agender_trait_loss(datum/source)
	SIGNAL_HANDLER

	//updates our gender to be whatever our DNA wants it to be
	switch(deconstruct_block(get_uni_identity_block(dna.unique_identity, DNA_GENDER_BLOCK), 3) || pick(G_MALE, G_FEMALE))
		if(G_MALE)
			gender = MALE
		if(G_FEMALE)
			gender = FEMALE
		else
			gender = PLURAL

/**
 * On gain of TRAIT_NOBREATH
 *
 * This will clear all alerts and moods related to breathing.
 */
/mob/living/carbon/proc/on_nobreath_trait_gain(datum/source)
	SIGNAL_HANDLER

	setOxyLoss(0, updating_health = TRUE, forced = TRUE)
	losebreath = 0
	failed_last_breath = FALSE

	clear_alert(ALERT_TOO_MUCH_OXYGEN)
	clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

	clear_alert(ALERT_TOO_MUCH_PLASMA)
	clear_alert(ALERT_NOT_ENOUGH_PLASMA)

	clear_alert(ALERT_TOO_MUCH_NITRO)
	clear_alert(ALERT_NOT_ENOUGH_NITRO)

	clear_alert(ALERT_TOO_MUCH_CO2)
	clear_alert(ALERT_NOT_ENOUGH_CO2)

	clear_alert(ALERT_TOO_MUCH_N2O)
	clear_alert(ALERT_NOT_ENOUGH_N2O)

	clear_mood_event("chemical_euphoria")
	clear_mood_event("smell")
	clear_mood_event("suffocation")

/**
 * On gain of TRAIT_LIVERLESS_METABOLISM
 *
 * This will clear all moods related to addictions and stop metabolization.
 */
/mob/living/carbon/proc/on_liverless_metabolism_trait_gain(datum/source)
	SIGNAL_HANDLER

	for(var/addiction_type in subtypesof(/datum/addiction))
		mind?.remove_addiction_points(addiction_type, MAX_ADDICTION_POINTS) //Remove the addiction!

	reagents.end_metabolization(keep_liverless = TRUE)

/**
 * On gain of TRAIT_VIRUSIMMUNE
 *
 * This will clear all diseases on the mob.
 */
/mob/living/carbon/proc/on_virusimmune_trait_gain(datum/source)
	SIGNAL_HANDLER

	for(var/datum/disease/disease as anything in diseases)
		disease.cure(FALSE)

/**
 * On gain of TRAIT_TOXIMMUNE
 *
 * This will clear all toxin damage on the mob.
 */
/mob/living/carbon/proc/on_toximmune_trait_gain(datum/source)
	SIGNAL_HANDLER

	setToxLoss(0, updating_health = TRUE, forced = TRUE)

/**
 * On gain of TRAIT_GENELLESS
 *
 * This will clear all DNA mutations on on the mob.
 */
/mob/living/carbon/proc/on_geneless_trait_gain(datum/source)
	SIGNAL_HANDLER

	dna?.remove_all_mutations()
