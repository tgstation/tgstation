/datum/surgery/plastic_surgery
	name = "plastic surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/reshape_face, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	location = "head"

//reshape_face
/datum/surgery_step/reshape_face
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchenknife = 50, /obj/item/weapon/wirecutters = 35)
	time = 64

/datum/surgery_step/reshape_face/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to alter [target]'s appearance.</span>")

/datum/surgery_step/reshape_face/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.status_flags & DISFIGURED)
		target.status_flags &= ~DISFIGURED
		user.visible_message("<span class='notice'>[user] successfully restores [target]'s appearance!</span>")
	else
		var/oldname = target.real_name
		target.real_name = random_name(target.gender)
		var/newname = target.real_name	//something about how the code handles names required that I use this instead of target.real_name
		user.visible_message("<span class='notice'>[user] alters [oldname]'s appearance completely, they are now [newname]!</span>")
	return 1