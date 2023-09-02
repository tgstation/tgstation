/// Gives the target critically bad wounds
/datum/smite/boneless
	name = ":B:oneless"

/datum/smite/boneless/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	for(var/obj/item/bodypart/limb as anything in carbon_target.bodyparts)
		var/severity = pick(list(
			"[WOUND_SEVERITY_MODERATE]",
			"[WOUND_SEVERITY_SEVERE]",
			"[WOUND_SEVERITY_SEVERE]",
			"[WOUND_SEVERITY_CRITICAL]",
			"[WOUND_SEVERITY_CRITICAL]",
		))
		var/datum/wound/wound_typepath = get_corresponding_wound_type(list(WOUND_BLUNT), limb, text2num(severity))
		if (wound_typepath)
			limb.force_wound_upwards(wound_typepath, smited = TRUE)
