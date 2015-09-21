#define FROST_HEALING_FACTOR	5

/datum/species/human/frosty
	id = "frosty"
	//TODO: meat
	burnmod = 1.1 //we don't like heat
	heatmod = 1.1
	coldmod = -0.5
	specflags = list(NOBREATH, NOBLOOD, COLDRES) //NOBREATH and NOBLOOD because we're frozen; our heart's not pumping.

/datum/species/human/frosty/spec_life(mob/living/carbon/human/H)
	H.nutrition = NUTRITION_LEVEL_WELL_FED //we're frozen; our body's not really processing anything

	if(H.health < H.maxHealth)
		var/obj/structure/alien/weeds/frost/frost = locate() in get_turf(H)
		if(frost && frost.type_of_weed == initial(frost.type_of_weed)) //ensures that subtypes of weeds that aren't thematically weeds don't heal the alien
			var/heal_amt = FROST_HEALING_FACTOR * coldmod
			H.adjustBruteLoss(heal_amt)
			H.adjustFireLoss(heal_amt)
			H.adjustOxyLoss(heal_amt)
			H.adjustCloneLoss(heal_amt)

/datum/species/human/frosty/scion
	id = "frost_scion"

/datum/species/human/frosty/pawn
	id = "frost_pawn"

/datum/species/human/frosty/scion/transformed
	name = "Scion"
	id = "frost_scion_t"
	burnmod = 1.7 //we REALLY don't like heat
	heatmod = 1.7
	coldmod = 1 //even stronger healing

#undef FROST_HEALING_FACTOR