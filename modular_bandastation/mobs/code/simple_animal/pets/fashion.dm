// =======
// FASHION
// =======

/datum/dog_fashion/head/beret/sec
	name = "Лейтенант %REAL_NAME%"
	desc = "Уже не младший лейтенант, требующий уважения."
	speak = list()
	icon_file = 'modular_bandastation/mobs/icons/dog_accessories.dmi'
	obj_icon_state = "beret"

/datum/dog_fashion/head/detective
	icon_file = 'modular_bandastation/mobs/icons/dog_accessories.dmi'
	obj_icon_state = "detective"

/datum/dog_fashion/mask
	icon_file = 'modular_bandastation/mobs/icons/dog_accessories.dmi'

/datum/dog_fashion/mask/cigar
	obj_icon_state = "cigar"

// =======
// ITEMS
// =======

/obj/item/clothing/head/fedora/det_hat
	dog_fashion = /datum/dog_fashion/head/detective

/obj/item/clothing/head/beret/sec
	dog_fashion = /datum/dog_fashion/head/beret/sec

/obj/item/clothing/mask/cigarette/cigar
	dog_fashion = /datum/dog_fashion/mask/cigar
