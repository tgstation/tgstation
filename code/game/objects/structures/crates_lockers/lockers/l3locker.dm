/obj/structure/locker/l3locker
	name = "level 3 biohazard gear locker"
	desc = "It's a storage unit for level 3 biohazard gear."
	icon_state = "bio"

/obj/structure/locker/l3locker/PopulateContents()
	new /obj/item/storage/bag/bio(src)
	new /obj/item/clothing/suit/bio_suit/general(src)
	new /obj/item/clothing/head/bio_hood/general(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)


/obj/structure/locker/l3locker/virology
	icon_state = "bio_viro"

/obj/structure/locker/l3locker/virology/PopulateContents()
	new /obj/item/storage/bag/bio(src)
	new /obj/item/clothing/suit/bio_suit/virology(src)
	new /obj/item/clothing/head/bio_hood/virology(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)


/obj/structure/locker/l3locker/security
	icon_state = "bio_sec"

/obj/structure/locker/l3locker/security/PopulateContents()
	new /obj/item/clothing/suit/bio_suit/security(src)
	new /obj/item/clothing/head/bio_hood/security(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)


/obj/structure/locker/l3locker/janitor
	icon_state = "bio_jan"

/obj/structure/locker/l3locker/janitor/PopulateContents()
	new /obj/item/clothing/suit/bio_suit/janitor(src)
	new /obj/item/clothing/head/bio_hood/janitor(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)


/obj/structure/locker/l3locker/scientist
	icon_state = "bio_viro"

/obj/structure/locker/l3locker/scientist/PopulateContents()
	new /obj/item/storage/bag/xeno(src)
	new /obj/item/clothing/suit/bio_suit/scientist(src)
	new /obj/item/clothing/head/bio_hood/scientist(src)
	new /obj/item/clothing/mask/breath(src)
	new /obj/item/tank/internals/oxygen(src)

