/datum/martial_art/baby
	name = "Baby"
	id = MARTIALART_BABY

/datum/martial_art/baby/disarm_act(mob/living/carbon/human/Attacker, mob/living/carbon/human/Defender)
	if(Attacker == Defender)
		to_chat(Attacker, "<span class='warning'>You can't disarm yourself!</span>")
		return TRUE
	if(Attacker != Defender)
		return FALSE
	return

/datum/martial_art/baby/grab_act(mob/living/carbon/human/Attacker, mob/living/carbon/human/Defender)
	if(Attacker == Defender)
		to_chat(Attacker, "<span class='warning'>You can't grab yourself!</span>")
		return TRUE
	if(Attacker != Defender)
		return FALSE
	return

/datum/martial_art/baby/harm_act(mob/living/carbon/human/Attacker, mob/living/carbon/human/Defender)
	if(Attacker == Defender)
		to_chat(Attacker, "<span class='warning'>You can't harm yourself!</span>")
		return TRUE
	if(Attacker != Defender)
		return FALSE
	return TRUE

/obj/item/clothing/gloves/baby
	var/datum/martial_art/baby/style = new

/obj/item/clothing/gloves/baby/equipped(mob/user, slot)
	. = ..()
	if(!ishuman(user))
		return
	if(slot == ITEM_SLOT_GLOVES)
		var/mob/living/carbon/human/H = user
		style.teach(H,1)
	return

/obj/item/clothing/gloves/baby/dropped(mob/user)
	. = ..()
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user
	if(H.get_item_by_slot(ITEM_SLOT_GLOVES) == src)
		style.remove(H)
	return
