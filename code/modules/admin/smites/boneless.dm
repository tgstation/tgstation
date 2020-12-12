/// Gives the target critically bad wounds
/datum/smite/boneless
	name = ":B:oneless"

/datum/smite/boneless/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, "<span class='warning'>This must be used on a carbon mob.</span>", confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	for(var/_limb in carbon_target.bodyparts)
		var/obj/item/bodypart/limb = _limb
		var/type_wound = pick(list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate))
		limb.force_wound_upwards(type_wound, smited = TRUE)
