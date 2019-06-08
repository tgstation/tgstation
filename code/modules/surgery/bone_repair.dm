/datum/surgery/bone_repair
	name = "bone repair"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/set_bone, /datum/surgery_step/close)
	possible_locs = list("chest", "l_arm", "r_arm", "r_leg", "l_leg", "head")

/datum/surgery/bone_repair/can_start(mob/user, mob/living/carbon/target)
	if(istype(target,/mob/living/carbon/human))
		var/mob/living/carbon/human/H = target
		var/obj/item/bodypart/affected = H.get_bodypart(user.zone_selected)
		if(affected && affected.broken)
			return TRUE
		return FALSE

/datum/surgery_step/set_bone
	name = "set bone"

	time = 64
	implements = list(
	/obj/item/hemostat = 100,	\
	/obj/item/wrench = 35,	\
	/obj/item/crowbar = 25)

/datum/surgery_step/set_bone/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target_zone == "skull")
		user.visible_message("[user] begins to set [target]'s skull with [tool]...", "<span class='notice'>You begin to set [target]'s skull with [tool]...</span>")
	else
		user.visible_message("[user] begins to set the bones in [target]'s [target_zone] with [tool]...", "<span class='notice'>You begin setting the bones in [target]'s [target_zone] with [tool]...</span>")

/datum/surgery_step/set_bone/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] successfully sets the bones in [target]'s [target_zone]!", "<span class='notice'>You successfully set the bones in [target]'s [target_zone].</span>")
	surgery.operated_bodypart.fix_bone()
	return TRUE 
