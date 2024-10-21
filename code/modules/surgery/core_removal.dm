/datum/surgery/core_removal
	name = "Core removal"
	target_mobtypes = list(/mob/living/basic/slime)
	surgery_flags = SURGERY_IGNORE_CLOTHES
	possible_locs = list(
		BODY_ZONE_R_ARM,
		BODY_ZONE_L_ARM,
		BODY_ZONE_R_LEG,
		BODY_ZONE_L_LEG,
		BODY_ZONE_CHEST,
		BODY_ZONE_HEAD,
	)
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/extract_core,
	)

/datum/surgery/core_removal/can_start(mob/user, mob/living/target)
	return target.stat == DEAD && ..()

//extract brain
/datum/surgery_step/extract_core
	name = "extract core (hemostat/crowbar)"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_CROWBAR = 100)
	time = 16

/datum/surgery_step/extract_core/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(
		user,
		target,
		span_notice("You begin to extract a core from [target]..."),
		span_notice("[user] begins to extract a core from [target]."),
		span_notice("[user] begins to extract a core from [target]."),
	)

/datum/surgery_step/extract_core/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	var/mob/living/basic/slime/target_slime = target
	var/core_count = target_slime.cores
	if(core_count && target_slime.try_extract_cores(count = core_count))
		display_results(
			user,
			target,
			span_notice("You successfully extract [core_count] core\s from [target]."),
			span_notice("[user] successfully extracts [core_count] core\s from [target]!"),
			span_notice("[user] successfully extracts [core_count] core\s from [target]!"),
		)
		return TRUE
	to_chat(user, span_warning("There aren't any cores left in [target]!"))
	return ..()
