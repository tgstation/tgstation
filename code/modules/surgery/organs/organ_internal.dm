/obj/item/organ/internal
	var/zone = "chest"
	var/slot
	var/vital = 0

/obj/item/organ/internal/proc/Insert(var/mob/living/carbon/M)
	owner = M
	M.internal_organs += src
	loc = null

/obj/item/organ/internal/proc/Remove(var/mob/living/carbon/M, var/special = 0)
	owner = null
	M.internal_organs -= src
	if(vital && !special)
		M.death()

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm



/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	zone = "chest"
	slot = "heart"
	vital = 1
	var/beating = 1

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"



/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = "groin"
	slot = "appendix"
	var/inflamed = 0

/obj/item/organ/internal/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
	else
		icon_state = "appendix"

/obj/item/organ/internal/appendix/Remove(var/mob/living/carbon/M)
	for(var/datum/disease/appendicitis in M.viruses)
		appendicitis.cure()
	..()

/obj/item/organ/internal/appendix/Insert(var/mob/living/carbon/M)
	..()
	if(inflamed)
		M.AddDisease(new /datum/disease/appendicitis)