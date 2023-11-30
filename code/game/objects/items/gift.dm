/* Gifts and wrapping paper
 * Contains:
 * Gifts
 * Wrapping Paper
 */

/*
 * Gifts
 */

GLOBAL_LIST_EMPTY(possible_gifts)

/obj/item/gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "giftdeliverypackage3"
	inhand_icon_state = "gift"
	resistance_flags = FLAMMABLE

	/// What type of thing are we guaranteed to spawn in with?
	var/obj/item/contains_type = null

/obj/item/gift/Initialize(mapload)
	. = ..()
	pixel_x = rand(-10,10)
	pixel_y = rand(-10,10)
	icon_state = "giftdeliverypackage[rand(1,5)]"

	if(isnull(contains_type))
		contains_type = get_gift_type()

/obj/item/gift/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] peeks inside [src] and cries [user.p_them()]self to death! It looks like [user.p_they()] [user.p_were()] on the naughty list..."))
	return BRUTELOSS

/obj/item/gift/examine(mob/M)
	. = ..()
	if(HAS_MIND_TRAIT(M, TRAIT_PRESENT_VISION) || isobserver(M))
		. += span_notice("It contains \a [initial(contains_type.name)].")

/obj/item/gift/attack_self(mob/M)
	if(HAS_MIND_TRAIT(M, TRAIT_CANNOT_OPEN_PRESENTS))
		to_chat(M, span_warning("You're supposed to be spreading gifts, not opening them yourself!"))
		return

	qdel(src)

	var/obj/item/I = new contains_type(get_turf(M))
	if (!QDELETED(I)) //might contain something like metal rods that might merge with a stack on the ground
		M.visible_message(span_notice("[M] unwraps \the [src], finding \a [I] inside!"))
		M.investigate_log("has unwrapped a present containing [I.type].", INVESTIGATE_PRESENTS)
		M.put_in_hands(I)
		I.add_fingerprint(M)
	else
		M.visible_message(span_danger("Oh no! The present that [M] opened had nothing inside it!"))

/obj/item/gift/proc/get_gift_type()
	var/static/list/gift_type_list = null

	if(isnull(gift_type_list))
		gift_type_list = list(
			/obj/item/banhammer,
			/obj/item/bikehorn,
			/obj/item/book/manual/chef_recipes,
			/obj/item/book/manual/wiki/barman_recipes,
			/obj/item/clothing/head/costume/snowman,
			/obj/item/clothing/neck/tie/horrible,
			/obj/item/clothing/suit/costume/poncho,
			/obj/item/clothing/suit/costume/poncho/green,
			/obj/item/clothing/suit/costume/poncho/red,
			/obj/item/clothing/suit/costume/snowman,
			/obj/item/clothing/suit/jacket/leather,
			/obj/item/clothing/suit/jacket/leather/biker,
			/obj/item/food/grown/ambrosia/deus,
			/obj/item/food/grown/ambrosia/vulgaris,
			/obj/item/grenade/smokebomb,
			/obj/item/grown/corncob,
			/obj/item/instrument/guitar,
			/obj/item/instrument/violin,
			/obj/item/lipstick/random,
			/obj/item/pai_card,
			/obj/item/pen/invisible,
			/obj/item/pickaxe/diamond,
			/obj/item/poster/random_contraband,
			/obj/item/poster/random_official,
			/obj/item/soap/deluxe,
			/obj/item/sord,
			/obj/item/stack/sheet/mineral/coal,
			/obj/item/storage/backpack/holding,
			/obj/item/storage/belt/champion,
			/obj/item/storage/belt/utility/full,
			/obj/item/storage/box/snappops,
			/obj/item/storage/crayons,
			/obj/item/storage/photo_album,
			/obj/item/storage/wallet,
			/obj/item/toy/basketball,
			/obj/item/toy/beach_ball,
		)

		gift_type_list += subtypesof(/obj/item/clothing/head/collectable)
		//Add all toys, except for abstract types and syndicate cards.
		gift_type_list += subtypesof(/obj/item/toy) - (((typesof(/obj/item/toy/cards) - /obj/item/toy/cards/deck) + /obj/item/toy/figure + /obj/item/toy/ammo))

	var/gift_type = pick(gift_type_list)
	return gift_type


/obj/item/gift/anything
	name = "christmas gift"
	desc = "It could be anything!"

/obj/item/gift/anything/get_gift_type()
	if(!GLOB.possible_gifts.len)
		var/list/gift_types_list = subtypesof(/obj/item)
		for(var/V in gift_types_list)
			var/obj/item/I = V
			if((!initial(I.icon_state)) || (!initial(I.inhand_icon_state)) || (initial(I.item_flags) & ABSTRACT))
				gift_types_list -= V
		GLOB.possible_gifts = gift_types_list
	var/gift_type = pick(GLOB.possible_gifts)

	return gift_type
