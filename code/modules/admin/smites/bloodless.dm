/// Slashes up the target
/datum/smite/bloodless
	name = ":B:loodless"

/datum/smite/bloodless/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, "<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	for(var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb
		var/type_wound = pick(list(/datum/wound/slash/severe, /datum/wound/slash/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/slash/critical, /datum/wound/slash/severe, /datum/wound/slash/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/slash/critical, /datum/wound/slash/severe))
		limb.force_wound_upwards(type_wound, smited = TRUE)
