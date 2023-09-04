/// Slashes up the target
/datum/smite/bloodless
	name = ":B:loodless"

/datum/smite/bloodless/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	for(var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb
		var/type_wound = pick(list(/datum/wound/slash/flesh/severe, /datum/wound/slash/flesh/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/slash/flesh/critical, /datum/wound/slash/flesh/severe, /datum/wound/slash/flesh/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/slash/flesh/critical, /datum/wound/slash/flesh/severe))
		limb.force_wound_upwards(type_wound, smited = TRUE)
