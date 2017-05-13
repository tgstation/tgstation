/obj/structure/closet/secure_closet/mime
	name = "Mime closet"
	desc = "Filled with mime stuff"
	icon = 'hippiestation/icons/obj/closet.dmi'
	req_access = list(GLOB.access_theatre)
	icon_state = "mime"

/obj/structure/closet/secure_closet/mime/PopulateContents()
	new /obj/item/toy/crayon/mime(src)
	new /obj/item/clothing/head/beret(src)
	new /obj/item/clothing/mask/gas/mime(src)
	new /obj/item/clothing/shoes/sneakers/mime(src)
	new /obj/item/clothing/under/rank/mime(src)
	new /obj/item/weapon/storage/backpack/mime(src)
	new /obj/item/clothing/gloves/color/white(src)
	new /obj/item/clothing/suit/suspenders(src)

/obj/structure/closet/secure_closet/clown
	name = "Clown closet"
	icon = 'hippiestation/icons/obj/closet.dmi'
	desc = "Filled with clown stuff"
	req_access = list(GLOB.access_theatre)
	icon_state = "clown"

/obj/structure/closet/secure_closet/clown/PopulateContents()
	new /obj/item/toy/crayon/rainbow(src)
	new /obj/item/weapon/stamp/clown(src)
	new /obj/item/clothing/under/rank/clown(src)
	new /obj/item/clothing/shoes/clown_shoes(src)
	new /obj/item/clothing/mask/gas/clown_hat(src)
	new /obj/item/weapon/storage/backpack/clown(src)
	new /obj/item/weapon/bikehorn(src)