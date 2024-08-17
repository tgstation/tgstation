///How many research points you gain from dissecting a Human.
#define BASE_HUMAN_REWARD 10

/datum/surgery/advanced/experimental_dissection
	name = "Experimental Dissection"
	desc = "A surgical procedure which analyzes the biology of a corpse, and automatically adds new findings to the research database."
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/experimental_dissection,
		/datum/surgery_step/close,
	)
	surgery_flags = SURGERY_REQUIRE_RESTING | SURGERY_MORBID_CURIOSITY
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living)

/datum/surgery/advanced/experimental_dissection/can_start(mob/user, mob/living/target)
	. = ..()
	if(!.)
		return .
	if(HAS_TRAIT_FROM(target, TRAIT_DISSECTED, EXPERIMENTAL_SURGERY_TRAIT))
		return FALSE
	if(target.stat != DEAD)
		return FALSE
	return .

/datum/surgery_step/experimental_dissection
	name = "dissection"
	implements = list(
		/obj/item/autopsy_scanner = 100,
		TOOL_SCALPEL = 60,
		TOOL_KNIFE = 20,
		/obj/item/shard = 10,
	)
	time = 12 SECONDS
	silicons_obey_prob = TRUE

/datum/surgery_step/experimental_dissection/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] starts dissecting [target].</span>", "<span class='notice'>You start dissecting [target].</span>")

/datum/surgery_step/experimental_dissection/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/points_earned = check_value(target)
	user.visible_message("<span class='notice'>[user] dissects [target], discovering [points_earned] point\s of data!</span>", "<span class='notice'>You dissect [target], finding [points_earned] point\s worth of discoveries, you also write a few notes.</span>")

	var/obj/item/research_notes/the_dossier = new /obj/item/research_notes(user.loc, points_earned, "biology")
	if(!user.put_in_hands(the_dossier) && istype(user.get_inactive_held_item(), /obj/item/research_notes))
		var/obj/item/research_notes/hand_dossier = user.get_inactive_held_item()
		hand_dossier.merge(the_dossier)

	target.apply_damage(80, BRUTE, BODY_ZONE_CHEST)
	ADD_TRAIT(target, TRAIT_DISSECTED, EXPERIMENTAL_SURGERY_TRAIT)
	return ..()

/datum/surgery_step/experimental_dissection/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/points_earned = round(check_value(target) * 0.01)
	user.visible_message(
		"<span class='notice'>[user] dissects [target]!</span>",
		"<span class='notice'>You dissect [target], but do not find anything particularly interesting.</span>",
	)

	var/obj/item/research_notes/the_dossier = new /obj/item/research_notes(user.loc, points_earned, "biology")
	if(!user.put_in_hands(the_dossier) && istype(user.get_inactive_held_item(), /obj/item/research_notes))
		var/obj/item/research_notes/hand_dossier = user.get_inactive_held_item()
		hand_dossier.merge(the_dossier)

	target.apply_damage(80, BRUTE, BODY_ZONE_CHEST)
	return TRUE

///Calculates how many research points dissecting 'target' is worth.
/datum/surgery_step/experimental_dissection/proc/check_value(mob/living/target)
	var/cost = BASE_HUMAN_REWARD

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.dna?.species)
			if(ismonkey(human_target))
				cost /= 5
			else if(isabductor(human_target))
				cost *= 4
			else if(isgolem(human_target) || iszombie(human_target))
				cost *= 3
			else if(isjellyperson(human_target) || ispodperson(human_target))
				cost *= 2
	else if(isalienroyal(target))
		cost *= 10
	else if(isalienadult(target))
		cost *= 5
	else
		cost /= 6

	return cost

#undef BASE_HUMAN_REWARD

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

/obj/item/research_notes/attackby(obj/item/attacking_item, mob/living/user, params)
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
