/datum/surgery/xenodechitin
	name = "alien chitin removal"
	steps = list(/datum/surgery_step/alien/armor_check, /datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/alien/saw, /datum/surgery_step/extract_xenochitin, /datum/surgery_step/close)
	species = list(/mob/living/carbon/alien/humanoid)
	location = "chest"

/datum/surgery_step/extract_xenochitin
	implements = list(/obj/item/weapon/circular_saw = 100, /obj/item/weapon/hatchet = 35, /obj/item/weapon/butch = 25)
	time = 64
	var/obj/item/organ/achitin/A = null

/datum/surgery_step/extract_xenochitin/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	A = locate() in target.internal_organs
	if(A)
		user.visible_message("<span class='notice'>[user] begins to pry off [target]'s armor.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for remaining armor on [target].</span>")

/datum/surgery_step/extract_xenochitin/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(A)
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s armor!</span>")
		A.loc = get_turf(target)
		target.internal_organs -= A
		var/mob/living/carbon/alien/humanoid/B = target
		B.maxHealth = B.maxHealth/2
	else
		user.visible_message("<span class='notice'>[user] can't find any more armor on [target]!</span>")
	return 1