/datum/quirk/prosthetic_limb
	name = "Prosthetic Limb"
	desc = "An accident caused you to lose one of your limbs. Because of this, you now have a surplus prosthetic!"
	icon = "tg-prosthetic-leg"
	value = -3
	medical_record_text = "During physical examination, patient was found to have a low-budget prosthetic limb."
	hardcore_value = 3
	quirk_flags = QUIRK_HUMAN_ONLY // while this technically changes appearance, we don't want it to be shown on the dummy because it's randomized at roundstart
	mail_goodies = list(/obj/item/weldingtool/mini, /obj/item/stack/cable_coil/five)
	/// The slot to replace, in string form
	var/slot_string = "limb"
	/// the original limb from before the prosthetic was applied
	var/obj/item/bodypart/old_limb

/datum/quirk/prosthetic_limb/add_unique(client/client_source)
	var/limb_slot = pick(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM, BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/bodypart/prosthetic
	switch(limb_slot)
		if(BODY_ZONE_L_ARM)
			prosthetic = new /obj/item/bodypart/arm/left/robot/surplus
			slot_string = "left arm"
		if(BODY_ZONE_R_ARM)
			prosthetic = new /obj/item/bodypart/arm/right/robot/surplus
			slot_string = "right arm"
		if(BODY_ZONE_L_LEG)
			prosthetic = new /obj/item/bodypart/leg/left/robot/surplus
			slot_string = "left leg"
		if(BODY_ZONE_R_LEG)
			prosthetic = new /obj/item/bodypart/leg/right/robot/surplus
			slot_string = "right leg"
	medical_record_text = "During physical examination, patient was found to have a low-budget prosthetic [slot_string]."
	old_limb = human_holder.return_and_replace_bodypart(prosthetic, special = TRUE)

/datum/quirk/prosthetic_limb/post_add()
	to_chat(quirk_holder, span_boldannounce("Your [slot_string] has been replaced with a surplus prosthetic. It is fragile and will easily come apart under duress. Additionally, \
	you need to use a welding tool and cables to repair it, instead of bruise packs and ointment."))

/datum/quirk/prosthetic_limb/remove()
	var/mob/living/carbon/human/human_holder = quirk_holder
	human_holder.del_and_replace_bodypart(old_limb, special = TRUE)
	old_limb = null
