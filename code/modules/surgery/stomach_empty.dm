//To remove people from a xeno's stomach
/datum/surgery/stomach_empty/alien
	name = "stomach emptying"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/remove_stomach_contents)
	species = list(/mob/living/carbon/alien/humanoid)
	location = "chest"
	requires_organic_chest = 1


/datum/surgery_step/remove_stomach_contents
	accept_hand = 1
	time = 64
	var/mob/M = null

/datum/surgery_step/remove_stomach_contents/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	M = locate() in target.stomach_contents
	user.visible_message("<span class='notice'>[user] begins to search through [target]'s stomach.</span>")

/datum/surgery_step/remove_stomach_contents/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(M)
		user.visible_message("<span class='notice'>[user] pulls [M] from [target]'s stomach!</span>")
		target.stomach_contents.Remove(M)
		M.loc = target.loc
	else
		user.visible_message("<span class='notice'>[user] can't locate anything in [target]'s stomach!</span>")
	return 1
