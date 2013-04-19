/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/service/gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftcrate3"
	item_state = "gift1"


/obj/item/service/gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftcrate[rand(1,5)]"

/obj/item/service/gift/attack_self(mob/M as mob)
	var/gift_type = pick(/obj/item/trash/sord,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/fancy/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/service/soap/deluxe,
		/obj/item/mining/pickaxe/silver,
		/obj/item/office/pen/invisible,
		/obj/item/service/lipstick/random,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/trash/corncob,
		/obj/item/office/contraband/poster,
		/obj/item/office/book/manual/barman_recipes,
		/obj/item/office/book/manual/chef_recipes,
		/obj/item/toy/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/toy/banhammer,
		/obj/item/toy/balloon,
		/obj/item/toy/blink,
		/obj/item/toy/crossbow,
		/obj/item/toy/gun,
		/obj/item/toy/katana,
		/obj/item/toy/prize/deathripley,
		/obj/item/toy/prize/durand,
		/obj/item/toy/prize/fireripley,
		/obj/item/toy/prize/gygax,
		/obj/item/toy/prize/honk,
		/obj/item/toy/prize/marauder,
		/obj/item/toy/prize/mauler,
		/obj/item/toy/prize/odysseus,
		/obj/item/toy/prize/phazon,
		/obj/item/toy/prize/ripley,
		/obj/item/toy/prize/seraph,
		/obj/item/toy/spinningtoy,
		/obj/item/toy/sword,
		/obj/item/chem/food/snacks/grown/ambrosiadeus,
		/obj/item/chem/food/snacks/grown/ambrosiavulgaris,
		/obj/item/device/paicard,
		/obj/item/service/violin,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/tie/horrible)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.u_equip(src)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	del(src)
	return


/*
 * Wrapping Paper
 */
/obj/item/service/gift_wrap
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"


/obj/item/service/gift_wrap/attack_self(mob/user)
	user << "<span class='notice'>You need to use it on a package that has already been wrapped!</span>"