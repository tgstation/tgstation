/datum/surgery/implant_removal
	name = "implant removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/extract_implant, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list("chest")
	requires_organic_bodypart = 0


//extract implant
/datum/surgery_step/extract_implant
	name = "extract implant"
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 65)
	time = 64
	var/obj/item/weapon/implant/I = null

/datum/surgery_step/extract_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/O in target.implants)
		I = O
		break
	if(I)
		user.visible_message("[IDENTITY_SUBJECT(1)] begins to extract [I] from [IDENTITY_SUBJECT(2)]'s [target_zone].", "<span class='notice'>You begin to extract [I] from [IDENTITY_SUBJECT(2)]'s [target_zone]...</span>", subjects=list(user, target))
	else
		user.visible_message("[IDENTITY_SUBJECT(1)] looks for an implant in [IDENTITY_SUBJECT(2)]'s [target_zone].", "<span class='notice'>You look for an implant in [IDENTITY_SUBJECT(2)]'s [target_zone]...</span>", subjects=list(user, target))

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(I)
		user.visible_message("[IDENTITY_SUBJECT(1)] successfully removes [I] from [IDENTITY_SUBJECT(2)]'s [target_zone]!", "<span class='notice'>You successfully remove [I] from [target]'s [target_zone].</span>", subjects=list(user))
		I.removed(target)

		var/obj/item/weapon/implantcase/case
		for(var/obj/item/weapon/implantcase/ic in user.held_items)
			case = ic
			break
		if(!case)
			case = locate(/obj/item/weapon/implantcase) in get_turf(target)
		if(case && !case.imp)
			case.imp = I
			I.loc = case
			case.update_icon()
			user.visible_message("[IDENTITY_SUBJECT(1)] places [I] into [case]!", "<span class='notice'>You place [I] into [case].</span>", subjects=list(user))
		else
			qdel(I)

	else
		to_chat(user, "<span class='warning'>You can't find anything in [target]'s [target_zone]!</span>")
	return 1