/datum/surgery/advanced/bioware/experimental_dissection
	name = "Experimental Dissection"
	desc = "A surgical procedure which deeply analyzes the biology of a corpse, and automatically adds new findings to the research database."
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/dissection,
				/datum/surgery_step/close)
	possible_locs = list(BODY_ZONE_CHEST)
	bioware_target = BIOWARE_DISSECTION

/datum/surgery/advanced/bioware/experimental_dissection/can_start(mob/user, mob/living/carbon/target)
	. = ..()
	if(iscyborg(user))
		return FALSE //robots cannot be creative
						//(also this surgery shouldn't be consistently successful, and cyborgs have a 100% success rate on surgery)
	if(target.stat != DEAD)
		return FALSE	
	
/datum/surgery_step/dissection
	name = "dissection"
	implements = list(/obj/item/scalpel = 60, /obj/item/kitchen/knife = 30, /obj/item/shard = 15)
	time = 125

/datum/surgery_step/dissection/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts dissecting [target].", "<span class='notice'>You start dissecting [target].</span>")
	
/datum/surgery_step/dissection/proc/check_value(mob/living/carbon/target)
	if(isalienroyal(target))
		return 10000
	else if(isalienadult(target))
		return 5000
	else if(ismonkey(target))
		return 1000
	else if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(H.dna && H.dna.species)
			if(isabductor(H))
				return 8000
			if(isgolem(H) || iszombie(H))
				return 4000
			if(isjellyperson(H) || ispodperson(H))
				return 3000
			return 2000

/datum/surgery_step/dissection/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] dissects [target]!", "<span class='notice'>You dissect [target], and add your discoveries to the research database!</span>")
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = check_value(target)))
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L)
	new /datum/bioware/dissected(target)
	return TRUE
	
/datum/surgery_step/dissection/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] dissects [target]!", "<span class='notice'>You dissect [target], but do not find anything particularly interesting.</span>")
	SSresearch.science_tech.add_point_list(list(TECHWEB_POINT_TYPE_GENERIC = (check_value(target) * 0.2)))
	var/obj/item/bodypart/L = target.get_bodypart(BODY_ZONE_CHEST)
	target.apply_damage(80, BRUTE, L)
	new /datum/bioware/dissected(target)
	return TRUE

/datum/bioware/dissected
	name = "Dissected"
	desc = "This body has been dissected and analyzed. It is no longer worth experimenting on."
	mod_type = BIOWARE_DISSECTION