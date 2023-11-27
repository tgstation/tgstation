/datum/quirk/lifesupport
	name = "Life Support"
	desc = "Because of an accident, your heart was replaced with older model of cybernetic life support heart. Be careful, it's incredibly fragrile!"
	icon = FA_ICON_ROBOT
	value = -8
	medical_record_text = "During physical examination, the patient's cybernetic heart was found to be at least 4 generations older than currect models. \
		<b>Please, don't even try touching it or you'll risk blowing their entire body! </b>"
	hardcore_value = 8

/datum/quirk/lifesupport/add_unique(client/client_source)
	var/mob/living/carbon/human/human_holder = quirk_holder
	var/obj/item/organ/internal/heart/cybernetic/lifesupport/new_heart = new /obj/item/organ/internal/heart/cybernetic/lifesupport
	new_heart.Insert(human_holder, special = TRUE, drop_if_replaced = FALSE)
