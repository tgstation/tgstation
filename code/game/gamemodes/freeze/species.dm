/datum/species/human/frosty
	id = "frosty"
	//TODO: meat
	burnmod = 1.1 //we don't like heat
	heatmod = 1.1
	coldmod = -0.5 //cold damage HEALS us
	specflags = list(NOBREATH, NOBLOOD)	//NOBREATH and NOBLOOD because we're frozen; our heart's not pumping.
								//we don't have COLDRES because without it we can use coldmod to heal.

/datum/species/human/frosty/spec_life(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_WELL_FED //we're frozen; our body's not really processing anything

/datum/species/human/frosty/scion
	id = "frost_scion"

/datum/species/human/frosty/pawn
	id = "frost_pawn"

/datum/species/human/frosty/scion/transformed
	name = "Scion"
	id = "frost_scion_t"
	burnmod = 1.7 //we REALLY don't like heat
	heatmod = 1.7
	coldmod = -1 //even stronger healing

