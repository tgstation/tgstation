/datum/emote/living/carbon/human/piss
	key = "piss"

/datum/emote/living/carbon/human/piss/run_emote(mob/user, params, type_override, intentional)
	. = ..()
	if(!user.get_organ_slot(ORGAN_SLOT_BLADDER) || !ishuman(user))
		to_chat(user, "<span class='warning'>You don't have a bladder!</span>")
		return
	if(user.client?.prefs.read_preference(/datum/preference/toggle/prude_mode))
		return
	var/obj/item/organ/internal/bladder/bladder = user.get_organ_slot(ORGAN_SLOT_BLADDER)
	bladder.urinate()
