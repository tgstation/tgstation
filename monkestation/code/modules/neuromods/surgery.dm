/datum/surgery/mimic_organ_extraction
	name = "organ extraction"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/extract_mimic_organ)
	target_mobtypes = list(/mob/living/simple_animal/hostile/alien_mimic)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	lying_required = FALSE
	ignore_clothes = TRUE

/datum/surgery/mimic_organ_extraction/can_start(mob/user, mob/living/target)
	if(target.stat == DEAD)
		return TRUE
	return FALSE

//extract organ
/datum/surgery_step/extract_mimic_organ
	name = "extract organ"
	accept_hand = TRUE
	time = 3 SECONDS

/datum/surgery_step/extract_mimic_organ/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to extract an organ from [target]...</span>",
		"[user] begins to extract an organ from [target].",
		"[user] begins to extract an organ from [target].")

/datum/surgery_step/extract_mimic_organ/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/mob/living/simple_animal/hostile/alien_mimic/mimic = target
	if(mimic.has_organ)
		mimic.has_organ = FALSE
		display_results(user, target, "<span class='notice'>You successfully extract the organ from [target].</span>",
			"[user] successfully extracts the organ from [target]!",
			"[user] successfully extracts the organ from [target]!")

		mimic.desc += "\nIt's body is cut open, and a chunk of it is missing."

		new /obj/item/mimic_organ(get_turf(target))
		return TRUE
	else
		to_chat(user, "<span class='warning'>There is no organ inside [target]!</span>")
		return TRUE
