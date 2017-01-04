/datum/species/umbrage
	name = "Umbrage"
	id = "umbrage"
	darksight = 8
	invis_sight = SEE_INVISIBLE_MINIMUM
	sexes = 0
	blacklisted = 1
	meat = /obj/item/weapon/reagent_containers/food/snacks/meat/slab/human/mutant/shadow
	species_traits = list(NOBREATH, NOBLOOD, RADIMMUNE, VIRUSIMMUNE, NOGUNS)
	dangerous_existence = 1
	var/datum/action/innate/shadow/darkvision/vision_toggle

/datum/species/umbrage/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()
	vision_toggle = new
	vision_toggle.Grant(C)

/datum/species/umbrage/on_species_loss(mob/living/carbon/C)
	. = ..()
	if(vision_toggle)
		vision_toggle.Remove(C)

/datum/species/umbrage/spec_life(mob/living/carbon/human/H)
	var/turf/T = get_turf(H)
	var/lumcount = T.get_lumcount()
	if(lumcount > 3) //If it's light, we die very quickly
		H << "<span class='userdanger'>The light burns you!</span>"
		H << sound('sound/weapons/sear.ogg', volume = 75) //Spam text and a sound to aggressively say "hey, you're dying"
		H.adjustFireLoss(UMBRAGE_LIGHT_BURN)
	if(lumcount < 4) //But if it's dark, we heal, albeit slowly
		H.adjustBruteLoss(UMBRAGE_DARK_HEAL)
		H.adjustFireLoss(UMBRAGE_DARK_HEAL)
		H.adjustToxLoss(UMBRAGE_DARK_HEAL)
		H.adjustOxyLoss(UMBRAGE_DARK_HEAL)
		H.adjustCloneLoss(UMBRAGE_DARK_HEAL)
