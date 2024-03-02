/datum/outfit/ghost_player
	name = "Ghost Player"
	shoes = /obj/item/clothing/shoes/sneakers/black
	box = /obj/item/storage/box/survival/engineer

/datum/outfit/ghost_player/pre_equip(mob/living/carbon/human/target, visualsOnly)
	. = ..()
	uniform = (target.jumpsuit_style == PREF_SKIRT) ? /obj/item/clothing/under/color/jumpskirt/grey : /obj/item/clothing/under/color/grey
	switch(target.backpack)
		if(GSATCHEL, DSATCHEL)
			back = /obj/item/storage/backpack/satchel
		if(GDUFFELBAG, DDUFFELBAG)
			back = /obj/item/storage/backpack/duffelbag
		if(LSATCHEL)
			back = /obj/item/storage/backpack/satchel/leather
		else
			back = /obj/item/storage/backpack
