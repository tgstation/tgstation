/obj/item/organ/internal
	origin_tech = "biotech=2"
	var/zone = "chest"
	var/slot
	var/vital = 0
	var/organ_action_name = null

/obj/item/organ/internal/proc/Insert(var/mob/living/carbon/M, special = 0)
	if(!iscarbon(M) || owner)
		return

	var/obj/item/organ/internal/replaced = M.getorganslot(slot)
	if(replaced)
		replaced.Remove(M, special = 1)

	owner = M
	M.internal_organs |= src
	loc = null
	if(organ_action_name)
		action_button_name = organ_action_name

/obj/item/organ/internal/proc/Remove(var/mob/living/carbon/M, special = 0)
	owner = null
	if(M)
		M.internal_organs -= src
		if(vital && !special)
			M.death()

	if(organ_action_name)
		action_button_name = null

/obj/item/organ/internal/proc/on_life()
	return

/obj/item/organ/internal/Destroy()
	if(owner)
		Remove(owner, 1)
	..()

//Looking for brains?
//Try code/modules/mob/living/carbon/brain/brain_item.dm



/obj/item/organ/internal/heart
	name = "heart"
	icon_state = "heart-on"
	zone = "chest"
	slot = "heart"
	origin_tech = "biotech=3"
	vital = 1
	var/beating = 1

/obj/item/organ/internal/heart/update_icon()
	if(beating)
		icon_state = "heart-on"
	else
		icon_state = "heart-off"

/obj/item/organ/internal/heart/Insert(var/mob/living/carbon/M, special = 0)
	..()
	beating = 1
	update_icon()

/obj/item/organ/internal/heart/Remove(var/mob/living/carbon/M, special = 0)
	..()
	spawn(120)
		beating = 0
		update_icon()


/obj/item/organ/internal/appendix
	name = "appendix"
	icon_state = "appendix"
	zone = "groin"
	slot = "appendix"
	var/inflamed = 0

/obj/item/organ/internal/appendix/update_icon()
	if(inflamed)
		icon_state = "appendixinflamed"
		name = "inflamed appendix"
	else
		icon_state = "appendix"
		name = "appendix"

/obj/item/organ/internal/appendix/Remove(var/mob/living/carbon/M, special = 0)
	for(var/datum/disease/appendicitis in M.viruses)
		appendicitis.cure()
	..()

/obj/item/organ/internal/appendix/Insert(var/mob/living/carbon/M, special = 0)
	..()
	if(inflamed)
		M.AddDisease(new /datum/disease/appendicitis)