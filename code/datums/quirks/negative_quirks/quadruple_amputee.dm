/datum/quirk/quadruple_amputee
	name = "Quadruple Amputee"
	desc = "Oops! All Prosthetics! Due to some truly cruel cosmic punishment, all your limbs have been replaced with surplus prosthetics."
	icon = "tg-prosthetic-full"
	value = -6
	medical_record_text = "During physical examination, patient was found to have all low-budget prosthetic limbs."
	hardcore_value = 6
	quirk_flags = QUIRK_CHANGES_APPEARANCE
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)

/datum/quirk/quadruple_amputee/add_unique(client/client_source)

	quirk_holder.del_and_replace_bodypart(new /obj/item/bodypart/arm/left/robot/surplus, special = TRUE)
	quirk_holder.del_and_replace_bodypart(new /obj/item/bodypart/arm/right/robot/surplus, special = TRUE)
	quirk_holder.del_and_replace_bodypart(new /obj/item/bodypart/leg/left/robot/surplus, special = TRUE)
	quirk_holder.del_and_replace_bodypart(new /obj/item/bodypart/leg/right/robot/surplus, special = TRUE)

/datum/quirk/quadruple_amputee/post_add()
	to_chat(quirk_holder, span_bolddanger("All your limbs have been replaced with surplus prosthetics. They are fragile and will easily come apart under duress. \
	Additionally, you need to use a welding tool and cables to repair them, instead of bruise packs and ointment."))
