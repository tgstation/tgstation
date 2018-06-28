/datum/surgery/cavity_implant
	name = "cavity implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/incise, /datum/surgery_step/handle_cavity, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)


//handle cavity
/datum/surgery_step/handle_cavity
	name = "implant item"
	accept_hand = 1
	accept_any_item = 1
	time = 32
	var/obj/item/IC = null

/datum/surgery_step/handle_cavity/preop(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/chest/CH = target.get_bodypart(BODY_ZONE_CHEST)
	IC = CH.cavity_item
	if(tool)
		if(istype(tool, /obj/item/surgical_drapes) || istype(tool, /obj/item/bedsheet))
			var/obj/item/inactive = user.get_inactive_held_item()
			if(istype(inactive, /obj/item/cautery) || istype(inactive, /obj/item/screwdriver) || iscyborg(user))
				attempt_cancel_surgery(surgery, tool, target, user)
				return -1
		user.visible_message("[user] begins to insert [tool] into [target]'s [target_zone].", "<span class='notice'>You begin to insert [tool] into [target]'s [target_zone]...</span>")
	else
		user.visible_message("[user] checks for items in [target]'s [target_zone].", "<span class='notice'>You check for items in [target]'s [target_zone]...</span>")

/datum/surgery_step/handle_cavity/success(mob/user, mob/living/carbon/human/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/chest/CH = target.get_bodypart(BODY_ZONE_CHEST)
	if(tool)
		if(IC || tool.w_class > WEIGHT_CLASS_NORMAL || (tool.item_flags & NODROP) || istype(tool, /obj/item/organ))
			to_chat(user, "<span class='warning'>You can't seem to fit [tool] in [target]'s [target_zone]!</span>")
			return 0
		var/obj/item/electronic_assembly/EA = tool
		if(istype(EA) && EA.combat_circuits && tool.w_class > WEIGHT_CLASS_SMALL)
			to_chat(user, "<span class='warning'>[tool] is too dangerous to put in [target]'s [target_zone]! Maybe if it was smaller...</span>")
			return 0
		else
			user.visible_message("[user] stuffs [tool] into [target]'s [target_zone]!", "<span class='notice'>You stuff [tool] into [target]'s [target_zone].</span>")
			user.transferItemToLoc(tool, target, TRUE)
			CH.cavity_item = tool
			return 1
	else
		if(IC)
			user.visible_message("[user] pulls [IC] out of [target]'s [target_zone]!", "<span class='notice'>You pull [IC] out of [target]'s [target_zone].</span>")
			user.put_in_hands(IC)
			CH.cavity_item = null
			return 1
		else
			to_chat(user, "<span class='warning'>You don't find anything in [target]'s [target_zone].</span>")
			return 0
