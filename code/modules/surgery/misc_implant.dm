/* MULTITOOL IMPLANT */
// Allows the user to pulse wires in hack panels without a mulitool.

/datum/surgery/mtool_implant
	name = "multitool implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/insert_mtool, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "head"


//inserting tools. look at you, hacker.
/datum/surgery_step/insert_mtool
	implements = list(/obj/item/device/multitool = 100)
	time = 60

/datum/surgery_step/insert_mtool/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to insert the multitool's electronics into [target]'s scalp.</span>")

/datum/surgery_step/insert_mtool/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully implants the multitool in [target]'s head!</span>")
	user.drop_item()
	tool.loc = target
	target.hackimplant = tool
	add_logs(user, target, "augmented", addition="by implanting a multitool. INTENT: [uppertext(user.a_intent)]")
	return 1


/* GOGGLE IMPLANT */
// Allows the user to toggle welding goggles on and off at any time.

/datum/surgery/goggle_implant
	name = "welding goggle implant"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/insert_goggles, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "eyes"


//inserting welding goggles.
/datum/surgery_step/insert_goggles
	implements = list(/obj/item/clothing/glasses/welding = 100)
	time = 60

/datum/surgery_step/insert_goggles/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to insert the goggles into [target]'s eyesockets.</span>")

/datum/surgery_step/insert_goggles/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully implants the welding goggles in [target]'s eyes!</span>")
	user.drop_item()
	qdel(tool)
	var/obj/item/weapon/implant/toggle/weldingshield/I = new/obj/item/weapon/implant/toggle/weldingshield(target)
	if(I.implanted(target))
		I.imp_in = target
		I.implanted = 1
	add_logs(user, target, "augmented", addition="by implanting welding goggles. INTENT: [uppertext(user.a_intent)]")
	return 1