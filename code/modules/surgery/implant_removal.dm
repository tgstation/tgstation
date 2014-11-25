/datum/surgery/implant_removal
	name = "implant removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/extract_implant, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "chest"
	requires_organic_chest = 1



//extract implant
/datum/surgery_step/extract_implant
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 65)
	time = 64
	var/obj/item/weapon/implant/I = null

/datum/surgery_step/extract_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/weapon/implant/W in target)
		if(W.imp_in == target)	//Checking that it's actually implanted, not just in his pocket
			I = W
			break
	if(I)
		user.visible_message("<span class='notice'>[user] begins to extract [I] from [target]'s [target_zone].</span>")
	else
		user.visible_message("<span class='notice'>[user] looks for an implant in [target]'s [target_zone].</span>")

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(I)
		user.visible_message("<span class='notice'>[user] successfully removes [I] from [target]'s [target_zone]!</span>")
		if(istype(I, /obj/item/weapon/implant/loyalty))
			target << "<span class='notice'>You feel a sense of liberation as Nanotrasen's grip on your mind fades away.</span>"
		qdel(I)
		if(istype(user, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = user
			H.sec_hud_set_implants()
	else
		user.visible_message("<span class='notice'>[user] can't find anything in [target]'s [target_zone].</span>")
	return 1
