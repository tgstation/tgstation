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
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftcrate3"
	item_state = "gift"


/obj/item/weapon/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftcrate[rand(1,5)]"

/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	var/gift_type = pick(/obj/item/weapon/sord,
		/obj/item/weapon/storage/wallet,
		/obj/item/weapon/storage/photo_album,
		/obj/item/weapon/storage/box/snappops,
		/obj/item/weapon/storage/fancy/crayons,
		/obj/item/weapon/storage/backpack/holding,
		/obj/item/weapon/storage/belt/champion,
		/obj/item/weapon/soap/deluxe,
		/obj/item/weapon/pickaxe/silver,
		/obj/item/weapon/pen/invisible,
		/obj/item/weapon/lipstick/random,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grown/corncob,
		/obj/item/weapon/contraband/poster,
		/obj/item/weapon/book/manual/barman_recipes,
		/obj/item/weapon/book/manual/chef_recipes,
		/obj/item/weapon/bikehorn,
		/obj/item/weapon/beach_ball,
		/obj/item/weapon/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/toy/balloon,
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
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/device/paicard,
		/obj/item/device/violin,
		/obj/item/weapon/storage/belt/utility/full,
		/obj/item/clothing/tie/horrible)

	if(!ispath(gift_type,/obj/item))	return

	var/obj/item/I = new gift_type(M)
	M.unEquip(src, 1)
	M.put_in_hands(I)
	I.add_fingerprint(M)
	qdel(src)
	return


/*
 * Wrapping Paper
 */
/obj/item/stack/wrapping_paper
	name = "wrapping paper"
	desc = "You can use this to wrap items in."
	icon = 'icons/obj/items.dmi'
	icon_state = "wrap_paper"
	amount = 25

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	user << "<span class='notice'>You need to use it on a package that has already been wrapped!</span>"
