/obj/structure/flora
	resistance_flags = FLAMMABLE
	max_integrity = 150
	anchored = TRUE
	/// Flags for the flora to determine what kind of sound to play when it gets hit
	var/flora_flags = NONE

	/// A lazylist of products that could be created when harvesting this flora, syntax is (type = weight)
	var/product_types = null
	
	//Temporary variables to work off of, make this modular as if it were a component and document later
	var/harvested_name as text
	var/harvested_desc as text
	var/harvest_amount_low = 1
	var/harvest_amount_high = 3
	var/harvest_message_low as text
	var/harvest_message_med as text
	var/harvest_message_high as text
	var/harvest_time = 60
	var/regrowth_time_low = 8 MINUTES
	var/regrowth_time_high = 16 MINUTES
	var/harvested = FALSE
	var/needs_sharp_harvest = TRUE
	var/delete_on_harvest = FALSE
	var/harvest_message_true_thresholds = FALSE	//Whether or not to divide the messages into thirds depending on how much was harvested

/obj/structure/flora/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	if(flora_flags == NONE)
		return ..()
	if(flora_flags & FLORA_HERBAL)
		playsound(src, SFX_CRUNCHY_BUSH_WHACK, 50, vary = FALSE)
	if(flora_flags & FLORA_WOODEN)
		playsound(src, SFX_TREE_CHOP, 50, vary = FALSE)
	if(flora_flags & FLORA_STONE)
		playsound(src, SFX_ROCK_TAP, 50, vary = FALSE)

/obj/structure/flora/proc/get_products_list()
	. = list()
	if(!LAZYLEN(product_types))
		return

	var/harvest_amount = rand(harvest_amount_low, harvest_amount_high)
	for(var/iteration in 1 to harvest_amount)
		var/chosen_product = pick_weight(product_types)
		if(!.[chosen_product])
			.[chosen_product] = 0
		.[chosen_product]++

/obj/structure/flora/proc/harvest(user)
	. = FALSE
	if(harvested && !LAZYLEN(product_types))
		return
	
	var/list/products_to_create = get_products_list()
	if(!products_to_create.len)
		return

	var/products_created = 0
	var/turf/turf_below = get_turf(src)

	//This loop creates new products on the turf of our flora, but checks if it's an item stack
	//If it *is* an item stack, we don't want to go through 50 different iterations of a new object where it just gets qdeleted after the first
	for(var/product in products_to_create)
		var/amount_to_create = products_to_create[product]
		products_created += amount_to_create
		if(ispath(product, /obj/item/stack))
			var/product_left = amount_to_create
			while(product_left > 0)
				var/obj/item/stack/new_stack = new product(turf_below)
				product_left -= new_stack.amount = min(product_left, new_stack.max_amount)
		else
			for(var/iteration in 1 to amount_to_create)
				new product(turf_below)

	//This bit of code determines what should be shown to the user when this is harvested
	var/message = harvest_message_med || harvest_message_high || harvest_message_low
	if(user)
		if(harvest_message_true_thresholds) //Old method of how the harvest messages worked. Useful depending on the context you want to implement
			if(products_created == harvest_amount_low && harvest_message_low)
				message = harvest_message_low
			if(products_created == harvest_amount_high && harvest_message_high)
				message = harvest_message_high
		else //New method of determining the message to display. Separates the messages into 3 different viable "regions" [   ][   ][   ]
			var/comparison = products_created - harvest_amount_low //Avoiding unnecessary math
			var/middle_value = round((harvest_amount_high - harvest_amount_low)/2) + harvest_amount_low //The exact (rounded) middle between the high and low
			if(comparison < (middle_value - harvest_amount_low)/2 && harvest_message_low) //[***][   ][   ]
				message = harvest_message_low
			if(comparison > (harvest_message_high - middle_value)/2 && harvest_message_high) //[   ][   ][***]
				message = harvest_message_high
			//[   ][***][   ] use the default message if none of the above applies

		to_chat(user, span_notice(message))
		

	if(harvested_name)
		name = harvested_name
	if(harvested_desc)
		desc = harvested_desc
	harvested = TRUE
	if(!delete_on_harvest)
		addtimer(CALLBACK(src, .proc/regrow), rand(regrowth_time_low, regrowth_time_high))
	return TRUE

/obj/structure/flora/proc/after_harvest(user)
	if(delete_on_harvest)
		qdel(src)

/obj/structure/flora/proc/regrow()
	name = initial(name)
	desc = initial(desc)
	harvested = FALSE

/obj/structure/flora/attackby(obj/item/W, mob/user, params)
	if(!harvested && needs_sharp_harvest && W.get_sharpness())
		user.visible_message(span_notice("[user] starts to harvest from [src] with [W]."),span_notice("You begin to harvest from [src] with [W]."))
		if(do_after(user, harvest_time, target = src))
			if(harvest(user))
				after_harvest(user)
	else
		return ..()

/obj/structure/flora/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!harvested && !needs_sharp_harvest)
		user.visible_message(span_notice("[user] starts to harvest from [src]."),span_notice("You begin to harvest from [src]."))
		if(do_after(user, harvest_time, target = src))
			if(harvest(user))
				after_harvest(user)

/*********
 * Trees *
 *********/
//Can *you* speak their language?

/obj/structure/flora/tree
	name = "tree"
	desc = "A large tree."
	density = TRUE
	pixel_x = -16
	layer = FLY_LAYER
	plane = ABOVE_GAME_PLANE
	product_types = list(/obj/item/grown/log/tree = 1)
	harvest_amount_low = 6
	harvest_amount_high = 10
	harvest_message_low = "You manage to gather a few logs from the tree."
	harvest_message_med = "You manage to gather some logs from the tree."
	harvest_message_high = "You harvest most of the wood from the tree."
	delete_on_harvest = TRUE
	flora_flags = FLORA_HERBAL | FLORA_WOODEN

/obj/structure/flora/tree/harvest(user)
	if(!..())
		return FALSE
	var/turf/my_turf = get_turf(src)
	playsound(my_turf, 'sound/effects/meteorimpact.ogg', 100 , FALSE, FALSE)
	var/obj/structure/flora/stump/new_stump = new(my_turf)
	new_stump.name = "[name] stump"
	qdel(src)
	return TRUE

/obj/structure/flora/stump
	name = "stump"
	desc = "This represents our promise to the crew, and the station itself, to cut down as many trees as possible." //running naked through the trees
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "tree_stump"
	density = FALSE
	pixel_x = -16
	product_types = list(/obj/item/grown/log/tree = 1)
	harvest_amount_low = 1
	harvest_amount_high = 1
	harvest_message_low = "You manage to cut up the stump from the ground, somehow."
	delete_on_harvest = TRUE
	flora_flags = FLORA_WOODEN

/obj/structure/flora/tree/dead
	icon = 'icons/obj/flora/deadtrees.dmi'
	desc = "A dead tree. How it died, you know not."
	icon_state = "tree_1"
	harvest_amount_low = 2
	harvest_amount_high = 6
	flora_flags = FLORA_WOODEN

/obj/structure/flora/tree/dead/style_2
	icon_state = "tree_2"
/obj/structure/flora/tree/dead/style_3
	icon_state = "tree_3"
/obj/structure/flora/tree/dead/style_4
	icon_state = "tree_4"
/obj/structure/flora/tree/dead/style_5
	icon_state = "tree_5"
/obj/structure/flora/tree/dead/style_6
	icon_state = "tree_6"
/obj/structure/flora/tree/dead/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tree_[rand(1, 6)]"

/obj/structure/flora/tree/jungle
	desc = "It's seriously hampering your view of the jungle."
	icon = 'icons/obj/flora/jungletrees.dmi'
	icon_state = "tree1"
	pixel_x = -48
	pixel_y = -20

/obj/structure/flora/tree/jungle/style_2
	icon_state = "tree2"
/obj/structure/flora/tree/jungle/style_3
	icon_state = "tree3"
/obj/structure/flora/tree/jungle/style_4
	icon_state = "tree4"
/obj/structure/flora/tree/jungle/style_5
	icon_state = "tree5"
/obj/structure/flora/tree/jungle/style_6
	icon_state = "tree6"
/obj/structure/flora/tree/jungle/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tree[rand(1, 6)]"

/obj/structure/flora/tree/jungle/small
	pixel_y = 0
	pixel_x = -32
	icon = 'icons/obj/flora/jungletreesmall.dmi'
	icon_state = "tree1"

/obj/structure/flora/tree/jungle/small/style_2
	icon_state = "tree2"
/obj/structure/flora/tree/jungle/small/style_3
	icon_state = "tree3"
/obj/structure/flora/tree/jungle/small/style_4
	icon_state = "tree4"
/obj/structure/flora/tree/jungle/small/style_5
	icon_state = "tree5"
/obj/structure/flora/tree/jungle/small/style_6
	icon_state = "tree6"
/obj/structure/flora/tree/jungle/small/style_random/Initialize(mapload)
	. = ..()
	icon_state = "tree[rand(1, 6)]"

/**************
 * Pine Trees *
 **************/

/obj/structure/flora/tree/pine
	name = "pine tree"
	desc = "A coniferous pine tree."
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "pine_1"

/obj/structure/flora/tree/pine/style_2
	icon_state = "pine_2"
/obj/structure/flora/tree/pine/style_3
	icon_state = "pine_3"
/obj/structure/flora/tree/pine/style_random/Initialize(mapload)
	. = ..()
	icon_state = "pine_[rand(1,3)]"

/obj/structure/flora/tree/pine/xmas
	name = "xmas tree"
	desc = "A wondrous decorated Christmas tree."
	icon_state = "pine_c"
	flags_1 = NODECONSTRUCT_1 //protected by the christmas spirit

/obj/structure/flora/tree/pine/xmas/presents
	icon_state = "pinepresents"
	desc = "A wondrous decorated Christmas tree. It has presents!"
	var/gift_type = /obj/item/a_gift/anything
	var/unlimited = FALSE
	var/static/list/took_presents //shared between all xmas trees

/obj/structure/flora/tree/pine/xmas/presents/Initialize(mapload)
	. = ..()
	if(!took_presents)
		took_presents = list()

/obj/structure/flora/tree/pine/xmas/presents/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user.ckey)
		return

	if(took_presents[user.ckey] && !unlimited)
		to_chat(user, span_warning("There are no presents with your name on."))
		return
	to_chat(user, span_warning("After a bit of rummaging, you locate a gift with your name on it!"))

	if(!unlimited)
		took_presents[user.ckey] = TRUE

	var/obj/item/G = new gift_type(src)
	user.put_in_hands(G)

/obj/structure/flora/tree/pine/xmas/presents/unlimited
	desc = "A wonderous decorated Christmas tree. It has a seemly endless supply of presents!"
	unlimited = TRUE

/obj/structure/festivus
	name = "festivus pole"
	icon = 'icons/obj/flora/pinetrees.dmi'
	icon_state = "festivus_pole"
	desc = "During last year's Feats of Strength the Research Director was able to suplex this passing immobile rod into a planter."

/obj/structure/festivus/anchored
	name = "suplexed rod"
	desc = "A true feat of strength, almost as good as last year."
	icon_state = "anchored_rod"
	anchored = TRUE

/**************
 * Palm Trees *
 **************/

/obj/structure/flora/tree/palm
	name = "palm tree"
	icon = 'icons/misc/beach2.dmi'
	desc = "A tree straight from the tropics."
	icon_state = "palm1"
	pixel_x = 0

/obj/structure/flora/tree/palm/style_2
	icon_state = "palm2"
/obj/structure/flora/tree/palm/style_random/Initialize(mapload)
	. = ..()
	icon_state = "palm[rand(1,2)]"

/*********
 * Grass *
 *********/
/obj/structure/flora/grass
	name = "grass"
	desc = "A patch of overgrown grass."
	icon = 'icons/obj/flora/snowflora.dmi'
	gender = PLURAL //"this is grass" not "this is a grass"
	product_types = list(/obj/item/food/grown/grass = 10, /obj/item/seeds/grass = 1)
	harvest_amount_low = 0
	harvest_amount_high = 2
	harvest_message_low = "You uproot the grass from the ground, just for the fun of it."
	harvest_message_med = "You gather up some grass."
	harvest_message_high = "You gather up a handfull grass."
	needs_sharp_harvest = FALSE
	delete_on_harvest = TRUE
	flora_flags = FLORA_HERBAL

/obj/structure/flora/grass/brown
	icon_state = "snowgrass1bb"
/obj/structure/flora/grass/brown/style_2
	icon_state = "snowgrass2bb"
/obj/structure/flora/grass/brown/style_3
	icon_state = "snowgrass2bb"
/obj/structure/flora/grass/brown/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]bb"

/obj/structure/flora/grass/green
	icon_state = "snowgrass1gb"
/obj/structure/flora/grass/green/style_2
	icon_state = "snowgrass2gb"
/obj/structure/flora/grass/green/style_3
	icon_state = "snowgrass3gb"
/obj/structure/flora/grass/green/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowgrass[rand(1, 3)]gb"

/obj/structure/flora/grass/both
	icon_state = "snowgrassall1"
/obj/structure/flora/grass/both/style_2
	icon_state = "snowgrassall2"
/obj/structure/flora/grass/both/style_3
	icon_state = "snowgrassall3"
/obj/structure/flora/grass/both/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowgrassall[rand(1, 3)]"

/obj/structure/flora/grass/jungle
	name = "jungle grass"
	desc = "Thick alien flora."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "grassa1"

/obj/structure/flora/grass/jungle/a/style_2
	icon_state = "grassa2"
/obj/structure/flora/grass/jungle/a/style_3
	icon_state = "grassa3"
/obj/structure/flora/grass/jungle/a/style_4
	icon_state = "grassa4"
/obj/structure/flora/grass/jungle/a/style_5
	icon_state = "grassa5"
/obj/structure/flora/grass/jungle/a/style_random/Initialize(mapload)
	. = ..()
	icon_state = "grassa[rand(1, 5)]"

/obj/structure/flora/grass/jungle/b
	icon_state = "grassb1"
/obj/structure/flora/grass/jungle/b/style_2
	icon_state = "grassb2"
/obj/structure/flora/grass/jungle/b/style_3
	icon_state = "grassb3"
/obj/structure/flora/grass/jungle/b/style_4
	icon_state = "grassb4"
/obj/structure/flora/grass/jungle/b/style_5
	icon_state = "grassb5"
/obj/structure/flora/grass/jungle/b/style_random/Initialize(mapload)
	. = ..()
	icon_state = "grassb[rand(1, 5)]"

/**********
 * Bushes *
 **********/

/obj/structure/flora/bush
	name = "bush"
	desc = "Some type of shrubbery. Known for causing considerable economic stress on designers."
	icon = 'icons/obj/flora/ausflora.dmi'
	icon_state = "firstbush_1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/bush/style_2
	icon_state = "firstbush_2"
/obj/structure/flora/bush/style_3
	icon_state = "firstbush_3"
/obj/structure/flora/bush/style_4
	icon_state = "firstbush_4"
/obj/structure/flora/bush/style_random/Initialize(mapload)
	. = ..()
	icon_state = "firstbush_[rand(1, 4)]"

/obj/structure/flora/bush/reed
	icon_state = "reedbush_1"
/obj/structure/flora/bush/reed/style_2
	icon_state = "reedbush_2"
/obj/structure/flora/bush/reed/style_3
	icon_state = "reedbush_3"
/obj/structure/flora/bush/reed/style_4
	icon_state = "reedbush_4"
/obj/structure/flora/bush/reed/style_random/Initialize(mapload)
	. = ..()
	icon_state = "reedbush_[rand(1, 4)]"

/obj/structure/flora/bush/leafy
	icon_state = "leafybush_1"
/obj/structure/flora/bush/leavy/style_2
	icon_state = "leafybush_2"
/obj/structure/flora/bush/leavy/style_3
	icon_state = "leafybush_3"
/obj/structure/flora/bush/leavy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "leafybush_[rand(1, 3)]"

/obj/structure/flora/bush/pale
	icon_state = "palebush_1"
/obj/structure/flora/bush/pale/style_2
	icon_state = "palebush_2"
/obj/structure/flora/bush/pale/style_3
	icon_state = "palebush_3"
/obj/structure/flora/bush/pale/style_4
	icon_state = "palebush_4"
/obj/structure/flora/bush/pale/style_random/Initialize(mapload)
	. = ..()
	icon_state = "palebush_[rand(1, 4)]"

/obj/structure/flora/bush/stalky
	icon_state = "stalkybush_1"
/obj/structure/flora/bush/stalky/style_2
	icon_state = "stalkybush_2"
/obj/structure/flora/bush/stalky/style_3
	icon_state = "stalkybush_3"
/obj/structure/flora/bush/stalky/style_random/Initialize(mapload)
	. = ..()
	icon_state = "stalkybush_[rand(1, 3)]"

/obj/structure/flora/bush/grassy
	icon_state = "grassybush_1"
/obj/structure/flora/bush/grassy/style_2
	icon_state = "grassybush_2"
/obj/structure/flora/bush/grassy/style_3
	icon_state = "grassybush_3"
/obj/structure/flora/bush/grassy/style_4
	icon_state = "grassybush_4"
/obj/structure/flora/bush/grassy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "grassybush_[rand(1, 4)]"

/obj/structure/flora/bush/sparsegrass
	icon_state = "sparsegrass_1"
/obj/structure/flora/bush/sparsegrass/style_2
	icon_state = "sparsegrass_2"
/obj/structure/flora/bush/sparsegrass/style_3
	icon_state = "sparsegrass_3"
/obj/structure/flora/bush/sparsegrass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "sparsegrass_[rand(1, 3)]"

/obj/structure/flora/bush/fullgrass
	icon_state = "fullgrass_1"
/obj/structure/flora/bush/fullgrass/style_2
	icon_state = "fullgrass_2"
/obj/structure/flora/bush/fullgrass/style_3
	icon_state = "fullgrass_3"
/obj/structure/flora/bush/fullgrass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "fullgrass_[rand(1, 3)]"

/obj/structure/flora/bush/ferny
	icon_state = "fernybush_1"
/obj/structure/flora/bush/ferny/style_2
	icon_state = "fernybush_2"
/obj/structure/flora/bush/ferny/style_3
	icon_state = "fernybush_3"
/obj/structure/flora/bush/ferny/style_random/Initialize(mapload)
	. = ..()
	icon_state = "fernybush_[rand(1, 3)]"

/obj/structure/flora/bush/sunny
	icon_state = "sunnybush_1"
/obj/structure/flora/bush/sunny/style_2
	icon_state = "sunnybush_2"
/obj/structure/flora/bush/sunny/style_3
	icon_state = "sunnybush_3"
/obj/structure/flora/bush/sunny/style_random/Initialize(mapload)
	. = ..()
	icon_state = "sunnybush_[rand(1, 3)]"

/obj/structure/flora/bush/generic
	icon_state = "genericbush_1"
/obj/structure/flora/bush/generic/style_2
	icon_state = "genericbush_2"
/obj/structure/flora/bush/generic/style_3
	icon_state = "genericbush_3"
/obj/structure/flora/bush/generic/style_4
	icon_state = "genericbush_4"
/obj/structure/flora/bush/generic/style_random/Initialize(mapload)
	. = ..()
	icon_state = "genericbush_[rand(1, 4)]"

/obj/structure/flora/bush/pointy
	icon_state = "pointybush_1"
/obj/structure/flora/bush/pointy/style_2
	icon_state = "pointybush_2"
/obj/structure/flora/bush/pointy/style_3
	icon_state = "pointybush_3"
/obj/structure/flora/bush/pointy/style_4
	icon_state = "pointybush_4"
/obj/structure/flora/bush/pointy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "pointybush_[rand(1, 4)]"

/obj/structure/flora/bush/lavendergrass
	icon_state = "lavendergrass_1"
/obj/structure/flora/bush/lavendergrass/style_2
	icon_state = "lavendergrass_2"
/obj/structure/flora/bush/lavendergrass/style_3
	icon_state = "lavendergrass_3"
/obj/structure/flora/bush/lavendergrass/style_4
	icon_state = "lavendergrass_4"
/obj/structure/flora/bush/lavendergrass/style_random/Initialize(mapload)
	. = ..()
	icon_state = "lavendergrass_[rand(1, 4)]"

/obj/structure/flora/bush/flowers_yw
	icon_state = "ywflowers_1"
/obj/structure/flora/bush/flowers_yw/style_2
	icon_state = "ywflowers_2"
/obj/structure/flora/bush/flowers_yw/style_3
	icon_state = "ywflowers_3"
/obj/structure/flora/bush/flowers_yw/style_random/Initialize(mapload)
	. = ..()
	icon_state = "ywflowers_[rand(1, 3)]"

/obj/structure/flora/bush/flowers_br
	icon_state = "brflowers_1"
/obj/structure/flora/bush/flowers_br/style_2
	icon_state = "brflowers_2"
/obj/structure/flora/bush/flowers_br/style_3
	icon_state = "brflowers_3"
/obj/structure/flora/bush/flowers_br/style_random/Initialize(mapload)
	. = ..()
	icon_state = "brflowers_[rand(1, 3)]"

/obj/structure/flora/bush/flowers_pp
	icon_state = "ppflowers_1"
/obj/structure/flora/bush/flowers_pp/style_2
	icon_state = "ppflowers_2"
/obj/structure/flora/bush/flowers_pp/style_3
	icon_state = "ppflowers_3"
/obj/structure/flora/bush/flowers_pp/style_random/Initialize(mapload)
	. = ..()
	icon_state = "ppflowers_[rand(1, 3)]"

/obj/structure/flora/bush/snow
	icon = 'icons/obj/flora/snowflora.dmi'
	icon_state = "snowbush1"

/obj/structure/flora/bush/snow/style_2
	icon_state = "snowbush2"
/obj/structure/flora/bush/snow/style_3
	icon_state = "snowbush3"
/obj/structure/flora/bush/snow/style_4
	icon_state = "snowbush4"
/obj/structure/flora/bush/snow/style_5
	icon_state = "snowbush5"
/obj/structure/flora/bush/snow/style_6
	icon_state = "snowbush6"
/obj/structure/flora/bush/snow/style_random/Initialize(mapload)
	. = ..()
	icon_state = "snowbush[rand(1, 6)]"

/obj/structure/flora/bush/jungle
	desc = "A wild plant that is found in jungles."
	icon = 'icons/obj/flora/jungleflora.dmi'
	icon_state = "busha1"
	flora_flags = FLORA_HERBAL

/obj/structure/flora/bush/jungle/a/style_2
	icon_state = "busha2"
/obj/structure/flora/bush/jungle/a/style_3
	icon_state = "busha3"
/obj/structure/flora/bush/jungle/a/style_random/Initialize(mapload)
	. = ..()
	icon_state = "busha[rand(1, 3)]"

/obj/structure/flora/bush/jungle/b
	icon_state = "bushb1"
/obj/structure/flora/bush/jungle/b/style_2
	icon_state = "bushb2"
/obj/structure/flora/bush/jungle/b/style_3
	icon_state = "bushb3"
/obj/structure/flora/bush/jungle/b/style_random/Initialize(mapload)
	. = ..()
	icon_state = "bushb[rand(1, 3)]"

/obj/structure/flora/bush/jungle/c
	icon_state = "bushc1"
/obj/structure/flora/bush/jungle/c/style_2
	icon_state = "bushc2"
/obj/structure/flora/bush/jungle/c/style_3
	icon_state = "bushc3"
/obj/structure/flora/bush/jungle/c/style_random/Initialize(mapload)
	. = ..()
	icon_state = "bushc[rand(1, 3)]"

/obj/structure/flora/bush/large
	icon = 'icons/obj/flora/largejungleflora.dmi'
	icon_state = "bush1"
	pixel_x = -16
	pixel_y = -12
	layer = ABOVE_ALL_MOB_LAYER
	plane = ABOVE_GAME_PLANE

/obj/structure/flora/bush/large/style_2
	icon_state = "bush2"
/obj/structure/flora/bush/large/style_3
	icon_state = "bush3"
/obj/structure/flora/bush/large/style_random/Initialize(mapload)
	. = ..()
	icon_state = "bush[rand(1, 3)]"

/*********
 * Rocks *
 *********/
// (I know these aren't plants)

/obj/structure/flora/rock
	name = "large rock"
	icon_state = "basalt1"
	desc = "A volcanic rock. Pioneers used to ride these babies for miles."
	icon = 'icons/obj/flora/rocks.dmi'
	resistance_flags = FIRE_PROOF
	density = TRUE
	product_types = list(/obj/item/stack/ore/glass/basalt = 1)
	harvest_amount_low = 10
	harvest_amount_high = 20
	harvest_message_med = "You finish mining the rock."
	flora_flags = FLORA_STONE

/obj/structure/flora/rock/style_2
	icon_state = "basalt2"
/obj/structure/flora/rock/style_3
	icon_state = "basalt3"
/obj/structure/flora/rock/style_random/Initialize(mapload)
	. = ..()
	icon_state = "basalt[rand(1, 3)]"

/obj/structure/flora/rock/pile
	name = "rock pile"
	desc = "A pile of rocks."
	icon_state = "lavarocks1"
	harvest_amount_low = 5
	harvest_amount_high = 10
	harvest_message_med = "You finish mining the pile of rocks."
	density = FALSE

/obj/structure/flora/rock/pile/style_2
	icon_state = "lavarocks2"
/obj/structure/flora/rock/pile/style_3
	icon_state = "lavarocks3"
/obj/structure/flora/rock/pile/style_random/Initialize(mapload)
	. = ..()
	icon_state = "lavarocks[rand(1, 3)]"

/obj/structure/flora/rock/pile/jungle
	icon_state = "rock1"
	icon = 'icons/obj/flora/jungleflora.dmi'
/obj/structure/flora/rock/pile/jungle/style_2
	icon_state = "rock2"
/obj/structure/flora/rock/pile/jungle/style_3
	icon_state = "rock3"
/obj/structure/flora/rock/pile/jungle/style_4
	icon_state = "rock4"
/obj/structure/flora/rock/pile/jungle/style_5
	icon_state = "rock5"
/obj/structure/flora/rock/pile/jungle/style_random/Initialize(mapload)
	. = ..()
	icon_state = "rock[rand(1, 5)]"

/obj/structure/flora/rock/pile/jungle/large
	name = "pile of large rocks"
	icon_state = "rocks1"
	icon = 'icons/obj/flora/largejungleflora.dmi'
	pixel_x = -16
	pixel_y = -16
	harvest_amount_low = 9
	harvest_amount_high = 13

/obj/structure/flora/rock/pile/jungle/large/style_2
	icon_state = "rocks2"
/obj/structure/flora/rock/pile/jungle/large/style_3
	icon_state = "rocks3"
/obj/structure/flora/rock/pile/jungle/large/style_random/Initialize(mapload)
	. = ..()
	icon_state = "rocks[rand(1, 3)]"

//TODO: Make new sprites for these. the pallete in the icons are grey, and a white color here still makes them grey
/obj/structure/flora/rock/icy
	name = "icy rock"
	icon_state = "basalt1"
	color = rgb(204,233,235)

/obj/structure/flora/rock/icy/style_2
	icon_state = "basalt2"
/obj/structure/flora/rock/icy/style_3
	icon_state = "basalt3"
/obj/structure/flora/rock/icy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "basalt[rand(1, 3)]"

/obj/structure/flora/rock/pile/icy
	name = "icy rocks"
	icon_state = "lavarocks1"
	color = rgb(204,233,235)

/obj/structure/flora/rock/pile/icy/style_2
	icon_state = "lavarocks2"
/obj/structure/flora/rock/pile/icy/style_3
	icon_state = "lavarocks3"
/obj/structure/flora/rock/pile/icy/style_random/Initialize(mapload)
	. = ..()
	icon_state = "lavarocks[rand(1, 3)]"
