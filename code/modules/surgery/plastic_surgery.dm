/datum/surgery/plastic_surgery
	name = "plastic surgery"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/reshape_face, /datum/surgery_step/close)
	possible_locs = list("head")

//reshape_face
/datum/surgery_step/reshape_face
	name = "reshape face"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/kitchen/knife = 50, /obj/item/weapon/wirecutters = 35)
	time = 64

/datum/surgery_step/reshape_face/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] begins to alter [target]'s appearance.", "<span class='notice'>You begin to alter [target]'s appearance...</span>")

/datum/surgery_step/reshape_face/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.status_flags & DISFIGURED)
		target.status_flags &= ~DISFIGURED
		user.visible_message("[user] successfully restores [target]'s appearance!", "<span class='notice'>You successfully restore [target]'s appearance.</span>")
	else
		var/oldname = target.real_name
		target.real_name = target.dna.species.random_name(target.gender,1)
		var/newname = target.real_name	//something about how the code handles names required that I use this instead of target.real_name
		user.visible_message("[user] alters [oldname]'s appearance completely, [target.p_they()] are now [newname]!", "<span class='notice'>You alter [oldname]'s appearance completely, [target.p_they()] are now [newname].</span>")
	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		H.sec_hud_set_ID()
	return 1