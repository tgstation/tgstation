/obj/item/clothing/accessory/medal/ribbon/eng
	name = "\"engineer of the shift\" award"
	desc = "An award given to engineers and atmospheric technicians who have exceeded their expectations and gone above and beyond."
	icon = 'icons/Fulpicons/fulp_medals.dmi'
	icon_state = "engineering"

/obj/item/clothing/accessory/medal/ribbon/med
	name = "\"doctor of the shift\" award"
	desc = "An award bestowed only upon medical staff who have performed their duties to the fullest."
	icon = 'icons/Fulpicons/fulp_medals.dmi'
	icon_state = "medical"

/obj/item/storage/lockbox/medal/med
	name = "medical medal box"
	desc = "A locked box used to store medals to be given to members of the medical department."
	req_access = list(ACCESS_CMO)

/obj/item/storage/lockbox/medal/eng
	name = "engineering medal box"
	desc = "A locked box used to store medals to be given to members of the engineering department."
	req_access = list(ACCESS_CE)

/obj/item/storage/lockbox/medal/eng/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/ribbon/eng(src)

/obj/item/storage/lockbox/medal/med/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/clothing/accessory/medal/ribbon/med(src)

/obj/structure/closet/secure_closet/engineering_chief/PopulateContents()
	new /obj/item/storage/lockbox/medal/eng(src)

/obj/structure/closet/secure_closet/CMO/PopulateContents()
	new /obj/item/storage/lockbox/medal/med(src)

