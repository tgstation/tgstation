
/datum/mutation/human/breathless
	name = "Breathless"
	desc = "A mutation within the skin that allows for filtering and absorption of oxygen from the skin."
	text_gain_indication = span_notice("Your lungs feel great.")
	text_lose_indication = span_warning("Your lungs feel normal again.")
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/breathless/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	ADD_TRAIT(acquirer, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/human/breathless/on_losing(mob/living/carbon/human/owner)//this shouldnt happen under normal condition but just to be sure
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/human/quick
	name = "Quick"
	desc = "A mution within the leg muscles that allows it to operate at 20% more than the usual capacity."
	text_gain_indication = span_notice("Your legs feel faster and stronger.")
	text_lose_indication = span_warning("Your legs feel weaker and slower.")
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/quick/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/human/quick/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/human/tough
	name = "Tough"
	desc = "A mutation within the epidermis that makes it more resistant to tear."
	text_gain_indication = span_notice("Your skin feels tougher.")
	text_lose_indication = span_warning("Your skin feels weaker.")
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/tough/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.brute_mod *= 0.7
	ADD_TRAIT(acquirer, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/human/tough/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.brute_mod /= 0.7
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/human/dextrous
	name = "Dextrous"
	desc = "A mutation within the nerve system that allows for more responsive and quicker action."
	text_gain_indication = span_notice("Your limbs feel more dextrous and responsive.")
	text_lose_indication = span_warning("Your limbs feel less dextrous and responsive.")
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/dextrous/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.next_move_modifier *= 0.5

/datum/mutation/human/dextrous/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.next_move_modifier /= 0.5

/datum/mutation/human/fire_immunity
	name = "Fire Immunity"
	desc = "A mutation within the body that allows it to become nonflammable and withstand higher temperature."
	text_gain_indication = span_notice("Your body feels like it can withstand fire.")
	text_lose_indication = span_warning("Your body feels vulnerable to fire again.")
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/fire_immunity/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.burn_mod *= 0.5
	ADD_TRAIT(acquirer, TRAIT_RESISTHEAT, GENETIC_MUTATION)
	ADD_TRAIT(acquirer, TRAIT_NOFIRE, GENETIC_MUTATION)

/datum/mutation/human/fire_immunity/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.burn_mod /= 0.5
	REMOVE_TRAIT(owner, TRAIT_RESISTHEAT, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_NOFIRE, GENETIC_MUTATION)

/datum/mutation/human/quick_recovery
	name = "Quick Recovery"
	desc = "A mutation within the nervouse system that allows it to recover from being knocked down."
	text_gain_indication = span_notice("You feel like you can recover from a fall easier.")
	text_lose_indication = span_warning("You feel like recovering from a fall is a challenge again.")
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/quick_recovery/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.stun_mod *= 0.5

/datum/mutation/human/quick_recovery/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.stun_mod /= 0.5

/datum/mutation/human/plasmocile
	name = "Plasmocile"
	desc = "A mutation in the lungs that provides it immunity to plasma's toxic nature."
	text_gain_indication = span_notice("Your lungs feel resistant to airborne contaminant.")
	text_lose_indication = span_warning("Your lungs feel vulnerable to airborne contaminant again.")
	locked = TRUE
	mutadone_proof = TRUE

/datum/mutation/human/plasmocile/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	var/obj/item/organ/internal/lungs/improved_lungs = acquirer.getorganslot(ORGAN_SLOT_LUNGS)
	ADD_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	if(improved_lungs)
		apply_buff(improved_lungs)
	RegisterSignal(acquirer, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(remove_modification))
	RegisterSignal(acquirer, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(reapply_modification))

/datum/mutation/human/plasmocile/on_losing(mob/living/carbon/human/owner)
	. = ..()
	var/obj/item/organ/internal/lungs/improved_lungs = owner.getorganslot(ORGAN_SLOT_LUNGS)
	REMOVE_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN)
	if(improved_lungs)
		remove_buff(improved_lungs)

/datum/mutation/human/plasmocile/proc/remove_modification(mob/source, obj/item/organ/old_organ)
	SIGNAL_HANDLER

	if(istype(old_organ, /obj/item/organ/internal/lungs))
		remove_buff(old_organ)

/datum/mutation/human/plasmocile/proc/reapply_modification(mob/source, obj/item/organ/new_organ)
	SIGNAL_HANDLER

	if(istype(new_organ, /obj/item/organ/internal/lungs))
		apply_buff(new_organ)

/datum/mutation/human/plasmocile/proc/apply_buff(obj/item/organ/internal/lungs/our_lungs)
	our_lungs.plas_breath_dam_min *= 0
	our_lungs.plas_breath_dam_max *= 0

/datum/mutation/human/plasmocile/proc/remove_buff(obj/item/organ/internal/lungs/our_lungs)
	our_lungs.plas_breath_dam_min = initial(our_lungs.plas_breath_dam_min)
	our_lungs.plas_breath_dam_max = initial(our_lungs.plas_breath_dam_max)

