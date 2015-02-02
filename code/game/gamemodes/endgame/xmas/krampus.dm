/datum/species/krampus // /vg/
	name = "Krampus"
	override_icon = 'icons/mob/human_races/krampus.dmi'
	icobase = 'icons/mob/human_races/krampus.dmi'
	deform = 'icons/mob/human_races/krampus.dmi'
	language = "Clatter"
	attack_verb = "punch"

	//flags = IS_WHITELISTED /*| HAS_LIPS | HAS_TAIL | NO_EAT | NO_BREATHE | NON_GENDERED*/ | NO_BLOOD
	// These things are just really, really griefy. IS_WHITELISTED removed for now - N3X
	flags = NO_BLOOD | NO_BREATHE | NO_PAIN

	default_mutations=list(M_NO_BREATH,M_NO_SHOCK,M_RUN)
	
	warning_low_pressure = 50
	hazard_low_pressure = -1

	cold_level_1 = 50
	cold_level_2 = -1
	cold_level_3 = -1

	heat_level_1 = 2000
	heat_level_2 = 3000
	heat_level_3 = 4000
	

/mob/living/carbon/human/krampus
	real_name = "Krampus"
	status_flags = GODMODE|CANPUSH
	
	New(var/new_loc)
		h_style = "Bald"
		..(new_loc, "Krampus")
		maxHealth=999999
		health=999999
		

// I'M THE KRAMPUS, BITCH
/mob/living/carbon/human/krampus/Stun(amount)
	return

/mob/living/carbon/human/krampus/Weaken(amount)
	return

/mob/living/carbon/human/krampus/Paralyse(amount)
	return
	
/mob/living/carbon/human/krampus/eyecheck()
	return 2 // Immune to flashes
