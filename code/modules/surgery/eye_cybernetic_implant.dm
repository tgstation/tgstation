/datum/surgery/eye_cybernetic_implant
	name = "eye cybernetic implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/cybernetic_implant, /datum/surgery_step/fix_eyes, /datum/surgery_step/close)
	location = "eyes"

/datum/surgery_step/cybernetic_implant
	accept_any_item = 1
	time = 32

/datum/surgery_step/cybernetic_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to implant [target] with [tool].</span>")

/datum/surgery_step/cybernetic_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(tool)
		if(!istype(tool, /obj/item/organ/cybernetic_implant/eyes))
			user.visible_message("<span class='notice'>[user] can't seem to fit [tool] in [target]'s [target_zone].</span>")
			return 0
		else if(locate(/obj/item/organ/cybernetic_implant/eyes,target.internal_organs))
			user.visible_message("<span class='notice'>[user] can't seem to implant anything else into [target]'s eyes.</span>")
			return 1
		else
			user.visible_message("<span class='notice'>[user] inserts [tool] into [target]'s [target_zone]!</span>")

			var/obj/item/organ/cybernetic_implant/eyes/implant = tool
			implant.owner = target
			implant.function()
			target.internal_organs |= implant
			user.drop_item()
			implant.loc = target

			return 1