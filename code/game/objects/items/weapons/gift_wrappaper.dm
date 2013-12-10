/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/weapon/a_gift
	name = "gift"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftcrate3"
	item_state = "gift1"
	nonplant_seed_type = "/obj/item/seeds/xmastree"
	var/seed // Needed to stop runtimes

/obj/item/weapon/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftcrate[rand(1,5)]"

/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	var/gift_type
	if(istype(src, /obj/item/weapon/a_gift/endless))
		gift_type = /obj/item/weapon/a_gift/endless
	else if(istype(src, /obj/item/weapon/a_gift/traitor))
		gift_type = /obj/item/weapon/grenade/chem_grenade/incendiary
	else if(istype(src, /obj/item/weapon/a_gift/present))
		gift_type = pick(typesof(/obj/item))
	else
		gift_type = pick(typesof(/obj/item))
	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.u_equip(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	if(istype(I, /obj/item/weapon/grenade/chem_grenade/incendiary))
		var/obj/item/weapon/grenade/chem_grenade/incendiary/thenade = I
		thenade.prime()
	del(src)
	return

/obj/item/weapon/a_gift/endless
	desc = "PRESENTS!!! Something feels odd about this one."
/obj/item/weapon/a_gift/present
	desc = "PRESENTS!!!! eek!"
/obj/item/weapon/a_gift/traitor
	desc = "PRESENTS!!!! eek!"
/*
 * Wrapping Paper
 */
/obj/item/weapon/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"


/obj/item/weapon/wrapping_paper/attack_self(mob/user)
	user << "<span class='notice'>You need to use it on a package that has already been wrapped!</span>"
