/* Gifts
 * Contains:
 * Gifts
 */

/// Gifts to give to players, will contain a nice toy or other fun item for them to play with.
/obj/item/gift
	name = "gift"
	desc = "PRESENTS!!!! eek!"
	icon = 'icons/obj/storage/wrapping.dmi'
	icon_state = "giftdeliverypackage3"
	inhand_icon_state = "gift"
	resistance_flags = FLAMMABLE

	/// What type of thing are we guaranteed to spawn in with?
	var/obj/item/contains_type = null
	/// Sound that plays when you tear into the gift, along with the volume it plays at
	var/list/tearsound = list('sound/items/poster/poster_ripped.ogg' = 50)
	/// Random icon on init?
	var/random_icon = TRUE
	/// Do we shift pixels around on init?
	var/random_pixshift = TRUE
	/// The debris we leave when we unwrap a gift. That paper gets EVERYWHERE, man
	var/obj/effect/decal/unwrap_trash = /obj/effect/decal/cleanable/wrapping
	/// Still almost instant, but the little bar adds to the anticipation and thus the dopamine when you get your gift
	var/unwrap_time = 5 DECISECONDS
	/// Pretty much here just for /obj/item/gift/anything/questionmark, but also adds a little more variation to basic gifts
	var/list/unwrap_verbs = list("unwraps", "tears into", "peels open")

/obj/item/gift/Initialize(mapload)
	. = ..()
	if(random_pixshift)
		pixel_x = rand(-10,10)
		pixel_y = rand(-10,10)
	if(random_icon)
		icon_state = "giftdeliverypackage[rand(1,5)]"

	if(isnull(contains_type))
		contains_type = get_gift_type()

/obj/item/gift/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] peeks inside [src] and cries [user.p_them()]self to death! It looks like [user.p_they()] [user.p_were()] on the naughty list..."))
	return BRUTELOSS

/obj/item/gift/examine(mob/user)
	. = ..()
	if(HAS_MIND_TRAIT(user, TRAIT_PRESENT_VISION) || isobserver(user))
		. += span_notice("It contains \a [initial(contains_type.name)].")

/obj/item/gift/attack_self(mob/user)
	if(HAS_MIND_TRAIT(user, TRAIT_CANNOT_OPEN_PRESENTS))
		to_chat(user, span_warning("You're supposed to be spreading gifts, not opening them yourself!"))
		return

	if(!do_after(user, unwrap_time, timed_action_flags = IGNORE_USER_LOC_CHANGE))
		return

	moveToNullspace()

	var/obj/item/thing = new contains_type(get_turf(user))
	if(LAZYLEN(tearsound))
		playsound(get_turf(user), tearsound[1], tearsound[tearsound[1]], TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)
	if(unwrap_trash)
		new unwrap_trash(get_turf(user))
	if (QDELETED(thing)) //might contain something like metal rods that might merge with a stack on the ground
		user.visible_message(span_danger("Oh no! \The [src] that [user] opened had nothing inside it!"))
	else
		user.visible_message(span_notice("[user] [pick(unwrap_verbs)] \the [src], finding \a [thing] inside!"))
		user.investigate_log("has unwrapped a present containing [thing.type].", INVESTIGATE_PRESENTS)
		user.put_in_hands(thing)
		thing.add_fingerprint(user)

	qdel(src)

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

/// Gifts that typically only very OP stuff or admins or Santa Claus himself should be giving out, as they contain ANY valid subtype of `/obj/item`, including stuff like instagib rifles. Wow!
/obj/item/gift/anything
	name = "christmas gift"
	desc = "It could be anything!"

/obj/item/gift/anything/get_gift_type()
	var/static/list/obj/item/possible_gifts = null

	if(isnull(possible_gifts))
		possible_gifts = list()
		for(var/type in subtypesof(/obj/item))
			var/obj/item/thing = type
			if(!initial(thing.icon_state) || !initial(thing.inhand_icon_state) || (initial(thing.item_flags) & ABSTRACT))
				continue

			possible_gifts += type

	var/gift_type = pick(possible_gifts)
	return gift_type
