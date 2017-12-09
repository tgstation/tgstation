/obj/item/clothing/head/helmet/knight
	alternate_screams = list('hippiestation/sound/voice/deus_vult.ogg')

/obj/item/clothing/head/helmet/knight/equipped(mob/living/carbon/user, slot)
	if(!ishuman(user))
		return
	if(slot == slot_head)
		var/mob/living/carbon/human/H = user
		H.reindex_screams()
	return ..()