
/*
 * Bruise wounds
 *
 * Very minor, flavor wounds, for the Coroner to see what may have led up to an individual's death.
 */
/datum/wound_pregen_data/bruised
	abstract = FALSE
	wound_path_to_generate = /datum/wound/bruised
	required_limb_biostate = BIO_FLESH
	required_wounding_type = NONE
	wound_series = WOUND_SERIES_BRUISING

/datum/wound/bruised
	name = "Bruising"
	undiagnosed_name = "Bruising"
	desc = "Patient's skin appears bruised, showing marks of resistance."
	sound_effect = null
	treat_text = "Will treat itself overtime."
	treat_text_short = "Best left alone."
	examine_desc = null
	occur_text = "gets bruised up"
	threshold_penalty = 1
	processes = TRUE
	default_scar_file = null
	severity = WOUND_SEVERITY_TRIVIAL
	simple_treat_text = null
	homemade_treat_text = null

	var/bruise_ticks = 25

/datum/wound/bruised/handle_process(seconds_per_tick)
	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS) || IS_DEAD_OR_FAKING(victim))
		return

	bruise_ticks--
	if(!bruise_ticks)
		qdel(src)

/datum/wound/bruised/on_xadone(power)
	. = ..()
	qdel(src)

/datum/wound/bruised/on_synthflesh(reac_volume)
	. = ..()
	qdel(src)
