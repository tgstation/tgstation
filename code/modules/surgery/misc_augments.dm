/* HACKING AUGMENT */
// Allows the user to pulse wires in hack panels without a mulitool.

/datum/surgery/hacking_augment
	name = "hacking augment"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/insert_hack, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "head"


//inserting tools. look at you, hacker.
/datum/surgery_step/insert_hack
	implements = list(/obj/item/device/multitool = 15, /obj/item/augment/hacking = 100)
	time = 60

/datum/surgery_step/insert_hack/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to insert the electronics into [target]'s scalp.</span>")

/datum/surgery_step/insert_hack/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully augments [target]'s head!</span>")
	user.drop_item()
	tool.loc = target
	target.hackimplant = tool
	add_logs(user, target, "augmented", addition="by adding a hacking aug. INTENT: [uppertext(user.a_intent)]")
	return 1


/* WELDING AUGMENT */
// Allows the user to toggle welding goggles on and off at any time.

/datum/surgery/welding_augment
	name = "welding augment"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/insert_welding, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "eyes"


//inserting welding goggles.
/datum/surgery_step/insert_welding
	implements = list(/obj/item/clothing/glasses/welding = 15, /obj/item/augment/welding = 100)
	time = 60

/datum/surgery_step/insert_welding/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to insert the goggles into [target]'s eyesockets.</span>")

/datum/surgery_step/insert_welding/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully implants the welding goggles in [target]'s eyes!</span>")
	user.drop_item()
	qdel(tool)
	var/obj/item/weapon/implant/toggle/weldingshield/I = new/obj/item/weapon/implant/toggle/weldingshield(target)
	if(I.implanted(target))
		I.imp_in = target
		I.implanted = 1
	add_logs(user, target, "augmented", addition="by adding a welding aug. INTENT: [uppertext(user.a_intent)]")
	return 1

/datum/surgery_step/insert_welding/failure(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='warning'>[user] accidentally stabs [target] through the eye!</span>")
	target.eye_blind = 1


/* FLASHLIGHT AUGMENT */
// Allows the user to toggle an internal flashlight on and off at any time.

/datum/surgery/welding_augment
	name = "welding augment"
	steps = list(/datum/surgery_step/incise, /datum/surgery_step/retract_skin, /datum/surgery_step/clamp_bleeders, /datum/surgery_step/insert_welding, /datum/surgery_step/close)
	species = list(/mob/living/carbon/human, /mob/living/carbon/monkey)
	location = "eyes"


//inserting welding goggles.
/datum/surgery_step/insert_flashlight
	implements = list(/obj/item/augment/flashlight = 100)
	time = 60

/datum/surgery_step/insert_flashlight/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] begins to insert the goggles into [target]'s eyesockets.</span>")

/datum/surgery_step/insert_flashlight/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	user.visible_message("<span class='notice'>[user] successfully implants the welding goggles in [target]'s eyes!</span>")
	user.drop_item()
	qdel(tool)
	var/obj/item/weapon/implant/toggle/flashlight/I = new/obj/item/weapon/implant/toggle/flashlight(target)
	if(I.implanted(target))
		I.imp_in = target
		I.implanted = 1
	add_logs(user, target, "augmented", addition="by adding a flashlight aug. INTENT: [uppertext(user.a_intent)]")
	return 1


/* AUGMENT ITEMS */
// Put augment items below. Make sure these are at the bottom of the file always.

/obj/item/augment
	name = "augment"
	desc = "J-j-jam it in!"
	icon = 'icons/obj/robot_parts.dmi'
	icon_state = "augment"
	item_state = "buildpipe"
	slot_flags = SLOT_BELT
	flags = CONDUCT
	w_class = 2
	m_amt = 100
	g_amt = 100

/obj/item/augment/hacking
	name = "hacking augment"
	desc = "Allows for wire pulsing without the need of a multitool. Inserted surgically."
	icon_state = "augmenthack"

/obj/item/augment/welding
	name = "welding augment"
	desc = "Allows the user to deploy welding shields over their eyes when welding. Inserted surgically."
	icon_state = "augmentweld"

/obj/item/augment/flashlight
	name = "flashlight augment"
	desc = "Allows the user to illuminate their immediate area with a low-level integrated light. Inserted surgically."
	icon_state = "augmentflash"