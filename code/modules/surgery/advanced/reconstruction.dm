/obj/item/disk/surgery/reconstruction
	name = "Reconstruction Surgery Disk"
	desc = "The disk provides instructions on how to repair a body without the use of chemicals."
	surgeries = list(/datum/surgery/advanced/reconstruction)

/datum/surgery/advanced/reconstruction
	name = "body reconstruction"
	steps = list(/datum/surgery_step/incise,
				/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/incise,
				/datum/surgery_step/clamp_bleeders,
				/datum/surgery_step/incise,
				/datum/surgery_step/retract_skin,
				/datum/surgery_step/reconstruct,
				/datum/surgery_step/close)

	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = 0

/datum/surgery_step/reconstruct
	name = "repair body"
	implements = list(/obj/item/hemostat = 100, TOOL_SCREWDRIVER = 35, /obj/item/pen = 15)
	repeatable = TRUE
	time = 25

/datum/surgery_step/reconstruct/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] starts knitting some of [target]'s flesh back together.", "<span class='notice'>You start knitting some of [target]'s flesh back together.</span>")

/datum/surgery_step/reconstruct/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] fixes some of [target]'s wounds.", "<span class='notice'>You succeed in fixing some of [target]'s wounds.</span>")
	target.heal_bodypart_damage(10,10)
	return TRUE

/datum/surgery_step/reconstruct/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("[user] screws up!", "<span class='warning'>You screwed up!</span>")
	target.take_bodypart_damage(5,0)
	return FALSE