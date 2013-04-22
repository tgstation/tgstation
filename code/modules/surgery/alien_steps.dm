//Surgery steps for alien humanoids.

/datum/surgery_step/alien/saw
	implements = list(/obj/item/weapon/circular_saw = 100, /obj/item/weapon/hatchet = 35, /obj/item/weapon/butch = 25)
	time = 64

/datum/surgery_step/alien/saw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to saw into [target]'s [target_zone].</span>")


/datum/surgery_step/alien/armor_check
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 55)
	time = 64
	var/obj/item/organ/achitin/B = null

/datum/surgery_step/alien/armor_check/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	B = locate() in target.internal_organs
	if(B)
		user.visible_message("<span class='notice'>[user] pries at [target]'s chitnous armor.</span>")
	else
		user.visible_message("<span class='notice'>[user] smooths and prepares [target]'s flesh.</span>")

/datum/surgery_step/alien/armor_check/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	B = locate() in target.internal_organs
	if(B)
		user.visible_message("<span class='notice'>[user] props open a piece of [target]'s chitinous armor.</span>")
	else
		user.visible_message("<span class='notice'>[user] finishes the preperation of [target]'s underflesh.</span>")
	return 1