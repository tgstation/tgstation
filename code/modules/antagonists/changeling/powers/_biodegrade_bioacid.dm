/datum/reagent/toxin/acid/bio_acid
	name = "adaptive bio-acid"
	description = "An immensely strong, acidic substance of seemingly biological origin. It is teeming with microscopic\
	organisms that seem to alter its composition to most adaptively dissolve whatever it comes into contact with."
	color = "#9455ff"
	creation_purity = 100
	toxpwr = 0
	acidpwr = 100.0
	ph = 0.0
	chemical_flags = NONE // NONE to avoid this showing up in plants or mech syringes

/datum/reagent/toxin/acid/bio_acid/expose_mob(mob/living/exposed_mob, methods = TOUCH, reac_volume, show_message = TRUE, touch_protection = 0)
	if(IS_CHANGELING(exposed_mob))
		to_chat(exposed_mob, span_changeling("We excrete a bio-agent to neutralize the bio-acid. It is routine and reflexive to do so."))
		acidpwr = 0
		volume = min(0.1, volume)
	. = ..()
