/* Closets for specific jobs
 * Contains:
 *		Bartender
 *		Janitor
 *		Lawyer
 */

/*
 * Bartender
 */
/obj/structure/closet/gmcloset
	name = "formal closet"
	desc = "It's a storage unit for formal clothing."
	icon_state = "black"
	icon_closed = "black"

/obj/structure/closet/gmcloset/New()
	..()
	sleep(2)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/head/that(src)
	new /obj/item/clothing/under/sl_suit(src)
	new /obj/item/clothing/under/sl_suit(src)
	new /obj/item/clothing/under/rank/bartender(src)
	new /obj/item/clothing/under/rank/bartender(src)
	new /obj/item/clothing/suit/wcoat(src)
	new /obj/item/clothing/suit/wcoat(src)
	new /obj/item/clothing/shoes/black(src)
	new /obj/item/clothing/shoes/black(src)

/*
 * Janitor
 */
/obj/structure/closet/jcloset
	name = "custodial closet"
	desc = "It's a storage unit for janitorial clothes and gear."
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/structure/closet/jcloset/New()
	..()
	sleep(2)
	new /obj/item/clothing/under/rank/janitor(src)
	new /obj/item/weapon/cartridge/janitor(src)
	new /obj/item/device/flashlight(src)
	new /obj/item/clothing/shoes/galoshes(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/caution(src)
	new /obj/item/weapon/trashbag(src)
	new /obj/item/device/lightreplacer(src)
	new /obj/item/clothing/head/soft/purple(src)

/*
 * Lawyer
 */
/obj/structure/closet/lawcloset
	name = "legal closet"
	desc = "It's a storage unit for courtroom apparel and items."
	icon_state = "blue"
	icon_closed = "blue"

/obj/structure/closet/lawcloset/New()
	new /obj/item/clothing/under/lawyer/female(src)
	new /obj/item/clothing/under/lawyer/black(src)
	new /obj/item/clothing/under/lawyer/red(src)
	new /obj/item/clothing/under/lawyer/bluesuit(src)
	new /obj/item/clothing/suit/lawyer/bluejacket(src)
	new /obj/item/clothing/under/lawyer/purpsuit(src)
	new /obj/item/clothing/suit/lawyer/purpjacket(src)
	new /obj/item/clothing/shoes/brown(src)
	new /obj/item/clothing/shoes/black(src)