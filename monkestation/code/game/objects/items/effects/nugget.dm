/obj/item/effect_granter/nugget
	name = "Nuggetify Yourself"
	icon_state = "nugget"

/obj/item/effect_granter/nugget/grant_effect(mob/living/carbon/granter)
	var/datum/smite/nugget/nugget_them = new
	nugget_them.effect(granter.client, granter)
	. = ..()
