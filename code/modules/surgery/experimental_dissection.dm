
/datum/surgery/advanced/experimental_dissection
	name = "Dissection"
	desc = "A surgical procedure which analyzes the biology of a corpse, and greatly increases one's medical knowledge."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/dissection,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	target_mobtypes = list(/mob/living) //Feel free to dissect devils but they're magic.
	replaced_by = /datum/surgery/advanced/experimental_dissection/adv
	requires_tech = FALSE
	var/value_multiplier = 1

/datum/surgery/advanced/experimental_dissection/can_start(mob/user, mob/living/target)
	. = ..()
	if(HAS_TRAIT_FROM(target, TRAIT_DISSECTED,"[name]"))
		return FALSE
	if(target.stat != DEAD)
		return FALSE

/datum/surgery_step/dissection
	name = "dissection"
	implements = list(/obj/item/scalpel/augment = 75, /obj/item/scalpel/advanced = 60, TOOL_SCALPEL = 45, /obj/item/kitchen/knife = 20, /obj/item/shard = 10)// special tools not only cut down time but also improve probability
	time = 125
	silicons_obey_prob = TRUE
	repeatable = TRUE
	experience_given = 0 //experience received scales with what's being dissected + which step you're doing.

/datum/surgery_step/dissection/preop(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] starts dissecting [target].</span>", "<span class='notice'>You start dissecting [target].</span>")

/datum/surgery_step/dissection/proc/check_value(mob/living/target, datum/surgery/advanced/experimental_dissection/ED)
	var/cost = MEDICAL_SKILL_DISSECT
	var/multi_surgery_adjust = 0

	//determine bonus applied
	if(isalienroyal(target))
		cost = (MEDICAL_SKILL_DISSECT*5)
	else if(isalienadult(target))
		cost = (MEDICAL_SKILL_DISSECT*3)
	else if(ismonkey(target))
		cost = (MEDICAL_SKILL_DISSECT*0.5)
	else if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H?.dna?.species)
			if(isabductor(H))
				cost = (MEDICAL_SKILL_DISSECT*3)
			else if(isgolem(H) || iszombie(H))
				cost = (MEDICAL_SKILL_DISSECT*2.5)
			else if(isjellyperson(H) || ispodperson(H))
				cost = (MEDICAL_SKILL_DISSECT*1.5)
	else
		cost = (MEDICAL_SKILL_DISSECT * 0.6)



	//now we do math for surgeries already done (no double dipping!).
	for(var/i in typesof(/datum/surgery/advanced/experimental_dissection))
		var/datum/surgery/advanced/experimental_dissection/cringe = i
		if(HAS_TRAIT_FROM(target,TRAIT_DISSECTED,"[initial(cringe.name)]"))
			multi_surgery_adjust = max(multi_surgery_adjust,initial(cringe.value_multiplier)) - 1

	multi_surgery_adjust *= cost

	//multiply by multiplier in surgery
	cost *= ED.value_multiplier
	return (cost-multi_surgery_adjust)

/datum/surgery_step/dissection/success(mob/user, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	user.visible_message("<span class='notice'>[user] dissects [target], enhancing their medical knowledge!", "<span class='notice'>You dissect [target] and receive some healing experience!</span>")
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L, wound_bonus=CANT_WOUND)
	ADD_TRAIT(target, TRAIT_DISSECTED, "[surgery.name]")
	repeatable = FALSE
	experience_given = check_value(target, surgery)
	return ..()

/datum/surgery_step/dissection/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] dissects [target]!</span>", "<span class='notice'>You attempt to dissect [target], but do not find anything particularly interesting.</span>")
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L, wound_bonus=CANT_WOUND)
	return TRUE

/datum/surgery/advanced/experimental_dissection/adv
	name = "Thorough Dissection"
	value_multiplier = 1.5
	replaced_by = /datum/surgery/advanced/experimental_dissection/exp
	requires_tech = TRUE

/datum/surgery/advanced/experimental_dissection/exp
	name = "Experimental Dissection"
	value_multiplier = 2
	replaced_by = /datum/surgery/advanced/experimental_dissection/alien
	requires_tech = TRUE

/datum/surgery/advanced/experimental_dissection/alien
	name = "Extraterrestrial Dissection"
	value_multiplier = 5
	requires_tech = TRUE
	replaced_by = null
