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

/datum/surgery_step/handle_cavity/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/chest/CH = target.get_bodypart("chest")
	IC = CH.cavity_item
	if(tool)
		user.visible_message("[IDENTITY_SUBJECT(1)] begins to insert [tool] into [IDENTITY_SUBJECT(2)]'s [target_zone].", "<span class='notice'>You begin to insert [tool] into [IDENTITY_SUBJECT(2)]'s [target_zone]...</span>", subjects=list(user, target))
	else
		user.visible_message("[IDENTITY_SUBJECT(1)] checks for items in [IDENTITY_SUBJECT(2)]'s [target_zone].", "<span class='notice'>You check for items in [target]'s [target_zone]...</span>", subjects=list(user, target))

/datum/surgery_step/handle_cavity/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/chest/CH = target.get_bodypart("chest")
	if(tool)
		if(IC || tool.w_class > WEIGHT_CLASS_NORMAL || (NODROP in tool.flags) || istype(tool, /obj/item/organ))
			to_chat(user, "<span class='warning'>You can't seem to fit [tool] in [IDENTITY_SUBJECT(1)]'s [target_zone]!</span>", list(target))
			return 0
		else
			user.visible_message("[IDENTITY_SUBJECT(1)] stuffs [tool] into [IDENTITY_SUBJECT(2)]'s [target_zone]!", "<span class='notice'>You stuff [tool] into [target]'s [target_zone].</span>", subjects=list(user, target))
			user.drop_item()
			CH.cavity_item = tool
			tool.loc = target
			return 1
	else
		if(IC)
			user.visible_message("[IDENTITY_SUBJECT(1)] pulls [IC] out of [IDENTITY_SUBJECT(2)]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [IDENTITY_SUBJECT(2)]'s [target_zone].</span>", subjects=list(user, target))
			user.put_in_hands(IC)
			CH.cavity_item = null
			return 1
		else
			to_chat(user, "<span class='warning'>You don't find anything in [IDENTITY_SUBJECT(1)]'s [target_zone].</span>", list(target))
			return 0
