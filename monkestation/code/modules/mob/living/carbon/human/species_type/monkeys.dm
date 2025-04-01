/datum/species/monkey/on_species_gain(mob/living/carbon/human/idiot_who_gained_species, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(idiot_who_gained_species, COMSIG_LIVING_DEATH, PROC_REF(spec_death))

/datum/species/monkey/on_species_loss(mob/living/carbon/human/idiot_who_lost_species)
	. = ..()
	UnregisterSignal(idiot_who_lost_species, COMSIG_LIVING_DEATH)

/datum/species/monkey/proc/spec_death(mob/living/carbon/human/H, gibbed)
	#ifdef UNIT_TESTS
		return
	#endif

	if (gibbed && H)
		explosion(H, heavy_impact_range = 2, light_impact_range = 4) // Smol boom.
	else if (!QDELETED(H) && H.stat == DEAD && H.getBruteLoss() + H.getFireLoss() >= 100) // Xenobio will live. FOR NOW.
		INVOKE_ASYNC(src, PROC_REF(oh_no_how_could_this_happen), H)

/datum/species/monkey/proc/oh_no_how_could_this_happen(mob/living/carbon/human/explosive_idiot)
	sleep(1 SECONDS)

	if (!beep_loop(repeats = 5, interval = 0.5 SECONDS, volume = 30, explosive_idiot = explosive_idiot))
		return
	if (!beep_loop(repeats = 10, interval = 0.3 SECONDS, volume = 40, explosive_idiot = explosive_idiot))
		return
	if (!beep_loop(repeats = 15, interval = 0.1 SECONDS, volume = 50, explosive_idiot = explosive_idiot))
		return

	if (!QDELETED(explosive_idiot))
		explosion(explosive_idiot, devastation_range = 2, heavy_impact_range = 4, light_impact_range = 8) // BIG BOOM.

/datum/species/monkey/proc/beep_loop(repeats, interval, volume, mob/living/carbon/human/explosive_idiot)
	for (var/i in 1 to repeats)
		if (QDELETED(explosive_idiot))
			return FALSE
		if (explosive_idiot.stat != DEAD)
			playsound(explosive_idiot, 'sound/machines/buzz/buzz-sigh.ogg', vol = 50, vary = TRUE)
			return FALSE
		playsound(explosive_idiot, 'sound/items/timer.ogg', volume, vary = FALSE)
		explosive_idiot.add_atom_colour("#FF0000", ADMIN_COLOUR_PRIORITY)
		sleep(0.1 SECONDS)
		explosive_idiot.remove_atom_colour(ADMIN_COLOUR_PRIORITY)
		sleep(interval)
	return TRUE
