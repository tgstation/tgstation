/*
 * The 'fancy' path is for objects like donut boxes that show how many items are in the storage item on the sprite itself
 * .. Sorry for the shitty path name, I couldnt think of a better one.
 *
 * Contains:
 * Donut Box
 * Egg Box
 * Candle Box
 * Cigarette Box
 * Rolling Paper Pack
 * Cigar Case
 * Heart Shaped Box w/ Chocolates
 * Coffee condiments display
 */

/obj/item/storage/fancy
	icon = 'icons/obj/food/containers.dmi'
	resistance_flags = FLAMMABLE
	custom_materials = list(/datum/material/cardboard = 2000)
	/// Used by examine to report what this thing is holding.
	var/contents_tag = "errors"
	/// What type of thing to fill this storage with.
	var/spawn_type
	/// How many of the things to fill this storage with.
	var/spawn_count = 0
	/// Whether the container is open, always open, or closed
	var/open_status = FANCY_CONTAINER_CLOSED
	/// What material do we get when we fold this box?
	var/foldable_result = /obj/item/stack/sheet/cardboard
	/// Whether it supports open and closed state icons.
	var/has_open_closed_states = TRUE

/obj/item/storage/fancy/Initialize(mapload)
	. = ..()

	atom_storage.max_slots = spawn_count

/obj/item/storage/fancy/PopulateContents()
	if(!spawn_type)
		return
	for(var/i = 1 to spawn_count)
		var/thing_in_box = pick(spawn_type)
		new thing_in_box(src)

/obj/item/storage/fancy/update_icon_state()
	icon_state = "[base_icon_state][has_open_closed_states && open_status ? contents.len : null]"
	return ..()

/obj/item/storage/fancy/examine(mob/user)
	. = ..()
	if(!open_status)
		return
	if(length(contents) == 1)
		. += "There is one [contents_tag] left."
	else
		. += "There are [contents.len <= 0 ? "no" : "[contents.len]"] [contents_tag]s left."

/obj/item/storage/fancy/attack_self(mob/user)
	if(open_status == FANCY_CONTAINER_CLOSED)
		open_status = FANCY_CONTAINER_OPEN
	else if(open_status == FANCY_CONTAINER_OPEN)
		open_status = FANCY_CONTAINER_CLOSED

	update_appearance()
	. = ..()
	if(contents.len)
		return
	if(!foldable_result || (flags_1 & HOLOGRAM_1))
		return
	var/obj/item/result = new foldable_result(user.drop_location())
	balloon_alert(user, "folded")
	// Gotta delete first, so then the cardboard appears in the same hand
	qdel(src)
	user.put_in_hands(result)

/obj/item/storage/fancy/Exited(atom/movable/gone, direction)
	. = ..()
	if(open_status == FANCY_CONTAINER_CLOSED)
		open_status = FANCY_CONTAINER_OPEN
	update_appearance()

/obj/item/storage/fancy/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(open_status == FANCY_CONTAINER_CLOSED)
		open_status = FANCY_CONTAINER_OPEN
	update_appearance()

#define DONUT_INBOX_SPRITE_WIDTH 3

/*
 * Donut Box
 */

/obj/item/storage/fancy/donut_box
	name = "donut box"
	desc = "Mmm. Donuts."
	icon = 'icons/obj/food/donuts.dmi'
	icon_state = "donutbox_open" //composite image used for mapping
	base_icon_state = "donutbox"
	spawn_type = /obj/item/food/donut/plain
	spawn_count = 6
	open_status = TRUE
	appearance_flags = KEEP_TOGETHER|LONG_GLIDE
	custom_premium_price = PAYCHECK_COMMAND * 1.75
	contents_tag = "donut"

/obj/item/storage/fancy/donut_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/food/donut))

/obj/item/storage/fancy/donut_box/PopulateContents()
	. = ..()
	update_appearance()

/obj/item/storage/fancy/donut_box/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][open_status ? "_inner" : null]"

/obj/item/storage/fancy/donut_box/update_overlays()
	. = ..()
	if(!open_status)
		return

	var/donuts = 0
	for(var/_donut in contents)
		var/obj/item/food/donut/donut = _donut
		if (!istype(donut))
			continue

		. += image(icon = initial(icon), icon_state = donut.in_box_sprite(), pixel_x = donuts * DONUT_INBOX_SPRITE_WIDTH)
		donuts += 1

	. += image(icon = initial(icon), icon_state = "[base_icon_state]_top")

#undef DONUT_INBOX_SPRITE_WIDTH

/*
 * Egg Box
 */

/obj/item/storage/fancy/egg_box
	icon = 'icons/obj/food/containers.dmi'
	inhand_icon_state = "eggbox"
	icon_state = "eggbox"
	base_icon_state = "eggbox"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	name = "egg box"
	desc = "A carton for containing eggs."
	spawn_type = /obj/item/food/egg
	spawn_count = 12
	contents_tag = "egg"

/obj/item/storage/fancy/egg_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/food/egg))

/*
 * Candle Box
 */

/obj/item/storage/fancy/candle_box
	name = "candle pack"
	desc = "A pack of red candles."
	icon = 'icons/obj/candle.dmi'
	icon_state = "candlebox5"
	base_icon_state = "candlebox"
	inhand_icon_state = null
	worn_icon_state = "cigpack"
	throwforce = 2
	slot_flags = ITEM_SLOT_BELT
	spawn_type = /obj/item/flashlight/flare/candle
	spawn_count = 5
	open_status = FANCY_CONTAINER_ALWAYS_OPEN
	contents_tag = "candle"


////////////
//CIG PACK//
////////////
/obj/item/storage/fancy/cigarettes
	name = "\improper Space Cigarettes packet"
	desc = "The most popular brand of cigarettes, sponsors of the Space Olympics. On the back it advertises to be the only brand that can be smoked in the vaccum of space."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig"
	inhand_icon_state = "cigpacket"
	worn_icon_state = "cigpack"
	base_icon_state = "cig"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	slot_flags = ITEM_SLOT_BELT
	spawn_type = /obj/item/clothing/mask/cigarette/space_cigarette
	spawn_count = 6
	custom_price = PAYCHECK_CREW
	age_restricted = TRUE
	contents_tag = "cigarette"
	///for cigarette overlay
	var/candy = FALSE
	/// Does this cigarette packet come with a coupon attached?
	var/spawn_coupon = TRUE
	/// For VV'ing, set this to true if you want to force the coupon to give an omen
	var/rigged_omen = FALSE
	///Do we not have our own handling for cig overlays?
	var/display_cigs = TRUE

/obj/item/storage/fancy/cigarettes/attack_self(mob/user)
	if(contents.len != 0 || !spawn_coupon)
		return ..()

	balloon_alert(user, "ooh, free coupon")
	var/obj/item/coupon/attached_coupon = new
	user.put_in_hands(attached_coupon)
	attached_coupon.generate(rigged_omen)
	attached_coupon = null
	spawn_coupon = FALSE
	name = "discarded cigarette packet"
	desc = "An old cigarette packet with the back torn off, worth less than nothing now."
	atom_storage.max_slots = 0

/obj/item/storage/fancy/cigarettes/Initialize(mapload)
	. = ..()
	atom_storage.display_contents = FALSE
	atom_storage.set_holdable(list(/obj/item/clothing/mask/cigarette, /obj/item/lighter))
	register_context()

/obj/item/storage/fancy/cigarettes/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	quick_remove_item(/obj/item/clothing/mask/cigarette, user)

/obj/item/storage/fancy/cigarettes/AltClick(mob/user)
	. = ..()
	var/obj/item/lighter = locate(/obj/item/lighter) in contents
	if(lighter)
		quick_remove_item(lighter, user)
	else
		quick_remove_item(/obj/item/clothing/mask/cigarette, user)

/// Removes an item from the packet if there is one
/obj/item/storage/fancy/cigarettes/proc/quick_remove_item(obj/item/grabbies, mob/user)
	var/obj/item/finger = locate(grabbies) in contents
	if(finger)
		atom_storage.attempt_remove(finger, drop_location())
		user.put_in_hands(finger)

/obj/item/storage/fancy/cigarettes/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	if(locate(/obj/item/lighter) in contents)
		context[SCREENTIP_CONTEXT_ALT_LMB] = "Remove lighter"
	context[SCREENTIP_CONTEXT_RMB] = "Remove [contents_tag]"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/storage/fancy/cigarettes/examine(mob/user)
	. = ..()

	if(spawn_coupon)
		. += span_notice("There's a coupon on the back of the pack! You can tear it off once it's empty.")

/obj/item/storage/fancy/cigarettes/update_icon_state()
	. = ..()
	icon_state = "[base_icon_state][contents.len ? null : "_empty"]"

/obj/item/storage/fancy/cigarettes/update_overlays()
	. = ..()
	if(!open_status || !contents.len)
		return

	. += "[icon_state]_open"

	if(!display_cigs)
		return

	var/cig_position = 1
	for(var/C in contents)
		var/use_icon_state = ""

		if(istype(C, /obj/item/lighter/greyscale))
			use_icon_state = "lighter_in"
		else if(istype(C, /obj/item/lighter))
			use_icon_state = "zippo_in"
		else if(candy)
			use_icon_state = "candy"
		else
			use_icon_state = "cigarette"

		. += "[use_icon_state]_[cig_position]"
		cig_position++

/obj/item/storage/fancy/cigarettes/dromedaryco
	name = "\improper DromedaryCo packet"
	desc = "A packet of six imported DromedaryCo cancer sticks. A label on the packaging reads, \"Wouldn't a slow death make a change?\""
	icon_state = "dromedary"
	base_icon_state = "dromedary"
	spawn_type = /obj/item/clothing/mask/cigarette/dromedary

/obj/item/storage/fancy/cigarettes/cigpack_uplift
	name = "\improper Uplift Smooth packet"
	desc = "Your favorite brand, now menthol flavored."
	icon_state = "uplift"
	base_icon_state = "uplift"
	spawn_type = /obj/item/clothing/mask/cigarette/uplift

/obj/item/storage/fancy/cigarettes/cigpack_robust
	name = "\improper Robust packet"
	desc = "Smoked by the robust."
	icon_state = "robust"
	base_icon_state = "robust"
	spawn_type = /obj/item/clothing/mask/cigarette/robust

/obj/item/storage/fancy/cigarettes/cigpack_robustgold
	name = "\improper Robust Gold packet"
	desc = "Smoked by the truly robust."
	icon_state = "robustg"
	base_icon_state = "robustg"
	spawn_type = /obj/item/clothing/mask/cigarette/robustgold

/obj/item/storage/fancy/cigarettes/cigpack_carp
	name = "\improper Carp Classic packet"
	desc = "Since 2313."
	icon_state = "carp"
	base_icon_state = "carp"
	spawn_type = /obj/item/clothing/mask/cigarette/carp

/obj/item/storage/fancy/cigarettes/cigpack_syndicate
	name = "cigarette packet"
	desc = "An obscure brand of cigarettes."
	icon_state = "syndie"
	base_icon_state = "syndie"
	spawn_type = /obj/item/clothing/mask/cigarette/syndicate

/obj/item/storage/fancy/cigarettes/cigpack_midori
	name = "\improper Midori Tabako packet"
	desc = "You can't understand the runes, but the packet smells funny."
	icon_state = "midori"
	base_icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/nicotine

/obj/item/storage/fancy/cigarettes/cigpack_candy
	name = "\improper Timmy's First Candy Smokes packet"
	desc = "Unsure about smoking? Want to bring your children safely into the family tradition? Look no more with this special packet! Includes 100%* Nicotine-Free candy cigarettes."
	icon_state = "candy"
	base_icon_state = "candy"
	contents_tag = "candy cigarette"
	spawn_type = /obj/item/clothing/mask/cigarette/candy
	candy = TRUE
	age_restricted = FALSE

/obj/item/storage/fancy/cigarettes/cigpack_candy/Initialize(mapload)
	. = ..()
	if(prob(7))
		spawn_type = /obj/item/clothing/mask/cigarette/candy/nicotine //uh oh!

/obj/item/storage/fancy/cigarettes/cigpack_shadyjims
	name = "\improper Shady Jim's Super Slims packet"
	desc = "Is your weight slowing you down? Having trouble running away from gravitational singularities? Can't stop stuffing your mouth? Smoke Shady Jim's Super Slims and watch all that fat burn away. Guaranteed results!"
	icon_state = "shadyjim"
	base_icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/shadyjims

/obj/item/storage/fancy/cigarettes/cigpack_xeno
	name = "\improper Xeno Filtered packet"
	desc = "Loaded with 100% pure slime. And also nicotine."
	icon_state = "slime"
	base_icon_state = "slime"
	spawn_type = /obj/item/clothing/mask/cigarette/xeno

/obj/item/storage/fancy/cigarettes/cigpack_cannabis
	name = "\improper Freak Brothers' Special packet"
	desc = "A label on the packaging reads, \"Endorsed by Phineas, Freddy and Franklin.\""
	icon_state = "midori"
	base_icon_state = "midori"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/cannabis

/obj/item/storage/fancy/cigarettes/cigpack_mindbreaker
	name = "\improper Leary's Delight packet"
	desc = "Banned in over 36 galaxies."
	icon_state = "shadyjim"
	base_icon_state = "shadyjim"
	spawn_type = /obj/item/clothing/mask/cigarette/rollie/mindbreaker

/obj/item/storage/fancy/rollingpapers
	name = "rolling paper pack"
	desc = "A pack of Nanotrasen brand rolling papers."
	w_class = WEIGHT_CLASS_TINY
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cig_paper_pack"
	base_icon_state = "cig_paper_pack"
	contents_tag = "rolling paper"
	spawn_type = /obj/item/rollingpaper
	spawn_count = 10
	custom_price = PAYCHECK_LOWER
	has_open_closed_states = FALSE

/obj/item/storage/fancy/rollingpapers/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/rollingpaper))

/obj/item/storage/fancy/rollingpapers/update_overlays()
	. = ..()
	if(!contents.len)
		. += "[base_icon_state]_empty"

/////////////
//CIGAR BOX//
/////////////

/obj/item/storage/fancy/cigarettes/cigars
	name = "\improper premium cigar case"
	desc = "A case of premium cigars. Very expensive."
	icon = 'icons/obj/cigarettes.dmi'
	icon_state = "cigarcase"
	base_icon_state = "cigarcase"
	w_class = WEIGHT_CLASS_NORMAL
	contents_tag = "premium cigar"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar
	spawn_count = 5
	spawn_coupon = FALSE
	display_cigs = FALSE

/obj/item/storage/fancy/cigarettes/cigars/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/clothing/mask/cigarette/cigar))

/obj/item/storage/fancy/cigarettes/cigars/update_icon_state()
	. = ..()
	//reset any changes the parent call may have made
	icon_state = base_icon_state

/obj/item/storage/fancy/cigarettes/cigars/update_overlays()
	. = ..()
	if(!open_status)
		return
	var/cigar_position = 1 //generate sprites for cigars in the box
	for(var/obj/item/clothing/mask/cigarette/cigar/smokes in contents)
		. += "[smokes.icon_off]_[cigar_position]"
		cigar_position++

/obj/item/storage/fancy/cigarettes/cigars/cohiba
	name = "\improper Cohiba Robusto cigar case"
	desc = "A case of imported Cohiba cigars, renowned for their strong flavor."
	icon_state = "cohibacase"
	base_icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/cohiba

/obj/item/storage/fancy/cigarettes/cigars/havana
	name = "\improper premium Havanian cigar case"
	desc = "A case of classy Havanian cigars."
	icon_state = "cohibacase"
	base_icon_state = "cohibacase"
	spawn_type = /obj/item/clothing/mask/cigarette/cigar/havana

/*
 * Heart Shaped Box w/ Chocolates
 */

/obj/item/storage/fancy/heart_box
	name = "heart-shaped box"
	desc = "A heart-shaped box for holding tiny chocolates."
	icon = 'icons/obj/food/containers.dmi'
	inhand_icon_state = "chocolatebox"
	icon_state = "chocolatebox"
	base_icon_state = "chocolatebox"
	lefthand_file = 'icons/mob/inhands/items/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/food_righthand.dmi'
	contents_tag = "chocolate"
	spawn_type = list(
		/obj/item/food/bonbon,
		/obj/item/food/bonbon/chocolate_truffle,
		/obj/item/food/bonbon/caramel_truffle,
		/obj/item/food/bonbon/peanut_truffle,
		/obj/item/food/bonbon/peanut_butter_cup,
	)
	spawn_count = 8

/obj/item/storage/fancy/heart_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/food/bonbon))


/obj/item/storage/fancy/nugget_box
	name = "nugget box"
	desc = "A cardboard box used for holding chicken nuggies."
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "nuggetbox"
	base_icon_state = "nuggetbox"
	contents_tag = "nugget"
	spawn_type = /obj/item/food/nugget
	spawn_count = 6

/obj/item/storage/fancy/nugget_box/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/food/nugget))

/*
 * Jar of pickles
 */

/obj/item/storage/fancy/pickles_jar
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "pickles"
	base_icon_state = "pickles"
	name = "pickles"
	desc = "A jar for containing pickles."
	spawn_type = /obj/item/food/pickle
	spawn_count = 10
	contents_tag = "pickle"
	foldable_result = null
	custom_materials = list(/datum/material/glass = 2000)
	open_status = FANCY_CONTAINER_ALWAYS_OPEN
	has_open_closed_states = FALSE

/obj/item/storage/fancy/pickles_jar/Initialize(mapload)
	. = ..()
	atom_storage.set_holdable(list(/obj/item/food/pickle))

/obj/item/storage/fancy/pickles_jar/update_icon_state()
	. = ..()
	if(!contents.len)
		icon_state = "[base_icon_state]_empty"
	else
		if(contents.len < 5)
			icon_state = "[base_icon_state]_[contents.len]"
		else
			icon_state = base_icon_state

/*
 * Coffee condiments display
 */

/obj/item/storage/fancy/coffee_condi_display
	icon = 'icons/obj/food/containers.dmi'
	icon_state = "coffee_condi_display"
	base_icon_state = "coffee_condi_display"
	name = "coffee condiments display"
	desc = "A neat small wooden box, holding all your favorite coffee condiments."
	contents_tag = "coffee condiment"
	custom_materials = list(/datum/material/wood = 1000)
	foldable_result = /obj/item/stack/sheet/mineral/wood
	open_status = FANCY_CONTAINER_ALWAYS_OPEN
	has_open_closed_states = FALSE

/obj/item/storage/fancy/coffee_condi_display/Initialize(mapload)
	. = ..()
	atom_storage.max_slots = 14
	atom_storage.set_holdable(list(
		/obj/item/reagent_containers/condiment/pack/sugar,
		/obj/item/reagent_containers/condiment/creamer,
		/obj/item/reagent_containers/condiment/pack/astrotame,
		/obj/item/reagent_containers/condiment/chocolate,
	))

/obj/item/storage/fancy/coffee_condi_display/update_overlays()
	. = ..()
	var/has_sugar = FALSE
	var/has_sweetener = FALSE
	var/has_creamer = FALSE
	var/has_chocolate = FALSE

	for(var/thing in contents)
		if(istype(thing, /obj/item/reagent_containers/condiment/pack/sugar))
			has_sugar = TRUE
		else if(istype(thing, /obj/item/reagent_containers/condiment/pack/astrotame))
			has_sweetener = TRUE
		else if(istype(thing, /obj/item/reagent_containers/condiment/creamer))
			has_creamer = TRUE
		else if(istype(thing, /obj/item/reagent_containers/condiment/chocolate))
			has_chocolate = TRUE

	if (has_sugar)
		. += "condi_display_sugar"
	if (has_sweetener)
		. += "condi_display_sweetener"
	if (has_creamer)
		. += "condi_display_creamer"
	if (has_chocolate)
		. += "condi_display_chocolate"

/obj/item/storage/fancy/coffee_condi_display/PopulateContents()
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/condiment/pack/sugar(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/condiment/pack/astrotame(src)
	for(var/i in 1 to 4)
		new /obj/item/reagent_containers/condiment/creamer(src)
	for(var/i in 1 to 3)
		new /obj/item/reagent_containers/condiment/chocolate(src)
	update_appearance()
