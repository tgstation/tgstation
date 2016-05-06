/datum/surgery/prosthetic_replacement
	name = "prosthetic replacement"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/add_prosthetic)
	species = list(/mob/living/carbon/human)
	possible_locs = list("r_arm", "l_arm", "l_leg", "r_leg", "head")
	requires_bodypart = FALSE //need a missing limb

/datum/surgery/prosthetic_replacement/can_start(mob/user, mob/living/carbon/target)
	if(!ishuman(target))
		return 0
	var/mob/living/carbon/human/H = target
	if(!H.get_bodypart(user.zone_selected)) //can only start if limb is missing
		return 1



/datum/surgery_step/add_prosthetic
	name = "add prosthetic"
	implements = list(/obj/item/robot_parts = 100, /obj/item/bodypart = 100)
	time = 32

/datum/surgery_step/add_prosthetic/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/tool_body_zone
	if(istype(tool, /obj/item/robot_parts))
		var/obj/item/robot_parts/RP = tool
		tool_body_zone = RP.body_zone
	else if(istype(tool, /obj/item/bodypart))
		var/obj/item/bodypart/L = tool
		if(L.status != ORGAN_ROBOTIC)
			user << "<span class='warning'>You need a robotic limb for this.</span>"
			return -1 //fail
		tool_body_zone = L.body_zone
	if(target_zone == tool_body_zone) //so we can't replace a leg with an arm.
		user.visible_message("[user] begins to replace [target]'s [parse_zone(target_zone)].", "<span class ='notice'>You begin to replace [target]'s [parse_zone(target_zone)]...</span>")
	else
		user << "<span class='warning'>[tool] isn't the right type for [parse_zone(target_zone)].</span>"

/datum/surgery_step/add_prosthetic/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	var/obj/item/bodypart/L
	if(istype(tool, /obj/item/robot_parts))
		L = newBodyPart(target_zone, 1, 1)
		user.drop_item()
		qdel(tool)
	else
		L = tool
	L.attach_limb(target)
	user.visible_message("[user] successfully replaces [target]'s [parse_zone(target_zone)]!", "<span class='notice'>You succeed in replacing [target]'s [parse_zone(target_zone)].</span>")
	return 1