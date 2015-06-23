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
	item_state = "gift1"


/obj/item/weapon/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftcrate[rand(1,5)]"

/obj/item/weapon/a_gift/attack_self(mob/M as mob)
	if(M && M.mind && M.mind.special_role == "Santa")
		M << "<span class='warning'>You're supposed to be spreading gifts, not opening them yourself!</span>"
		return

	var/gift_type_list = list(/obj/item/weapon/sord,
		/obj/item/weapon/storage/wallet,
		/obj/item/weapon/storage/photo_album,
		/obj/item/weapon/storage/box/snappops,
		/obj/item/weapon/storage/fancy/crayons,
		/obj/item/weapon/storage/backpack/holding,
		/obj/item/weapon/storage/belt/champion,
		/obj/item/weapon/soap/deluxe,
		/obj/item/weapon/pickaxe/diamond,
		/obj/item/weapon/pen/invisible,
		/obj/item/weapon/lipstick/random,
		/obj/item/weapon/grenade/smokebomb,
		/obj/item/weapon/grown/corncob,
		/obj/item/weapon/contraband/poster,
		/obj/item/weapon/contraband/poster/legit,
		/obj/item/weapon/book/manual/barman_recipes,
		/obj/item/weapon/book/manual/chef_recipes,
		/obj/item/weapon/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/weapon/banhammer,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/weapon/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/device/paicard,
		/obj/item/device/instrument/violin,
		/obj/item/device/instrument/guitar,
		/obj/item/weapon/storage/belt/utility/full,
		/obj/item/clothing/tie/horrible,
		/obj/item/clothing/suit/jacket/leather,
		/obj/item/clothing/suit/jacket/leather/overcoat,
		/obj/item/clothing/suit/poncho,
		/obj/item/clothing/suit/poncho/green,
		/obj/item/clothing/suit/poncho/red)

	gift_type_list += typesof(/obj/item/clothing/head/collectable) - /obj/item/clothing/head/collectable
	gift_type_list += typesof(/obj/item/toy) - (((typesof(/obj/item/toy/cards) - /obj/item/toy/cards/deck) + /obj/item/toy/ammo) + /obj/item/toy) //All toys, except for abstract types and syndicate cards.

	var/gift_type = pick(gift_type_list)

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
	flags = NOBLUDGEON
	amount = 25
	max_amount = 25

/obj/item/stack/wrapping_paper/attack_self(mob/user)
	user << "<span class='warning'>You need to use it on a package that has already been wrapped!</span>"
