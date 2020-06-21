
//what people wear unrevealed

/datum/outfit/mafia
	name = "Mafia Game Outfit"
	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black

//town

/datum/outfit/job/assistant/mafia

/datum/outfit/job/assistant/mafia/pre_equip(mob/living/carbon/human/H)
	..() //we set it to random colors
	if(H.jumpsuit_style == PREF_SUIT) //then overwrite that to be rainbow jumpsuit
		uniform = /obj/item/clothing/under/color/rainbow
	else
		uniform = /obj/item/clothing/under/color/jumpskirt/rainbow

//mafia

/datum/outfit/mafialing
	head = /obj/item/clothing/head/helmet/changeling
	suit = /obj/item/clothing/suit/armor/changeling

//solo
