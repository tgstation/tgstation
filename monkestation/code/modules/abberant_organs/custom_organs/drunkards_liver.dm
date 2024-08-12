/obj/item/organ/internal/liver/drunkards
	name = "drunkard's liver"

/obj/item/organ/internal/liver/drunkards/Initialize(mapload, mob_sprite)
	. = ..()
	AddComponent(/datum/component/abberant_organ, 200, ORGAN_LIVER, list(/datum/organ_process/reagent_conversion), /datum/organ_trigger/chemical_consume)
