/datum/quirk/augmented
	name = "Augmented"
	desc = "All your limbs are replaced with robotic ones, which are more durable, but are vulnerable to EMPs and can be healed only by welding tools and cable coils."
	icon = "tg-prosthetic-full"
	value = 4
	medical_record_text = "During physical examination, patient was found to have all robotic limbs."
	quirk_flags = QUIRK_HUMAN_ONLY | QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)
	/// the original limbs from before the augmented was applied
	var/obj/item/bodypart/old_l_arm
	var/obj/item/bodypart/old_r_arm
	var/obj/item/bodypart/old_l_leg
	var/obj/item/bodypart/old_r_leg

/datum/quirk/augmented/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	old_l_arm = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/arm/left/robot, special = TRUE)
	old_r_arm = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/arm/right/robot, special = TRUE)
	old_l_leg = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/leg/left/robot, special = TRUE)
	old_r_leg = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/leg/right/robot, special = TRUE)

/datum/quirk/augmented/post_add()
	to_chat(quirk_holder, span_boldannounce("All your limbs have been replaced with robotic ones. They are more durable and reistant to damage. Additionally, \
	you need to use a welding tool and cables to repair them, instead of bruise packs and ointment."))

/datum/quirk/augmented/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(old_l_arm, special = TRUE)
	human_holder.del_and_replace_bodypart(old_r_arm, special = TRUE)
	human_holder.del_and_replace_bodypart(old_l_leg, special = TRUE)
	human_holder.del_and_replace_bodypart(old_r_leg, special = TRUE)
	old_l_arm = null
	old_r_arm = null
	old_l_leg = null
	old_r_leg = null