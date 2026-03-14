/datum/surgery_operation/basic/dissection
	name = "experimental dissection"
	rnd_name = "Experimental Androtomy (Experimental Dissection and Autopsy)"
	desc = "Perform an experimental dissection on a patient to obtain research points."
	rnd_desc = "An experimental surgical procedure that dissects bodies in exchange for research points at ancient R&D consoles."
	implements = list(
		/obj/item/autopsy_scanner = 1,
		TOOL_SCALPEL = 1.66,
		TOOL_KNIFE = 5,
		/obj/item/shard = 10,
	)
	time = 12 SECONDS
	operation_flags = OPERATION_LOCKED | OPERATION_ALWAYS_FAILABLE | OPERATION_MORBID | OPERATION_IGNORE_CLOTHES
	required_biotype = NONE
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/basic/dissection/get_default_radial_image()
	return image(/obj/item/paper)

/datum/surgery_operation/basic/dissection/all_required_strings()
	. += ..()
	. += "the patient must be deceased"
	. += "the patient must not have been dissected prior"

/datum/surgery_operation/basic/dissection/state_check(mob/living/patient)
	return !HAS_TRAIT_FROM(patient, TRAIT_DISSECTED, EXPERIMENTAL_SURGERY_TRAIT) && patient.stat == DEAD

/datum/surgery_operation/basic/dissection/on_preop(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	display_results(
		surgeon,
		patient,
		span_notice("You begin to dissect [patient]..."),
		span_notice("[surgeon] begins to dissect [patient]."),
		span_notice("[surgeon] begins to dissect [patient]."),
	)

/datum/surgery_operation/basic/dissection/on_failure(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/points_earned = round(check_value(patient) * 0.01)
	display_results(
		surgeon,
		patient,
		span_warning("You dissect [patient], but don't find anything particularly interesting."),
		span_warning("[surgeon] dissects [patient]."),
		span_warning("[surgeon] dissects [patient]."),
	)
	give_paper(surgeon, points_earned)
	patient.apply_damage(80, BRUTE, BODY_ZONE_CHEST)
	ADD_TRAIT(patient, TRAIT_DISSECTED, EXPERIMENTAL_SURGERY_TRAIT)

/datum/surgery_operation/basic/dissection/on_success(mob/living/patient, mob/living/surgeon, tool, list/operation_args)
	var/points_earned = check_value(patient)
	display_results(
		surgeon,
		patient,
		span_warning("You dissect [patient], discovering [points_earned] point\s of data!"),
		span_warning("[surgeon] dissects [patient]."),
		span_warning("[surgeon] dissects [patient]."),
	)
	give_paper(surgeon, points_earned)
	patient.apply_damage(80, BRUTE, BODY_ZONE_CHEST)
	ADD_TRAIT(patient, TRAIT_DISSECTED, EXPERIMENTAL_SURGERY_TRAIT)

/datum/surgery_operation/basic/dissection/proc/give_paper(mob/living/surgeon, points)
	var/obj/item/research_notes/the_dossier = new /obj/item/research_notes(surgeon.loc, points, "biology")
	if(!surgeon.put_in_hands(the_dossier) && istype(surgeon.get_inactive_held_item(), /obj/item/research_notes))
		var/obj/item/research_notes/hand_dossier = surgeon.get_inactive_held_item()
		hand_dossier.merge(the_dossier)

///Calculates how many research points dissecting 'target' is worth.
/datum/surgery_operation/basic/dissection/proc/check_value(mob/living/target)
	var/reward = 10

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.dna?.species)
			if(ismonkey(human_target))
				reward /= 5
			else if(isabductor(human_target))
				reward *= 4
			else if(isgolem(human_target) || iszombie(human_target))
				reward *= 3
			else if(isjellyperson(human_target) || ispodperson(human_target))
				reward *= 2
	else if(isalienroyal(target))
		reward *= 10
	else if(isalienadult(target))
		reward *= 5
	else
		reward /= 6

	return reward

/obj/item/research_notes
	name = "research notes"
	desc = "Valuable scientific data. Use it in an ancient research server to turn it in."
	icon = 'icons/obj/service/bureaucracy.dmi'
	icon_state = "paper"
	w_class = WEIGHT_CLASS_SMALL
	///research points it holds
	var/value = 100
	///origin of the research
	var/origin_type = "debug"
	///if it ws merged with different origins to apply a bonus
	var/mixed = FALSE

/obj/item/research_notes/Initialize(mapload, value, origin_type)
	. = ..()
	if(value)
		src.value = value
	if(origin_type)
		src.origin_type = origin_type
	change_vol()

/obj/item/research_notes/examine(mob/user)
	. = ..()
	. += span_notice("It is worth [value] research points.")

/obj/item/research_notes/attackby(obj/item/attacking_item, mob/living/user, list/modifiers, list/attack_modifiers)
	if(istype(attacking_item, /obj/item/research_notes))
		var/obj/item/research_notes/notes = attacking_item
		value = value + notes.value
		change_vol()
		qdel(notes)
		return
	return ..()

/// proc that changes name and icon depending on value
/obj/item/research_notes/proc/change_vol()
	if(value >= 10000)
		name = "revolutionary discovery in the field of [origin_type]"
		icon_state = "docs_verified"
	else if(value >= 2500)
		name = "essay about [origin_type]"
		icon_state = "paper_words"
	else if(value >= 100)
		name = "notes of [origin_type]"
		icon_state = "paperslip_words"
	else
		name = "fragmentary data of [origin_type]"
		icon_state = "scrap"

///proc when you slap research notes into another one, it applies a bonus if they are of different origin (only applied once)
/obj/item/research_notes/proc/merge(obj/item/research_notes/new_paper)
	var/bonus = min(value , new_paper.value)
	value = value + new_paper.value
	if(origin_type != new_paper.origin_type && !mixed)
		value += bonus * 0.3
		origin_type = "[origin_type] and [new_paper.origin_type]"
		mixed = TRUE
	change_vol()
	qdel(new_paper)
