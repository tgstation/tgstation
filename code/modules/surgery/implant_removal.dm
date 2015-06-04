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
		user.visible_message("[user] begins to extract [I] from [target]'s [target_zone].", "<span class='notice'>You begin to extract [I] from [target]'s [target_zone]...</span>")
	else
		user.visible_message("[user] looks for an implant in [target]'s [target_zone].", "<span class='notice'>You look for an implant in [target]'s [target_zone]...</span>")

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(I)
		user.visible_message("[user] successfully removes [I] from [target]'s [target_zone]!", "<span class='notice'>You successfully remove [I] from [target]'s [target_zone].</span>")
		if(istype(I, /obj/item/weapon/implant/loyalty))
			target << "<span class='notice'><b>You feel a sense of liberation as Nanotrasen's grip on your mind fades away.</b></span>"
		qdel(I)
		if(istype(target, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = target
			H.sec_hud_set_implants()
	else
		user << "<span class='warning'>You can't find anything in [target]'s [target_zone]!</span>"
	return 1
