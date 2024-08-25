/// Gives the target critically bad wounds
/datum/smite/small_bit_of_everything
	name = "light wound mix bag"

/datum/smite/small_bit_of_everything/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return
	var/mob/living/carbon/carbon_target = target
	for(var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb // fine to use this raw, its a meme smite
		var/type_wound = pick(list(/datum/wound/burn/flesh/severe/cursed_brand,/datum/wound/burn/flesh/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/blunt/bone/moderate, /datum/wound/pierce/bleed/moderate, /datum/wound/slash/flesh/moderate/many_cuts))
		limb.force_wound_upwards(type_wound, smited = TRUE)
		type_wound = pick(list(/datum/wound/muscle/moderate, /datum/wound/muscle/severe))
		limb.force_wound_upwards(type_wound, smited = TRUE)

