/datum/outfit/santa //ho ho ho!
	name = "Santa Claus"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/red
	suit = /obj/item/clothing/suit/space/santa
	head = /obj/item/clothing/head/santa
	back = /obj/item/storage/backpack/santabag
	mask = /obj/item/clothing/mask/breath
	r_pocket = /obj/item/flashlight
	gloves = /obj/item/clothing/gloves/color/red
	belt = /obj/item/tank/internals/emergency_oxygen/double
	id = /obj/item/card/id/gold

/datum/outfit/santa/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return
	H.fully_replace_character_name(H.real_name, "Santa Claus")
	H.mind.assigned_role = "Santa"
	H.mind.special_role = "Santa"

	H.hair_style = "Long Hair"
	H.facial_hair_style = "Full Beard"
	H.hair_color = "FFF"
	H.facial_hair_color = "FFF"

	var/obj/item/storage/backpack/bag = H.back
	var/obj/item/a_gift/gift = new(H)
	while(SEND_SIGNAL(bag, COMSIG_TRY_STORAGE_INSERT, gift, null, TRUE, FALSE))
		gift = new(H)
