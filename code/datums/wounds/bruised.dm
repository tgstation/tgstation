
/*
 * Bruise wounds
 *
 * Very minor, flavor wounds, for the Coroner to see what may have led up to an individual's death.
 */
/datum/wound_pregen_data/bruised
	abstract = TRUE

	required_wounding_type = WOUND_BLUNT
	required_limb_biostate = BIO_FLESH

	wound_series = WOUND_SERIES_BRUISING

/datum/wound/bruised
	name = "Bruising"
	undiagnosed_name = "Bruising"
	desc = "Patient's skin appears bruised, showing marks of resistance."
	sound_effect = null
	treat_text = "Will treat itself overtime."
	treat_text_short = "Best left alone."
	examine_desc = "appears bruised"
	occur_text = "gets bruised up"
	threshold_penalty = 1
	processes = TRUE
	default_scar_file = null//FLESH_SCAR_FILE
	severity = WOUND_SEVERITY_TRIVIAL
	simple_treat_text = null
	homemade_treat_text = null

	var/bruise_ticks = 25

/datum/wound/bruised/handle_process(seconds_per_tick)
	if (!victim || HAS_TRAIT(victim, TRAIT_STASIS) || !IS_DEAD_OR_FAKING(victim))
		return

	bruise_ticks--
	if(!bruise_ticks)
		to_chat(victim, span_green("The cut on your [limb.plaintext_zone] has [!limb.can_bleed() ? "healed up" : "stopped bleeding"]!"))
		qdel(src)

/datum/wound/bruised/on_xadone(power)
	. = ..()
	qdel(src)

/datum/wound/bruised/on_synthflesh(reac_volume)
	. = ..()
	qdel(src)

/*
/datum/wound/bruised/moderate
	name = "Rough Abrasion"
	desc = "Patient's skin has been badly scraped, generating moderate blood loss."
	treat_text = "Apply bandaging or suturing to the wound. \
		Follow up with food and a rest period."
	treat_text_short = "Apply bandaging or suturing."
	examine_desc = "has an open cut"
	occur_text = "is cut open, slowly leaking blood"
	sound_effect = 'sound/effects/wounds/blood1.ogg'
	severity = WOUND_SEVERITY_MODERATE
	initial_flow = 1.75
	minimum_flow = 0.5
	clot_rate = 0.04
	series_threshold_penalty = 10
	status_effect_type = /datum/status_effect/wound/slash/flesh/moderate
	scar_keyword = "slashmoderate"

	simple_treat_text = "<b>Bandaging</b> the wound will reduce blood loss, help the wound close by itself quicker, and speed up the blood recovery period. The wound itself can be slowly <b>sutured</b> shut."
	homemade_treat_text = "<b>Tea</b> stimulates the body's natural healing systems, slightly fastening clotting. The wound itself can be rinsed off on a sink or shower as well. Other remedies are unnecessary."

/datum/wound/bruised/moderate/update_descriptions()
	if(!limb.can_bleed())
		occur_text = "is cut open"
*/
