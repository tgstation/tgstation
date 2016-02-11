/obj/structure/closet/l3closet
	name = "level-3 biohazard gear closet"
	desc = "It's a storage unit for level-3 biohazard gear."
	icon_state = "bio"

/obj/structure/closet/l3closet/New()
	..()
	new /obj/item/weapon/storage/bag/bio( src )
	new /obj/item/clothing/suit/bio_suit/general( src )
	new /obj/item/clothing/head/bio_hood/general( src )


/obj/structure/closet/l3closet/virology
	icon_state = "bio_viro"

/obj/structure/closet/l3closet/virology/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/bag/bio( src )
	new /obj/item/clothing/suit/bio_suit/virology( src )
	new /obj/item/clothing/head/bio_hood/virology( src )


/obj/structure/closet/l3closet/security
	icon_state = "bio_sec"

/obj/structure/closet/l3closet/security/New()
	..()
	contents = list()
	new /obj/item/clothing/suit/bio_suit/security( src )
	new /obj/item/clothing/head/bio_hood/security( src )


/obj/structure/closet/l3closet/janitor
	icon_state = "bio_jan"

/obj/structure/closet/l3closet/janitor/New()
	..()
	contents = list()
	new /obj/item/clothing/suit/bio_suit/janitor( src )
	new /obj/item/clothing/head/bio_hood/janitor( src )


/obj/structure/closet/l3closet/scientist
	icon_state = "bio_viro"

/obj/structure/closet/l3closet/scientist/New()
	..()
	contents = list()
	new /obj/item/weapon/storage/bag/bio( src )
	new /obj/item/clothing/suit/bio_suit/scientist( src )
	new /obj/item/clothing/head/bio_hood/scientist( src )
	
