/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_APPENDIX
	var/inflamed = 0

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/appendix/Remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.diseases)
		A.cure()
		inflamed = 1
	update_icon()
	..()

/obj/item/organ/appendix/Insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.ForceContractDisease(new /datum/disease/appendicitis(), FALSE, TRUE)

/obj/item/organ/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent("bad_food", 5)
	return S
