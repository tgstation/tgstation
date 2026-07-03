///amount of reagent to inject per time
#define REAGENT_AMOUNT "reagent_amount"
///amount of reagent to inject before the implant stops injecting
#define REAGENT_THRESHOLD "reagent_threshold"
///cooldown for reagent synthesis
#define COOLDOWN_PUMP "pump"

/obj/item/organ/cyberimp/chest/pump
	name = "pump"
	desc = "Маленькая помпа, используемая для инъекции реагентов в кровоток."
	icon_state = "nutriment_implant"
	aug_overlay = "nutripump"
	slot = ORGAN_SLOT_STOMACH_AID
	var/cooldown_time = 5 SECONDS
	/**
	 * list of reagents with their injection and threshold amounts
	 * * REAGENT_AMOUNT - amount of reagent to inject per time
	 * * REAGENT_THRESHOLD - amount of reagent to inject before the implant stops injecting
	 */
	var/list/reagent_data = list()
	/// time between injections

/obj/item/organ/cyberimp/chest/pump/on_life(seconds_per_tick, times_fired)
	if(!TIMER_COOLDOWN_FINISHED(src, COOLDOWN_PUMP))
		return ..()

	for(var/key,value in reagent_data)
		var/reagent_type = key
		var/list/reagent_data_value = value
		var/datum/reagent/reagent_inside_owner = owner.reagents.has_reagent(reagent_type)
		if(!reagent_inside_owner || reagent_inside_owner.volume < reagent_data_value[REAGENT_THRESHOLD])
			owner.reagents.add_reagent(reagent_type, reagent_data_value[REAGENT_AMOUNT])

	if(custom_check(seconds_per_tick, times_fired))
		custom_effect(seconds_per_tick, times_fired)

	TIMER_COOLDOWN_START(src, COOLDOWN_PUMP, cooldown_time)
	return ..()

/**
 * This is a stub, it should be overridden by the implant
 * to check if the implant can be used or not for the specific actions.
*/
/obj/item/organ/cyberimp/chest/pump/proc/custom_check(seconds_per_tick, times_fired)
	return FALSE

/**
 * This is a stub, it should be overridden by the implant
 * to apply the specific effect of the implant.
*/
/obj/item/organ/cyberimp/chest/pump/proc/custom_effect(seconds_per_tick, times_fired)
	return

/obj/item/organ/cyberimp/chest/pump/centcom
	name = "combat medicine pump"
	desc = "Маленькая помпа, используемая для инъекции крайне эффективных препаратов в кровоток."
	reagent_data = list(
		/datum/reagent/medicine/syndicate_nanites = list(
			REAGENT_AMOUNT = 5,
			REAGENT_THRESHOLD = 20
		),
		/datum/reagent/medicine/leporazine = list(
			REAGENT_AMOUNT = 2,
			REAGENT_THRESHOLD = 8
		),
		/datum/reagent/medicine/synaptizine = list(
			REAGENT_AMOUNT = 2,
			REAGENT_THRESHOLD = 4
		),
		/datum/reagent/medicine/coagulant = list(
			REAGENT_AMOUNT = 4,
			REAGENT_THRESHOLD = 16
		),
			/datum/reagent/medicine/salglu_solution = list(
			REAGENT_AMOUNT = 10,
			REAGENT_THRESHOLD = 50
		)
	)

/obj/item/organ/cyberimp/chest/pump/centcom/custom_check(seconds_per_tick, times_fired)
	return owner.nutrition <= NUTRITION_LEVEL_HUNGRY

/obj/item/organ/cyberimp/chest/pump/centcom/custom_effect(seconds_per_tick, times_fired)
	. = ..()
	to_chat(owner, span_notice("Вы чувствуете себя менее голодным..."))
	owner.adjust_nutrition(25 * seconds_per_tick)

/obj/item/organ/cyberimp/chest/pump/sansufentanyl
	name = "sansufentanyl pump"
	desc = "Помпа, используемая для инъекции синтетического опиоида в фент-реактор. Жизненно важный механизм для функционирования фент-дроидов"
	reagent_data = list(
		/datum/reagent/medicine/sansufentanyl = list(
			REAGENT_AMOUNT = 1,
			REAGENT_THRESHOLD = 4
		)
	)

#undef REAGENT_AMOUNT
#undef REAGENT_THRESHOLD
#undef COOLDOWN_PUMP
