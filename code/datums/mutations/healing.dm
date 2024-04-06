/datum/mutation/human/regenerative
	name = "Regenerative"
	desc = "A medical marvel of the genetic field, this mutation causes the host to slowly recover from all forms of damage."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>Somehow, you feel... better.</span>"
	text_lose_indication = "<span class='notice'>Your stomach drops as your flesh suddenly shifts awkwardly to a halt.</span>"
	locked = TRUE
	difficulty = 12
	instability = 10
	energy_coeff = 1
	/*
	species_allowed = /datum/species/human
	*/
	mutadone_proof = TRUE
	var/regenerative = FALSE

/datum/mutation/human/regenerative/on_acquiring(mob/living/carbon/human/acquirer)
	if(..())
		return

	regenerative = TRUE

/datum/mutation/human/regenerative/on_losing(mob/living/carbon/human/owner)
	if(..())
		return

	regenerative = FALSE

/datum/mutation/human/regenerative/on_life(seconds_per_tick, times_fired, mob/living/carbon/human/H)
	if(regenerative)
		addtimer(CALLBACK(src, PROC_REF(heal)), 1 SECONDS)

/datum/mutation/human/regenerative/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-0.1)
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-0.1)
	if(owner.getFireLoss())
		owner.adjustFireLoss(-0.1)
	if(owner.getToxLoss())
		owner.adjustToxLoss(-0.1)

	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_HEART, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_EYES, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_EARS, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_TONGUE, -0.1)
	owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, -0.1)
