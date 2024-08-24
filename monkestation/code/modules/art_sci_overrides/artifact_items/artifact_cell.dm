/obj/item/stock_parts/cell/artifact
	icon = 'icons/obj/artifacts.dmi'
	icon_state = "narnar-1"
	resistance_flags = LAVA_PROOF | ACID_PROOF | INDESTRUCTIBLE
	ratingdesc = FALSE
	charge_light_type = null
	var/forced_effect = /datum/artifact_effect/cell
	var/datum/component/artifact/assoc_comp = /datum/component/artifact

ARTIFACT_SETUP(/obj/item/stock_parts/cell/artifact, SSobj)

/obj/item/stock_parts/cell/artifact/use(amount, force) //dont use power unless active
	. = FALSE
	if(assoc_comp.active)
		return ..()
