//Could be made a part of organ manipulation now

/datum/surgery/cavity_implant
	name = "cavity implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/handle_cavity, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("chest")


//handle cavity
/datum/surgery_step/handle_cavity
	name = "implant item"
	accept_hand = 1
	accept_any_item = 1
	time = 32
	var/obj/item/IC = null
	var/datum/organ/cavity/CA = null

/datum/surgery_step/handle_cavity/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	CA = target.get_organ("cavity")
	if(CA && CA.exists())
		IC = CA.organitem
	if(tool)
		user.visible_message("<span class='notice'>[user] begins to insert [tool] into [target]'s [target_zone].</span>")
	else
		user.visible_message("<span class='notice'>[user] checks for items in [target]'s [target_zone].</span>")

/datum/surgery_step/handle_cavity/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool)
		if(!CA || IC || tool.w_class > 3 || (tool.flags & NODROP) || tool.GetTypeInAllContents(/obj/item/weapon/disk/nuclear) || istype(tool, /obj/item/weapon/disk/nuclear) || istype(tool, /obj/item/organ))
			user.visible_message("<span class='notice'>[user] can't seem to fit [tool] in [target]'s [target_zone].</span>")
			return 0
		else
			user.visible_message("<span class='notice'>[user] stuffs [tool] into [target]'s [target_zone]!</span>")
			user.drop_item()
			if(CA.set_organitem(tool))
				return 1
			else return 0
	else
		if(IC)
			user.visible_message("<span class='notice'>[user] pulls [IC] out of [target]'s [target_zone]!</span>")
			CA.dismember(ORGAN_REMOVED)
			user.put_in_hands(IC)
			return 1
		else
			user.visible_message("<span class='notice'>[user] doesn't find anything in [target]'s [target_zone].</span>")
			return 0