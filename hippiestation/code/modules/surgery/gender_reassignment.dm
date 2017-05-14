/* Remie Richards BTFO */

/datum/surgery/gender_reassignment
	name = "gender reassignment"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/reshape_genitals, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human)
	possible_locs = list("groin")


//reshape_genitals
/datum/surgery_step/reshape_genitals
	name = "reshape genitals"
	implements = list(/obj/item/weapon/scalpel = 100, /obj/item/weapon/hatchet = 50, /obj/item/weapon/wirecutters = 35)
	time = 64

/datum/surgery_step/reshape_genitals/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.gender == FEMALE)
		user.visible_message("[user] begins to reshape [target]'s genitals to look more masculine.", "<span class='notice'>You begin to reshape [target]'s genitals to look more masculine...</span>")
	else
		user.visible_message("[user] begins to reshape [target]'s genitals to look more feminine.", "<span class='notice'>You begin to reshape [target]'s genitals to look more feminine...</span>")

/datum/surgery_step/reshape_genitals/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	if(target.gender == FEMALE)
		user.visible_message("[user] has made a man of [target]!", "<span class='notice'>You made [target] a man.</span>")
		target.gender = MALE
	else
		user.visible_message("[user] has made a woman of [target]!", "<span class='notice'>You made [target] a woman.</span>")
		target.gender = FEMALE
	target.regenerate_icons()
	return 1

/datum/surgery_step/reshape_genitals/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.gender = NEUTER
	user.visible_message("<span class='warning'>[user] accidentally mutilates [target]'s genitals beyond the point of recognition!</span>", "<span class='warning'>You accidentally mutilate [target]'s genitals beyond the point of recognition!</span>")
	target.regenerate_icons()
	return 1