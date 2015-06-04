/datum/surgery/brain_removal
	name = "brain removal"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/extract_brain)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "head"


//extract brain
/datum/surgery_step/extract_brain
	implements = list(/obj/item/weapon/hemostat = 100, /obj/item/weapon/crowbar = 55)
	time = 64
	var/obj/item/organ/brain/B = null

/datum/surgery_step/extract_brain/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	B = target.getorgan(/obj/item/organ/brain)
	if(B)
		user.visible_message("[user] begins to extract [target]'s brain.", "<span class='notice'>You begin to extract [target]'s brain...</span>")
	else
		user.visible_message("[user] looks for a brain in [target].", "<span class='notice'>You look for a brain in [target]...</span>")

/datum/surgery_step/extract_brain/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(B)
		user.visible_message("[user] successfully removes [target]'s brain!", "<span class='notice'>You successfully remove [target]'s brain.</span>")
		B.loc = get_turf(target)
		B.transfer_identity(target)
		target.internal_organs -= B
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			H.update_hair(0)
			H.apply_damage(25,"brute","head")
		add_logs(user, target, "debrained", addition="INTENT: [uppertext(user.a_intent)]")
	else
		user << "<span class='warning'>You can't find a brain in [target]!</span>"
	return 1


//brain removal for aliens
/datum/surgery/brain_removal/alien
	name = "alien brain removal"
	steps = list(/datum/surgery_step/saw, /datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/saw, /datum/surgery_step/extract_brain)
	species = list(/mob/living/carbon/alien/humanoid)
