/// Gives the target critically bad wounds
/datum/smite/swisscheese
	name = "swisscheese without the cheese"

/datum/smite/swisscheese/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	for(var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb // fine to use this raw, its a meme smite
		var/type_wound = pick(list(/datum/wound/pierce/bleed/severe, /datum/wound/pierce/bleed/critical))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/pierce/bleed/moderate, /datum/wound/pierce/bleed/severe, /datum/wound/pierce/bleed/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/pierce/bleed/moderate, /datum/wound/pierce/bleed/severe))
		limb.force_wound_upwards(type_wound, smited = TRUE)
