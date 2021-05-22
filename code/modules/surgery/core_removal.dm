/datum/surgery/core_removal
	name = "Core removal"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/extract_core)
	target_mobtypes = list(/mob/living/simple_animal/slime)
	possible_locs = list(BODY_ZONE_R_ARM,BODY_ZONE_L_ARM,BODY_ZONE_R_LEG,BODY_ZONE_L_LEG,BODY_ZONE_CHEST,BODY_ZONE_HEAD)
	lying_required = FALSE
	ignore_clothes = TRUE

/datum/surgery/core_removal/can_start(mob/user, mob/living/target)
	if(target.stat == DEAD)
		return TRUE
	return FALSE

//extract brain
/datum/surgery_step/extract_core
	name = "extract core"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_CROWBAR = 100)
	time = 16

/datum/surgery_step/extract_core/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to extract a core from [target]...</span>",
		"<span class='notice'>[user] begins to extract a core from [target].</span>",
		"<span class='notice'>[user] begins to extract a core from [target].</span>")

/datum/surgery_step/extract_core/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/mob/living/simple_animal/slime/target_slime = target
	if(target_slime.cores > 0)
		target_slime.cores--
		display_results(user, target, "<span class='notice'>You successfully extract a core from [target]. [target_slime.cores] core\s remaining.</span>",
			"<span class='notice'>[user] successfully extracts a core from [target]!</span>",
			"<span class='notice'>[user] successfully extracts a core from [target]!</span>")

		new target_slime.coretype(target_slime.loc)

		if(target_slime.cores <= 0)
			target_slime.icon_state = "[target_slime.colour] baby slime dead-nocore"
			return ..()
		else
			return FALSE
	else
		to_chat(user, "<span class='warning'>There aren't any cores left in [target]!</span>")
		return ..()
