/datum/quirk/quadruple_amputee
	name = "Quadruple Amputee"
	desc = "Oops! All Prosthetics! Due to some truly cruel cosmic punishment, all your limbs have been replaced with surplus prosthetics."
	icon = "tg-prosthetic-full"
	value = -6
	medical_record_text = "During physical examination, patient was found to have all low-budget prosthetic limbs."
	hardcore_value = 6
	quirk_flags = QUIRK_HUMAN_ONLY|QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)
	
	/// the original limbs from before the аugmented was applied
	var/obj/item/bodypart/old_l_arm
	var/obj/item/bodypart/old_r_arm
	var/obj/item/bodypart/old_l_leg
	var/obj/item/bodypart/old_r_leg

/datum/quirk/quadruple_amputee/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	old_l_arm = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/arm/left/robot/surplus, special = TRUE)
	old_r_arm = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/arm/right/robot/surplus, special = TRUE)
	old_l_leg = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/leg/left/robot/surplus, special = TRUE)
	old_r_leg = human_holder.return_and_replace_bodypart(new /obj/item/bodypart/leg/right/robot/surplus, special = TRUE)

/datum/quirk/quadruple_amputee/post_add()
	to_chat(quirk_holder, span_bolddanger("All your limbs have been replaced with surplus prosthetics. They are fragile and will easily come apart under duress. \
	Additionally, you need to use a welding tool and cables to repair them, instead of bruise packs and ointment."))

/datum/quirk/quadruple_amputee/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(old_l_arm, special = TRUE)
	human_holder.del_and_replace_bodypart(old_r_arm, special = TRUE)
	human_holder.del_and_replace_bodypart(old_l_leg, special = TRUE)
	human_holder.del_and_replace_bodypart(old_r_leg, special = TRUE)
	old_l_arm = null
	old_r_arm = null
	old_l_leg = null
	old_r_leg = null
