/obj/item/organ/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = BODY_ZONE_PRECISE_GROIN
	slot = ORGAN_SLOT_APPENDIX
	var/inflamed = FALSE
	var/failed = FALSE	//set to 0 to limit failing message to only occur once
	Unique_Failure_Msg = "<span class='danger'>Subject's appendix has burst and needs to be removed immediately!</span>"

/obj/item/organ/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/appendix/on_life()
	..()
	if(!failing)
		failed = FALSE
		return
	if(!failed)
		failed = TRUE
		to_chat(owner, "<span class='warning'>Your lower abdomen flashes with pain before spreading further around the body!</span>")
	var/mob/living/carbon/M = owner
	M.adjustToxLoss(4, TRUE, TRUE)	//forced to ensure people don't use it to gain tox as slime person

/obj/item/organ/appendix/Remove(mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis/A in M.diseases)
		A.cure()
		inflamed = TRUE
	update_icon()
	..()

/obj/item/organ/appendix/Insert(mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.ForceContractDisease(new /datum/disease/appendicitis(), FALSE, TRUE)

/obj/item/organ/appendix/prepare_eat()
	var/obj/S = ..()
	if(inflamed)
		S.reagents.add_reagent(/datum/reagent/toxin/bad_food, 5)
	return S
