
/datum/mutation/breathless
	name = "Breathless"
	desc = "A mutation within the skin that allows for filtering and absorption of oxygen from the skin."
	text_gain_indication = span_notice("Ваши лёгкие чувствуют себя прекрасно.")
	text_lose_indication = span_warning("Ваши лёгкие чувствуют себя как обычно.")
	locked = TRUE

/datum/mutation/breathless/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	ADD_TRAIT(acquirer, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/breathless/on_losing(mob/living/carbon/human/owner)//this shouldnt happen under normal condition but just to be sure
	. = ..()
	REMOVE_TRAIT(owner, TRAIT_NOBREATH, GENETIC_MUTATION)

/datum/mutation/quick
	name = "Quick"
	desc = "Мутация мышц ног, которая позволяет им функционировать на 7.5% эффективней, чем обычно."
	text_gain_indication = span_notice("Ваши ноги становятся сильнее и быстрее.")
	text_lose_indication = span_warning("Ваши ноги становятся слабее и медленнее.")
	locked = TRUE

/datum/mutation/quick/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.add_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/quick/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.remove_movespeed_modifier(/datum/movespeed_modifier/dna_vault_speedup)

/datum/mutation/tough
	name = "Tough"
	desc = "A mutation within the epidermis that makes it more resistant to tear."
	text_gain_indication = span_notice("Ваша коже крепнет.")
	text_lose_indication = span_warning("Ваша кожа снова нормальная.")
	locked = TRUE

/datum/mutation/tough/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.brute_mod *= 0.7
	ADD_TRAIT(acquirer, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/tough/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.brute_mod /= 0.7
	REMOVE_TRAIT(owner, TRAIT_PIERCEIMMUNE, GENETIC_MUTATION)

/datum/mutation/dextrous
	name = "Dextrous"
	desc = "A mutation within the nerve system that allows for more responsive and quicker action."
	text_gain_indication = span_notice("Ваши конечности чувствуются более ловкими и отзывчивыми.")
	text_lose_indication = span_warning("Ваши конечности чувствуются не такими ловкими и отзывчивыми.")
	locked = TRUE

/datum/mutation/dextrous/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.next_move_modifier *= 0.5

/datum/mutation/dextrous/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.next_move_modifier /= 0.5

/datum/mutation/fire_immunity
	name = "Fire Immunity"
	desc = "A mutation within the body that allows it to become nonflammable and withstand higher temperature."
	text_gain_indication = span_notice("Вы чувствуете, что ваше тело может противостоять огню.")
	text_lose_indication = span_warning("Вы чувствуете, что ваше тело уязвимо для огня.")
	locked = TRUE

/datum/mutation/fire_immunity/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.burn_mod *= 0.5
	acquirer.add_traits(list(TRAIT_RESISTHEAT, TRAIT_NOFIRE), GENETIC_MUTATION)

/datum/mutation/fire_immunity/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.burn_mod /= 0.5
	owner.remove_traits(list(TRAIT_RESISTHEAT, TRAIT_NOFIRE), GENETIC_MUTATION)

/datum/mutation/quick_recovery
	name = "Quick Recovery"
	desc = "A mutation within the nervous system that allows it to recover from being knocked down."
	text_gain_indication = span_notice("Вы чувствуете, что вам легче оправиться от падения.")
	text_lose_indication = span_warning("Вы чувствуете, что восстановление после падения снова является тяжёлой задачей.")
	locked = TRUE

/datum/mutation/quick_recovery/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	acquirer.physiology.stun_mod *= 0.5

/datum/mutation/quick_recovery/on_losing(mob/living/carbon/human/owner)
	. = ..()
	owner.physiology.stun_mod /= 0.5

/datum/mutation/plasmocile
	name = "Plasmocile"
	desc = "A mutation in the lungs that provides it immunity to plasma's toxic nature."
	text_gain_indication = span_notice("Вы чувствуете, что ваши лёгкие более устойчивы к загрязнениям в воздухе.")
	text_lose_indication = span_warning("Вы чувствуете, что ваши лёгкие менее устойчивы к загрязнениям в воздухе.")
	locked = TRUE

/datum/mutation/plasmocile/on_acquiring(mob/living/carbon/human/acquirer)
	. = ..()
	var/obj/item/organ/lungs/improved_lungs = acquirer.get_organ_slot(ORGAN_SLOT_LUNGS)
	ADD_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	if(improved_lungs)
		apply_buff(improved_lungs)
	RegisterSignal(acquirer, COMSIG_CARBON_LOSE_ORGAN, PROC_REF(remove_modification))
	RegisterSignal(acquirer, COMSIG_CARBON_GAIN_ORGAN, PROC_REF(reapply_modification))

/datum/mutation/plasmocile/on_losing(mob/living/carbon/human/owner)
	. = ..()
	var/obj/item/organ/lungs/improved_lungs = owner.get_organ_slot(ORGAN_SLOT_LUNGS)
	REMOVE_TRAIT(owner, TRAIT_VIRUSIMMUNE, GENETIC_MUTATION)
	UnregisterSignal(owner, COMSIG_CARBON_LOSE_ORGAN)
	UnregisterSignal(owner, COMSIG_CARBON_GAIN_ORGAN)
	if(improved_lungs)
		remove_buff(improved_lungs)

/datum/mutation/plasmocile/proc/remove_modification(mob/source, obj/item/organ/old_organ)
	SIGNAL_HANDLER

	if(istype(old_organ, /obj/item/organ/lungs))
		remove_buff(old_organ)

/datum/mutation/plasmocile/proc/reapply_modification(mob/source, obj/item/organ/new_organ)
	SIGNAL_HANDLER

	if(istype(new_organ, /obj/item/organ/lungs))
		apply_buff(new_organ)

/datum/mutation/plasmocile/proc/apply_buff(obj/item/organ/lungs/our_lungs)
	our_lungs.plas_breath_dam_min *= 0
	our_lungs.plas_breath_dam_max *= 0

/datum/mutation/plasmocile/proc/remove_buff(obj/item/organ/lungs/our_lungs)
	our_lungs.plas_breath_dam_min = initial(our_lungs.plas_breath_dam_min)
	our_lungs.plas_breath_dam_max = initial(our_lungs.plas_breath_dam_max)

