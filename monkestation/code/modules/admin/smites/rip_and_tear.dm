/datum/smite/rip_and_tear
	name = "rip and tear those tendons"

/datum/smite/rip_and_tear/effect(client/user, mob/living/target)
	. = ..()
	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	for(var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb // fine to use this raw, its a meme smite
		var/type_wound = pick(list(/datum/wound/muscle/severe, /datum/wound/muscle/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list( /datum/wound/muscle/severe, /datum/wound/muscle/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/muscle/moderate, /datum/wound/muscle/severe))
		limb.force_wound_upwards(type_wound, smited = TRUE)
