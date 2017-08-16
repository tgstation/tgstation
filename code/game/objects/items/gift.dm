/* Gifts and wrapping paper
 * Contains:
 *		Gifts
 *		Wrapping Paper
 */

/*
 * Gifts
 */
/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftdeliverypackage3"
	item_state = "gift1"
	resistance_flags = FLAMMABLE

/obj/item/a_gift/New()
	..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftdeliverypackage[rand(1,5)]"

/obj/item/a_gift/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] peeks inside [src] and cries [user.p_them()]self to death! It looks like [user.p_they()] [user.p_were()] on the naughty list...</span>")
	return (BRUTELOSS)

/obj/item/a_gift/attack_self(mob/M)
	if(M && M.mind && M.mind.special_role == "Santa")
		to_chat(M, "<span class='warning'>You're supposed to be spreading gifts, not opening them yourself!</span>")
		return

	var/gift_type_list = list(/obj/item/sord,
		/obj/item/storage/wallet,
		/obj/item/storage/photo_album,
		/obj/item/storage/box/snappops,
		/obj/item/storage/crayons,
		/obj/item/storage/backpack/holding,
		/obj/item/storage/belt/champion,
		/obj/item/soap/deluxe,
		/obj/item/pickaxe/diamond,
		/obj/item/pen/invisible,
		/obj/item/lipstick/random,
		/obj/item/grenade/smokebomb,
		/obj/item/grown/corncob,
		/obj/item/poster/random_contraband,
		/obj/item/poster/random_official,
		/obj/item/book/manual/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/banhammer,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus,
		/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris,
		/obj/item/device/paicard,
		/obj/item/device/instrument/violin,
		/obj/item/device/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/neck/tie/horrible,
		/obj/item/clothing/suit/jacket/leather,
		/obj/item/clothing/suit/jacket/leather/overcoat,
		/obj/item/clothing/suit/poncho,
		/obj/item/clothing/suit/poncho/green,
		/obj/item/clothing/suit/poncho/red,
		/obj/item/clothing/suit/snowman,
		/obj/item/clothing/head/snowman,
		/obj/item/trash/coal)

	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/toy) - (((typesof(/obj/item/toy/cards) - /obj/item/toy/cards/deck) + /obj/item/toy/figure + /obj/item/toy/ammo)) //All toys, except for abstract types and syndicate cards.

	var/gift_type = pick(gift_type_list)

	if(!ispath(gift_type, /obj/item))
		return

	qdel(src)
	var/obj/item/I = new gift_type(M)
	M.put_in_hands(I)
	I.add_fingerprint(M)
