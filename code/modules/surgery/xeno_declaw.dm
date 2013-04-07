/datum/surgery/xenodeclaw
	name = "xeno declawing"
	steps = list(/datum/surgery_step/alien/armor_check, /datum/surgery_step/alien/saw, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/extract_xenoclaw, /datum/surgery_step/close)
	species = list(/mob/living/carbon/alien/humanoid)
	location = "l_arm"

/datum/surgery_step/extract_xenoclaw
	implements = list(/obj/item/weapon/circular_saw = 100, /obj/item/weapon/hatchet = 35, /obj/item/weapon/butch = 25)
	time = 64
	var/obj/item/organ/aclaws/A = null

/datum/surgery_step/extract_xenoclaw/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	A = locate() in target.internal_organs
	if(A)
		user.visible_message("<span class='notice'>[user] begins to remove [target]'s claws.</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for claws on [target].</span>")

/datum/surgery_step/extract_xenoclaw/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(A)
		user.visible_message("<span class='notice'>[user] successfully removes [target]'s claws!</span>")
		A.loc = get_turf(target)
		target.internal_organs -= A
		var/mob/living/carbon/alien/humanoid/B = target
		B.has_fine_manipulation = 1
	else
		user.visible_message("<span class='notice'>[user] can't find any claws on [target]!</span>")
	return 1