/datum/quirk/hemiplegic
	name = "Hemiplegic"
	desc = "Половина вашего тела не работает. Ничто никогда это не исправит."
	icon = FA_ICON_CIRCLE_HALF_STROKE
	value = -10 // slightly more bearable than paraplegic but not by much
	gain_text = null // Handled by trauma.
	lose_text = null
	medical_record_text = "Пациент имеет не поддающееся лечению нарушение двигательной функции половины своего тела."
	hardcore_value = 10
	mail_goodies = list(
		/obj/item/stack/sheet/mineral/uranium/half, //half a stack of a material that has a half life
		/obj/item/reagent_containers/cup/glass/drinkingglass/filled/half_full,
	)

/datum/quirk_constant_data/hemiplegic
	associated_typepath = /datum/quirk/hemiplegic
	customization_options = list(/datum/preference/choiced/hemiplegic)

/datum/quirk/hemiplegic/add(client/client_source)
	var/datum/brain_trauma/severe/paralysis/hemiplegic/side_choice = GLOB.side_choice_hemiplegic[client_source?.prefs?.read_preference(/datum/preference/choiced/hemiplegic)]
	if(isnull(side_choice))  // Client gone or they chose a random side
		side_choice = GLOB.side_choice_hemiplegic[pick(GLOB.side_choice_hemiplegic)]

	var/mob/living/carbon/human/human_holder = quirk_holder

	medical_record_text = "Пациент имеет не поддающееся лечению нарушение двигательной функции [side_choice::paralysis_type]."
	human_holder.gain_trauma(side_choice, TRAUMA_RESILIENCE_ABSOLUTE)

/datum/quirk/hemiplegic/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.cure_trauma_type(/datum/brain_trauma/severe/paralysis/hemiplegic, TRAUMA_RESILIENCE_ABSOLUTE)
