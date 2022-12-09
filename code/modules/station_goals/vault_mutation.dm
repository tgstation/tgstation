/datum/mutation/human/breathless
	name = "Breathless"
	desc = "A mutation within the skin that allows for filtering and absorption of oxygen from the skin."
	text_gain_indication = "Your lungs feel great."
	text_lose_indication = "Your lungs feel normal again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/breathless/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	ADD_TRAIT(acquirer, TRAIT_NOBREATH, DNA_VAULT_TRAIT)

/datum/mutation/human/breathless/on_losing(mob/living/carbon/human/owner)//this shouldnt happen under normal condition but just to be sure
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, DNA_VAULT_TRAIT)

/datum/mutation/human/fast_runner
	name = "Fast runner"
	desc = "A mution within the leg muscles that allows it to operate at 20% more than the usual capacity."
	text_gain_indication = "Your legs feel faster and stronger."
	text_lose_indication = "Your legs feel weaker and slower."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/fast_runner/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/human/fast_runner/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/human/tough_skin
	name = "Tough skin"
	desc = "A mutation within the epidermis that makes it more resistant to tear."
	text_gain_indication = "Your skin feels tougher."
	text_lose_indication = "Your skin feels weaker."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/tough_skin/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.armor += 30
	ADD_TRAIT(acquirer, TRAIT_PIERCEIMMUNE, DNA_VAULT_TRAIT)

/datum/mutation/human/tough_skin/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.armor -= 30
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, DNA_VAULT_TRAIT)

/datum/mutation/human/dexterous
	name = "Dexterous"
	desc = "A mutation within the nerve system that allows for more responsive and quicker action."
	text_gain_indication = "Your limbs feel more dexterous and responsive."
	text_lose_indication = "Your limbs feel less dexterous and responsive."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/dexterous/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.next_move_modifier = 0.5

/datum/mutation/human/dexterous/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.next_move_modifier = 1

/datum/mutation/human/fire_immune
	name = "Fire immunity"
	desc = "A mutation within the body that allows it to become unflammable and withstand higher temperature."
	text_gain_indication = "Your body feels like it can withstand fire."
	text_lose_indication = "Your body feels vulnerable to fire again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/fire_immune/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	ADD_TRAIT(acquirer, TRAIT_RESISTHEAT, DNA_VAULT_TRAIT)
	ADD_TRAIT(acquirer, TRAIT_NOFIRE, DNA_VAULT_TRAIT)

/datum/mutation/human/fire_immune/on_losing(mob/living/carbon/human/owner)
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_RESISTHEAT, DNA_VAULT_TRAIT)
	REMOVE_TRAIT( owner, TRAIT_NOFIRE, DNA_VAULT_TRAIT)

/datum/mutation/human/stun_resistant
	name = "Stun resistant"
	desc = "A mutation within the nervouse system that allows it to recover from being knocked down."
	text_gain_indication = "You feel like you can recover from a fall easier."
	text_lose_indication = "You feel like recovering from a fall is a challenge again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/stun_resistant/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	var/datum/species/mutant = acquirer.dna.species
	mutant.stunmod = 0.5

/datum/mutation/human/stun_resistant/on_losing(mob/living/carbon/human/owner)
	. = ..()
	var/datum/species/mutant = owner.dna.species
	mutant.stunmod = 1

/datum/mutation/human/plasma_adapter
	name = "Plasma adaptation"
	desc = "A mutation in the lungs that provides it immunity to plasma's toxic nature."
	text_gain_indication = "Your lungs feel resistant to airborne contaminant."
	text_lose_indication = "Your lungs feel vulnerable to airborne contaminant again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/plasma_adapter/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	if(/obj/item/organ/internal/lungs in acquirer.internal_organs)
		var/obj/item/organ/internal/lungs/L = acquirer.internal_organs_slot[ORGAN_SLOT_LUNGS]
		L.plas_breath_dam_min = 0
		L.plas_breath_dam_max = 0

/datum/mutation/human/plasma_adapter/on_losing(mob/living/carbon/human/owner)
	. = ..()
	if(/obj/item/organ/internal/lungs in owner.internal_organs)
		var/obj/item/organ/internal/lungs/L = owner.internal_organs_slot[ORGAN_SLOT_LUNGS]
		L.plas_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
		L.plas_breath_dam_max = MAX_TOXIC_GAS_DAMAGE

