/* Gifts and wrapping paper
 * Contains:
 * Gifts
 * Wrapping Paper
 */

/*
 * Gifts
 */

GLOBAL_LIST_EMPTY(possible_gifts)

/obj/item/a_gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage.dmi'
	icon_state = "giftdeliverypackage3"
	inhand_icon_state = "gift"
	resistance_flags = FLAMMABLE

	var/obj/item/contains_type

/obj/item/a_gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftdeliverypackage[rand(1,5)]"

	contains_type = get_gift_type()

/obj/item/a_gift/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] peeks inside [src] and cries [user.p_them()]self to death! It looks like [user.p_they()] [user.p_were()] on the naughty list..."))
	return (BRUTELOSS)

/obj/item/a_gift/examine(mob/M)
	. = ..()
	if((M.mind && HAS_TRAIT(M.mind, TRAIT_PRESENT_VISION)) || isobserver(M))
		. += span_notice("It contains \a [initial(contains_type.name)].")

/obj/item/a_gift/attack_self(mob/M)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_CANNOT_OPEN_PRESENTS))
		to_chat(M, span_warning("You're supposed to be spreading gifts, not opening them yourself!"))
		return

	qdel(src)

	var/obj/item/I = new contains_type(get_turf(M))
	if (!QDELETED(I)) //might contain something like metal rods that might merge with a stack on the ground
		M.visible_message(span_notice("[M] unwraps \the [src], finding \a [I] inside!"))
		I.investigate_log("([I.type]) was found in a present by [key_name(M)].", INVESTIGATE_PRESENTS)
		M.put_in_hands(I)
		I.add_fingerprint(M)
	else
		M.visible_message(span_danger("Oh no! The present that [M] opened had nothing inside it!"))

/obj/item/a_gift/proc/get_gift_type()
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
		/obj/item/book/manual/wiki/barman_recipes,
		/obj/item/book/manual/chef_recipes,
		/obj/item/bikehorn,
		/obj/item/toy/beach_ball,
		/obj/item/toy/beach_ball/holoball,
		/obj/item/banhammer,
		/obj/item/food/grown/ambrosia/deus,
		/obj/item/food/grown/ambrosia/vulgaris,
		/obj/item/paicard,
		/obj/item/instrument/violin,
		/obj/item/instrument/guitar,
		/obj/item/storage/belt/utility/full,
		/obj/item/clothing/neck/tie/horrible,
		/obj/item/clothing/suit/jacket/leather,
		/obj/item/clothing/suit/jacket/leather/overcoat,
		/obj/item/clothing/suit/costume/poncho,
		/obj/item/clothing/suit/costume/poncho/green,
		/obj/item/clothing/suit/costume/poncho/red,
		/obj/item/clothing/suit/costume/snowman,
		/obj/item/clothing/head/snowman,
		/obj/item/stack/sheet/mineral/coal)

	gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
	gift_type_list += subtypesof(/obj/item/toy) - (((typesof(/obj/item/toy/cards) - /obj/item/toy/cards/deck) + /obj/item/toy/figure + /obj/item/toy/ammo)) //All toys, except for abstract types and syndicate cards.

	var/gift_type = pick(gift_type_list)

	return gift_type


/obj/item/a_gift/anything
	name = "christmas gift"
	desc = "It could be anything!"

/obj/item/a_gift/anything/get_gift_type()
	if(!GLOB.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		for(var/V in gift_types_list)
			var/obj/item/I = V
			if((!initial(I.icon_state)) || (!initial(I.inhand_icon_state)) || (initial(I.item_flags) & ABSTRACT))
				gift_types_list -= V
		GLOB.possible_gifts = gift_types_list
	var/gift_type = pick(GLOB.possible_gifts)

	return gift_type
