/datum/surgery/dissection
	target_mobtypes = list()


/datum/surgery/voidcrew_dissection
	name = "Dissection"
	desc = "A surgical procedure which analyzes the biology of a corpse, and automatically adds new findings to the research database."
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/dissection/voidcrew,
		/datum/surgery_step/close,
	)
	target_mobtypes = list(/mob/living)
	surgery_flags = SURGERY_REQUIRE_LIMB | SURGERY_REQUIRES_REAL_LIMB
	possible_locs = list(BODY_ZONE_CHEST)
	replaced_by = /datum/surgery/voidcrew_dissection/adv
	requires_tech = FALSE

	var/value_multiplier = 1

/datum/surgery/voidcrew_dissection/adv
	name = "Thorough Dissection"
	value_multiplier = 2
	replaced_by = /datum/surgery/voidcrew_dissection/exp
	requires_tech = TRUE

/datum/surgery/voidcrew_dissection/exp
	name = "Experimental Dissection"
	value_multiplier = 5
	replaced_by = /datum/surgery/voidcrew_dissection/alien
	requires_tech = TRUE

/datum/surgery/voidcrew_dissection/alien
	name = "Extraterrestrial Dissection"
	value_multiplier = 10
	requires_tech = TRUE
	replaced_by = null

/datum/surgery/voidcrew_dissection/can_start(mob/user, mob/living/patient)
	. = ..()

	if(HAS_TRAIT_FROM(patient, TRAIT_DISSECTED, name))
		return FALSE

	if (patient.stat != DEAD)
		return FALSE


/datum/surgery_step/dissection/voidcrew/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You start to dissect [target]..."),
		span_notice("[user] starts to dissect [target]..."),
		span_notice("[user] begins to start poking around inside your corpse...hey, wait a minute!"),
	)


#define BASE_HUMAN_REWARD 1500
/datum/surgery_step/dissection/voidcrew/proc/check_value(mob/living/target, datum/surgery/voidcrew_dissection/ED)
	var/cost = BASE_HUMAN_REWARD
	var/multi_surgery_adjust = 0
	//determine bonus applied
	if(isalienroyal(target))
		cost = (BASE_HUMAN_REWARD*10)
	else if(isalienadult(target))
		cost = (BASE_HUMAN_REWARD*5)
	else if(ismonkey(target))
		cost = (BASE_HUMAN_REWARD*0.5)
	else if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H?.dna?.species)
			if(isabductor(H))
				cost = (BASE_HUMAN_REWARD*4)
			else if(isgolem(H) || iszombie(H))
				cost = (BASE_HUMAN_REWARD*3)
			else if(isjellyperson(H) || ispodperson(H))
				cost = (BASE_HUMAN_REWARD*2)
	else
		cost = (BASE_HUMAN_REWARD * 0.6)



	//now we do math for surgeries already done (no double dipping!).
	for(var/i in typesof(/datum/surgery/voidcrew_dissection))
		var/datum/surgery/voidcrew_dissection/cringe = i
		if(HAS_TRAIT_FROM(target, TRAIT_DISSECTED, initial(cringe.name)))
			multi_surgery_adjust = max(multi_surgery_adjust, initial(cringe.value_multiplier)) - 1

	multi_surgery_adjust *= cost

	//multiply by multiplier in surgery
	cost *= ED.value_multiplier
	return (cost-multi_surgery_adjust)

#undef BASE_HUMAN_REWARD

/datum/surgery_step/dissection/voidcrew/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	var/points_earned = check_value(target, surgery)
	user.visible_message("<span class='notice'>[user] dissects [target], discovering [points_earned] point\s of data!</span>", "<span class='notice'>You dissect [target], finding [points_earned] point\s worth of discoveries, you also write a few notes.</span>")
	ADD_TRAIT(target, TRAIT_DISSECTED, surgery.name)
	var/obj/item/research_notes/the_dossier = new /obj/item/research_notes(user.loc, points_earned, "biology")
	if(!user.put_in_hands(the_dossier) && istype(user.get_inactive_held_item(), /obj/item/research_notes))
		var/obj/item/research_notes/hand_dossier = user.get_inactive_held_item()
		hand_dossier.merge(the_dossier)
	return ..()

/mob/living/attackby(obj/item/attacking_item, mob/living/user, params)
	if(stat == DEAD && surgeries.len)
		var/list/modifiers = params2list(params)
		if(!user.combat_mode || (LAZYACCESS(modifiers, RIGHT_CLICK)))
			for(var/datum/surgery/operations as anything in surgeries)
				if(operations.next_step(user, modifiers))
					return TRUE
	..()

