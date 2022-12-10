/datum/mutation/human/Breathless
	name = "Breathless"
	desc = "A mutation within the skin that allows for filtering and absorption of oxygen from the skin."
	text_gain_indication = "Your lungs feel great."
	text_lose_indication = "Your lungs feel normal again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/Breathless/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	ADD_TRAIT(acquirer, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/human/Breathless/on_losing(mob/living/carbon/human/owner)//this shouldnt happen under normal condition but just to be sure
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/human/Fast_Runner
	name = "Fast Runner"
	desc = "A mution within the leg muscles that allows it to operate at 20% more than the usual capacity."
	text_gain_indication = "Your legs feel faster and stronger."
	text_lose_indication = "Your legs feel weaker and slower."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/Fast_Runner/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/human/Fast_Runner/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/human/Tough_Skin
	name = "Tough Skin"
	desc = "A mutation within the epidermis that makes it more resistant to tear."
	text_gain_indication = "Your skin feels tougher."
	text_lose_indication = "Your skin feels weaker."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/Tough_Skin/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.armor += 30
	ADD_TRAIT(acquirer, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/human/Tough_Skin/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.armor -= 30
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/human/Dextrous
	name = "Dextrous"
	desc = "A mutation within the nerve system that allows for more responsive and quicker action."
	text_gain_indication = "Your limbs feel more dextrous and responsive."
	text_lose_indication = "Your limbs feel less dextrous and responsive."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/Tough_Skin/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.next_move_modifier *= 0.5

/datum/mutation/human/Tough_Skin/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.next_move_modifier /= 0.5

/datum/mutation/human/Fire_Immune
	name = "Fire Immunity"
	desc = "A mutation within the body that allows it to become unflammable and withstand higher temperature."
	text_gain_indication = "Your body feels like it can withstand fire."
	text_lose_indication = "Your body feels vulnerable to fire again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/Fire_Immune/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.burn_mod *= 0.5
	ADD_TRAIT(acquirer, TRAIT_RESISTHEAT, GENETIC_MUTATION)
	ADD_TRAIT(acquirer, TRAIT_NOFIRE, GENETIC_MUTATION)

/datum/mutation/human/Fire_Immune/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.burn_mod /= 0.5
	REMOVE_TRAIT(owner, TRAIT_RESISTHEAT, GENETIC_MUTATION)
	REMOVE_TRAIT( owner, TRAIT_NOFIRE, GENETIC_MUTATION)

/datum/mutation/human/Stun_Resistant
	name = "Stun Resistant"
	desc = "A mutation within the nervouse system that allows it to recover from being knocked down."
	text_gain_indication = "You feel like you can recover from a fall easier."
	text_lose_indication = "You feel like recovering from a fall is a challenge again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/Stun_Resistant/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.stun_mod *= 0.5

/datum/mutation/human/Stun_Resistant/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.stun_mod /= 0.5

/datum/mutation/human/Plasma_Adapter
	name = "Plasma Adaptation"
	desc = "A mutation in the lungs that provides it immunity to plasma's toxic nature."
	text_gain_indication = "Your lungs feel resistant to airborne contaminant."
	text_lose_indication = "Your lungs feel vulnerable to airborne contaminant again."
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/Plasma_Adapter/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	var/obj/item/organ/internal/lungs/improved_lungs = acquirer.getorganslot(ORGAN_SLOT_LUNGS)
	ADD_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	if(improved_lungs)
		improved_lungs.plas_breath_dam_min *= 0
		improved_lungs.plas_breath_dam_max *= 0

/datum/mutation/human/Plasma_Adapter/on_losing(mob/living/carbon/human/owner)
	. = ..()
	var/obj/item/organ/internal/lungs/improved_lungs = owner.getorganslot(ORGAN_SLOT_LUNGS)
	REMOVE_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	if(improved_lungs)
		improved_lungs.plas_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
		improved_lungs.plas_breath_dam_max = MAX_TOXIC_GAS_DAMAGE

