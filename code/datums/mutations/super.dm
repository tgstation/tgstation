/datum/mutation/human/superhuman
	name = "Super"
	desc = "A down-right supernatural mutation found only within sentient humanoids. It enhances many of a humanoid's physical and mental attributes to a near unprecedented state."
	quality = POSITIVE
	text_gain_indication = "<span class='notice'>You feel as though you've become far greater than you ever were.</span>"
	text_lose_indication = "<span class='notice'>Your super-humanity has been robbed from you.</span>"
	locked = TRUE
	difficulty = 40
	instability = 50
	species_allowed = list(SPECIES_HUMAN)
	conflicts = list(/datum/mutation/human/hulk)
	mutadone_proof = TRUE
	var/superhumanhealing = FALSE
	var/static/list/mutation_traits = list(
		TRAIT_NO_SLIP_WATER,
		TRAIT_IGNOREDAMAGESLOWDOWN,
		TRAIT_PUSHIMMUNE,
		TRAIT_STUNIMMUNE,
		TRAIT_NODISMEMBER,
	)

/datum/mutation/human/superhuman/on_acquiring(mob/living/carbon/human/acquirer)
	if(..())
		return

	superhumanhealing = TRUE
	acquirer.maxHealth += 50
	acquirer.physiology.brute_mod *= 0.90
	acquirer.physiology.burn_mod *= 0.90
	acquirer.physiology.tox_mod *= 0.90
	acquirer.physiology.oxy_mod *= 0.90
	acquirer.add_traits(mutation_traits, TRAIT_NO_SLIP_WATER)
	acquirer.add_traits(mutation_traits, TRAIT_IGNOREDAMAGESLOWDOWN)
	acquirer.add_traits(mutation_traits, TRAIT_PUSHIMMUNE)
	acquirer.add_traits(mutation_traits, TRAIT_STUNIMMUNE)
	acquirer.add_traits(mutation_traits, TRAIT_NODISMEMBER)

/datum/mutation/human/superhuman/on_losing(mob/living/carbon/human/owner)
	if(..())
		return

	superhumanhealing = FALSE
	owner.maxHealth -= 50
	owner.physiology.brute_mod *= 1.10
	owner.physiology.burn_mod *= 1.10
	owner.physiology.tox_mod *= 1.10
	owner.physiology.oxy_mod *= 1.10
	owner.remove_traits(mutation_traits, TRAIT_NO_SLIP_WATER)
	owner.remove_traits(mutation_traits, TRAIT_IGNOREDAMAGESLOWDOWN)
	owner.remove_traits(mutation_traits, TRAIT_PUSHIMMUNE)
	owner.remove_traits(mutation_traits, TRAIT_STUNIMMUNE)
	owner.remove_traits(mutation_traits, TRAIT_NODISMEMBER)

/datum/mutation/human/superhuman/on_life(seconds_per_tick, times_fired, mob/living/carbon/human/H)
	if(superhumanhealing)
		addtimer(CALLBACK(src, PROC_REF(heal)), 1 SECONDS)

/datum/mutation/human/superhuman/proc/heal()
	if(owner.getOxyLoss())
		owner.adjustOxyLoss(-0.25)
	if(owner.getBruteLoss())
		owner.adjustBruteLoss(-0.25)
	if(owner.getFireLoss())
		owner.adjustFireLoss(-0.25)
	if(owner.getToxLoss())
		owner.adjustToxLoss(-0.25)

	owner.adjustStaminaLoss(-2.5)

	owner.adjustOrganLoss(ORGAN_SLOT_BRAIN, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_HEART, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_EYES, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_EARS, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_LUNGS, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_LIVER, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_STOMACH, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_TONGUE, -0.25)
	owner.adjustOrganLoss(ORGAN_SLOT_APPENDIX, -0.25)
